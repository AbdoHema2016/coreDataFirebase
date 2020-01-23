//
//  CategoryModel.swift
//  coreDataFirebase
//
//  Created by Abdelrahman-Arw on 1/21/20.
//  Copyright © 2020 Abdelrahman-Arw. All rights reserved.
//

import Foundation
import Firebase
import CoreData
class CategoryEntity :NSObject {
    var uniqueID: String?
    var title: String?
    var subCategory: String?
    var isSynced: String?
    var lastUpdated: String?
}
class CategoryModel {
    
    //MARK:- Varaibles
    var ref: DatabaseReference!
    var categories = [CategoryEntity]()
    var coreDataCategories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK:- Instance Method
    func loadFromDictionary(_ dict: [String: AnyObject]) -> CategoryEntity {
        let category = CategoryEntity()
        if let data = dict["title"] as? String {
            category.title = data
        }
        if let data = dict["isSynced"] as? String {
            category.isSynced = data
        }
        if let data = dict["lastUpdated"] as? String {
            category.lastUpdated = data
        }
        if let data = dict["subCategory"] as? String {
            category.subCategory = data
        }
        if let data = dict["uniqueID"] as? String {
            category.uniqueID = data
        }
        return category
    }
    

    
    //MARK: - Main saving Method (Local and Backend)
    func saveCategory(category: Category,nodeId: String? = nil){
        category.saveObjects(in: context, object: category)
        self.saveCategoriesBackend(category: category,nodeId: nodeId)
    }
    
    //MARK: - Adding Category Methods
    // A new category is created and checked if it's on the local and updated to add it
    func createCategoryEntity(categoryName: String,subCategory: String) -> CategoryEntity{
        let date = getFormattedDate()
        let identifier = UUID()
        let newCategory = CategoryEntity()
        newCategory.title = categoryName
        newCategory.uniqueID = identifier.uuidString
        newCategory.subCategory = subCategory
        newCategory.isSynced = "No"
        newCategory.lastUpdated = date
        return newCategory
    }
    func addCategory(categoryName: String, subCategory:String, onSuccess: ((Category) -> Void)?){
        let newCategory = createCategoryEntity(categoryName: categoryName, subCategory: subCategory)
        let (checkExistence,category) = self.checkifExist(category: newCategory)
        if checkExistence {
            let checkUpdated = self.checkifUpdated(updateDate: newCategory.lastUpdated!, category:category)
            if checkUpdated {
                category.deleteObject(in: context, object: category)
                self.categories.append(newCategory)
                self.saveCategory(category: category)
                self.coreDataCategories.append(category)
            }
            
            
        } else {
            self.categories.append(newCategory)
            self.saveCategory(category: category)
            self.coreDataCategories.append(category)

        }
        onSuccess?(category)
    }
    func checkifExist(category: CategoryEntity) -> (Bool,Category) {
        for checkCategory in coreDataCategories {
            if category.uniqueID == checkCategory.uniqueID {
                return (true,checkCategory)
            }
        }
        let newCategory = Category(context: self.context)
        newCategory.title = category.title
        newCategory.isSynced = category.isSynced
        newCategory.uniqueID = category.uniqueID
        newCategory.subCategory = category.subCategory
        newCategory.lastUpdated = category.lastUpdated
        return (false,newCategory)
    }
    
    func checkifUpdated(updateDate: String,category: Category) -> Bool {
        if updateDate != category.lastUpdated {
            return true
        }
        return false
    }
    
    func getFormattedDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.string(from: date)
    }

    

    

    
    
    //MARK: - Backend Methods
    func fetchFirebase(onSuccess: (([Category]) -> Void)?){
        ref = Database.database().reference()
        coreDataCategories = Category.fetchObjects(in: context){ fetchRequest in
            //Configuration code like adding predicates and sort descriptors
        }
        let nonSyncedCategories = Category.sendNonSynced(in: context)
        for i in nonSyncedCategories {
            i.saveObjects(in: context, object: i)
            saveCategoriesBackend(category: i)
        }
        ref.child("Categories").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for snap in snapshot.children {
                let categorySnap = snap as! DataSnapshot
                let categoryDict = categorySnap.value as! [String:AnyObject]
                let categoryEntity = self.loadFromDictionary(categoryDict)
                let newCategory = Category(context: self.context)
                newCategory.isSynced = categoryEntity.isSynced
                newCategory.title = categoryEntity.title
                newCategory.uniqueID = categoryEntity.uniqueID
                newCategory.subCategory = categoryEntity.subCategory
                newCategory.lastUpdated = categoryEntity.lastUpdated
                var foundCategory = Category(context: self.context)
                if newCategory.checkifExist(in: self.context,objects: self.coreDataCategories, uniqueID: categoryEntity.uniqueID!, onSuccess: { checkedCategory in
                    foundCategory = checkedCategory
                    
                }) {
                    let checkifUpdated = foundCategory.checkifUpdated(updateDate: categoryEntity.lastUpdated!, object: foundCategory)
                    if checkifUpdated {
                        
                        foundCategory.deleteObject(in: self.context, object: foundCategory)
                        if let index = self.coreDataCategories.index(where: {$0.uniqueID == foundCategory.uniqueID}) {
                            self.coreDataCategories.remove(at: index)
                        }
                        newCategory.saveObjects(in: self.context, object: newCategory)
                        self.coreDataCategories.append(newCategory)
                    }
                    
                } else {
                    newCategory.saveObjects(in: self.context, object: newCategory)
                    self.coreDataCategories.append(newCategory)
                }
                
            }
            onSuccess?(self.coreDataCategories)
        })
        
    }
    
    func saveCategoriesBackend(category: Category, nodeId: String? = nil){
        var nodeID = ref.childByAutoId().key
        if nodeId != nil {
            nodeID = nodeId
        }
        category.setValue("yes", forKey: "isSynced")
        self.ref.child("Categories").child(nodeID!).setValue(["title": category.title,"isSynced":category.isSynced,"lastUpdated":category.lastUpdated,"subCategory":category.subCategory,"uniqueID":category.uniqueID]) { (error, ref) in
            guard error == nil else {
                
                print("error saving into firebase\(error?.localizedDescription ?? "something went Wrong")")
                return
            }
            
            category.saveObjects(in: self.context, object: category)
        }
    }

}
