//
//  CategoryRepository.swift
//  coreDataFirebase
//
//  Created by Abdelrahman-Arw on 1/27/20.
//  Copyright © 2020 Abdelrahman-Arw. All rights reserved.
//

import Foundation
import CoreData



protocol DeviceRepository {
    associatedtype ModelType: NSFetchRequestResult & Managed
     func fetchObjects(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<ModelType>) -> ()) -> [ModelType]
     func saveObjects(in context:NSManagedObjectContext,object: ModelType)
     func deleteObject(in context: NSManagedObjectContext, object: ModelType)
     func sendNonSynced(in context: NSManagedObjectContext) -> [ModelType]
     func checkExistence(in context: NSManagedObjectContext,uniqueID: String) -> [ModelType]
     func checkUpdate(in context: NSManagedObjectContext,updateDate: String) -> [ModelType]
}



extension DeviceRepository {
    
    
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
        request.predicate = NSPredicate(format: "uniqueID MATCHES %@", uniqueID)
        return try! context.fetch(request)
    }
    
    
     func checkUpdate(in context: NSManagedObjectContext,updateDate: String) -> [ModelType] {
        let request = NSFetchRequest<ModelType>(entityName: ModelType.entityName)
        request.predicate = NSPredicate(format: "lastUpdated MATCHES %@", updateDate)
        return try! context.fetch(request)
    }
}
