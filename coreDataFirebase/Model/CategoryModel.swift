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
    
    
   
    
    //MARK: - CoreData Flow Methods
    func saveCategoriesCoreData(category: Category){
        do {
            try context.save()
        } catch {
            print("Error saving categories \(error)")
        }
    }
    
    func loadCategories(with request:NSFetchRequest<Category> = Category.fetchRequest()) -> [Category]{
        
        do {
            coreDataCategories = try context.fetch(request)
        } catch {
            print("error loading data \(error)")
        }
        return coreDataCategories
    }
    
    func deleteCategory(category: Category){
        self.context.delete(category)
    }

    
    //MARK: - Main saving Method
    func saveCategory(category: Category,nodeId: String? = nil){
        self.saveCategoriesCoreData(category: category)
        self.saveCategoriesBackend(category: category,nodeId: nodeId)
    }
    
    //MARK: - Adding Category Methods
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
                deleteCategory(category: category)
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

    
    //MARK: - Syncing Data
    func sendNonSyncedData(){
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        let predicate = NSPredicate(format: "isSynced CONTAINS[cd] %@", "No")
        request.predicate = predicate
        var nonSynced = [Category]()
        do {
            nonSynced = try context.fetch(request)
            for category in nonSynced {
                saveCategoriesBackend(category: category)
            }
            
        } catch {
            print("Can't save mobile saved data\(error)")
        }
        
    }
    
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
    
    //MARK: - Backend Methods
    func fetchFirebase(onSuccess: (([Category]) -> Void)?){
        ref = Database.database().reference()
        coreDataCategories = loadCategories()
        sendNonSyncedData()
        ref.child("Categories").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for snap in snapshot.children {
                let categorySnap = snap as! DataSnapshot
                let categoryDict = categorySnap.value as! [String:AnyObject]
                let categoryEntity = self.loadFromDictionary(categoryDict)
                let (checkExistence,category) = self.checkifExist(category: categoryEntity)
                if checkExistence {
                    let checkUpdated = self.checkifUpdated(updateDate: categoryEntity.lastUpdated!, category:category)
                    if checkUpdated {
                        self.deleteCategory(category: category)
                        if let index = self.coreDataCategories.index(where: {$0.uniqueID == category.uniqueID}) {
                            self.coreDataCategories.remove(at: index)
                        }
                        self.categories.append(categoryEntity)
                    }
                    
                    
                } else {
                    self.categories.append(categoryEntity)
                }
                
                
            }
            let newCategories = self.categories.map({response -> Category in
                let newCategory = Category(context: self.context)
                newCategory.isSynced = response.isSynced
                newCategory.title = response.title
                newCategory.uniqueID = response.uniqueID
                newCategory.subCategory = response.subCategory
                newCategory.lastUpdated = response.lastUpdated
                self.saveCategoriesCoreData(category: newCategory)
                return newCategory
            })
            for i in newCategories{
                self.coreDataCategories.append(i)
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
            
            self.saveCategoriesCoreData(category: category)
        }
    }

}
