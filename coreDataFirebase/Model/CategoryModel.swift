//
//  CategoryModel.swift
//  coreDataFirebase
//
//  Created by Abdelrahman-Arw on 1/21/20.
//  Copyright © 2020 Abdelrahman-Arw. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON

class CategoryModel {
    
    //MARK:- Varaibles
    var coreDataCategories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK:- Instance Method
    func loadFromJson(_ dict: JSON) -> Category {
        let category = Category(context: self.context)
        if let data = dict["title"].string  {
            category.title = data
        }
        if let data = dict["isSynced"].bool {
            category.isSynced = data
        }
        if let data = dict["lastUpdated"].string  {
            category.lastUpdated = data
        }
        if let data = dict["subCategory"].string {
            category.subCategory = data
        }
        if let data = dict["uniqueID"].string {
            category.uniqueID = data
        }
        return category
    }
    

    
    //MARK: - Main saving Method (Local and Backend)
    func saveCategory(category: Category,nodeId: String? = nil){
        category.saveObjects(in: context, object: category)
        //self.saveCategoriesBackend(category: category,nodeId: nodeId)
    }
    
    //MARK: - Adding Category Methods
    // A new category is created and checked if it's on the local and updated to add it
    func createCategoryEntity(categoryName: String,subCategory: String) -> Category{
        let date = getFormattedDate()
        let identifier = UUID()
        let newCategory = Category(context: self.context)
        newCategory.title = categoryName
        newCategory.uniqueID = identifier.uuidString
        newCategory.subCategory = subCategory
        newCategory.isSynced = false
        newCategory.lastUpdated = date
        return newCategory
    }
    func addCategory(categoryName: String, subCategory:String, onSuccess: ((Category) -> Void)?){
        let newCategory = createCategoryEntity(categoryName: categoryName, subCategory: subCategory)
        let checkExistence = newCategory.checkifExist(in: self.context,objects: self.coreDataCategories, uniqueID: newCategory.uniqueID!, onSuccess: { checkedCategory in
            
        })
        if !checkExistence {
            newCategory.saveObjects(in: self.context, object: newCategory)
            //saveCategoriesBackend(category: newCategory)
            onSuccess?(newCategory)
        }
        
    }

    

    func getFormattedDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.string(from: date)
    }

    

    

    
    
    //MARK: - Backend Methods
    func fetchDataDevice() -> [Category]{
        coreDataCategories = Category.fetchObjects(in: context){ fetchRequest in
            //Configuration code like adding predicates and sort descriptors
        }
        return coreDataCategories
    }
    func fetchDataBackEnd(onSuccess: (([Category]) -> Void)?){
        let deviceCategories = fetchDataDevice()
        var backEndCategories = [Category]()
        let categoryRequest = CategoryRequest()
        let _ = categoryRequest.fetchDataBackend(onSuccess: { result in
            
        let json = JSON(result)
            
            if let articles = json.array {
                for i in articles {
                    
                   let category = self.loadFromJson(i)
                    
                    let checkExistence = category.checkifExist(in: self.context,objects: deviceCategories, uniqueID: category.uniqueID!, onSuccess: { checkedCategory in
                        
                    })
                    if !checkExistence {
                        category.saveObjects(in: self.context, object: category)
                        backEndCategories.append(category)
                    }
                    
                    
                }
                
                
                onSuccess?(backEndCategories)
            }
        })
      
    }
    
    func saveCategoriesBackend(category: Category, nodeId: String? = nil){

        
    }

}
