//
//  BackendRepository.swift
//  coreDataFirebase
//
//  Created by Abdelrahman-Arw on 1/27/20.
//  Copyright © 2020 Abdelrahman-Arw. All rights reserved.
//

import Foundation
import CoreData

protocol BackendRepository {
    associatedtype BackEndModelType: NSFetchRequestResult & Managed
    func fetchDataBackEnd(in context: NSManagedObjectContext,onSuccess: (([CategoryRepository.ModelType]) -> Void)?)
    
}
extension BackendRepository {
    
    //MARK:- Instance Method
    func loadFromJson(_ dict: [String:Any],in context: NSManagedObjectContext) -> CategoryRepository.ModelType {
        let category = CategoryRepository.ModelType(context: context)
        if let data = dict["title"]  {
            category.title = data as? String
        }
        if let data = dict["isSynced"] {
            category.isSynced = data as! Bool
        }
        if let data = dict["lastUpdated"]  {
            category.lastUpdated = data as? String
        }
        if let data = dict["subCategory"] {
            category.subCategory = data as? String
        }
        if let data = dict["uniqueID"] {
            category.uniqueID = data as? String
        }
        return category
    }
    
    func fetchDataBackEnd(in context: NSManagedObjectContext,onSuccess: (([CategoryRepository.ModelType]) -> Void)?){
        
        
        let categoryRequest = CategoryRequest()
        let categoryRepo = CategoryRepository()
        var categories = [CategoryRepository.ModelType]()
        
        
        let _ = categoryRequest.fetchDataBackend(onSuccess: { result in
            
            
                for i in result {
                    context.rollback()
                    let category = self.loadFromJson(i, in: context)
                    
                    let checkExistence = categoryRepo.checkExistence(in: context, uniqueID: category.uniqueID!)
                    if checkExistence.count == 1 {
                        categoryRepo.saveObjects(in: context, object: category)
                        categories.append(category)
                        
                    }
                    
                
                
                
                
            }
            onSuccess?(categories)
        })
        
    }
}
