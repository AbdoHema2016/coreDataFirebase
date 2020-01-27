//
//  CategoryRepository.swift
//  coreDataFirebase
//
//  Created by Abdelrahman-Arw on 1/27/20.
//  Copyright © 2020 Abdelrahman-Arw. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
protocol Repository {
    associatedtype ModelType: NSFetchRequestResult & Managed
     func fetchObjects(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<ModelType>) -> ()) -> [ModelType]
     func saveObjects(in context:NSManagedObjectContext,object: ModelType)
     func deleteObject(in context: NSManagedObjectContext, object: ModelType)
     func sendNonSynced(in context: NSManagedObjectContext) -> [ModelType]
     func checkExistence(in context: NSManagedObjectContext,uniqueID: String) -> [ModelType]
     func checkUpdate(in context: NSManagedObjectContext,updateDate: String) -> [ModelType]
}
protocol BackendRepository {
    associatedtype BackEndModelType: NSFetchRequestResult & Managed

}
extension BackendRepository {
    
    
    func fetchDataBackEnd(in context: NSManagedObjectContext,onSuccess: (([BackEndModelType]) -> Void)?){
        
        
        let categoryRequest = CategoryRequest()
        let categoryRepo = CategoryRepository()
        let categoryModel = CategoryModel()
        let deviceObjects = categoryRepo.fetchObjects(in: context) { request in
            
        }
        let _ = categoryRequest.fetchDataBackend(onSuccess: { result in
            
            let json = JSON(result)
            
            if let articles = json.array {
                for i in articles {
                    
                    let category = categoryModel.loadFromJson(i)
                    
                    let checkExistence = categoryRepo.checkExistence(in: context, uniqueID: category.uniqueID!)
                    if checkExistence.count > 0 {
                        categoryRepo.saveObjects(in: context, object: checkExistence[0])
                        //onSuccess?(checkExistence)
                    }
                    
                }
                
                
                
            }
        })
        
    }
}

struct CategoryRepository: Repository,BackendRepository {
    typealias BackEndModelType = Category
    typealias ModelType = Category
    
}

extension Repository {
    
    
     func fetchObjects(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<ModelType>) -> ()) -> [ModelType] {
        
        let request = NSFetchRequest<ModelType>(entityName: ModelType.entityName)
        configurationBlock(request)
        return try! context.fetch(request)
        
    }
    
     func saveObjects(in context:NSManagedObjectContext,object: ModelType){
        do {
            
            try context.save()
        } catch {
            print("Error saving Object \(error)")
        }
    }
    
     func deleteObject(in context: NSManagedObjectContext, object: ModelType){
        context.delete(object as! NSManagedObject)
        do {
            try context.save()
        } catch {
            print("Error saving Object \(error)")
        }
    }
    
     func sendNonSynced(in context: NSManagedObjectContext) -> [ModelType] {
        let request = NSFetchRequest<ModelType>(entityName: ModelType.entityName)
        request.predicate = NSPredicate(format: "isSynced == %@", NSNumber(value: false))
        return try! context.fetch(request)
    }
     func checkExistence(in context: NSManagedObjectContext,uniqueID: String) -> [ModelType] {
        let request = NSFetchRequest<ModelType>(entityName: ModelType.entityName)
        request.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
        return try! context.fetch(request)
    }
    
    
     func checkUpdate(in context: NSManagedObjectContext,updateDate: String) -> [ModelType] {
        let request = NSFetchRequest<ModelType>(entityName: ModelType.entityName)
        request.predicate = NSPredicate(format: "lastUpdated == %@", updateDate)
        return try! context.fetch(request)
    }
}
