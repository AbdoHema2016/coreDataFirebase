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
    var coreDataStoreName: String { get }
    var uniqueID: String { get }
    var isSynced: String { get }
     func fetchObjects(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<ModelType>) -> ()) -> [ModelType]
     func saveObjects(in context:NSManagedObjectContext,object: ModelType)
     func deleteObject(in context: NSManagedObjectContext, object: ModelType)
     func sendNonSynced(in context: NSManagedObjectContext) -> [ModelType]
     func checkExistence(in context: NSManagedObjectContext,objectUniqueID: String) -> [ModelType]
     func checkUpdate(in context: NSManagedObjectContext,updateDate: String) -> [ModelType]
}



extension DeviceRepository {
    
    // MARK: - Core Data stack
    var persistentContainer: NSPersistentContainer  {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: coreDataStoreName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }
     var managedObjectContext: NSManagedObjectContext  {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
        return managedObjectContext
    }
    
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
        request.predicate = NSPredicate(format: "\(isSynced) == %@", NSNumber(value: false))
        return try! context.fetch(request)
    }
     func checkExistence(in context: NSManagedObjectContext,objectUniqueID: String) -> [ModelType] {
        let request = NSFetchRequest<ModelType>(entityName: ModelType.entityName)
        request.predicate = NSPredicate(format: "\(uniqueID) MATCHES %@", objectUniqueID)
        return try! context.fetch(request)
    }
    
    
     func checkUpdate(in context: NSManagedObjectContext,updateDate: String) -> [ModelType] {
        let request = NSFetchRequest<ModelType>(entityName: ModelType.entityName)
        request.predicate = NSPredicate(format: "lastUpdated MATCHES %@", updateDate)
        return try! context.fetch(request)
    }
}
