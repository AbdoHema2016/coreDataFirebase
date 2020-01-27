//
//  NotesModel.swift
//  coreDataFirebase
//
//  Created by Abdelrahman-Arw on 1/23/20.
//  Copyright © 2020 Abdelrahman-Arw. All rights reserved.
//

import Foundation
import CoreData

extension Category: Managed {
    
    
}
protocol Managed: class, NSFetchRequestResult {
    static var entityName: String { get }
    
}
extension Managed where Self: NSManagedObject {
    static var entityName: String { return entity().name! }

    static func fetchObjects(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> ()) -> [Self] {
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        configurationBlock(request)
        return try! context.fetch(request)
    }
    
    func saveObjects(in context:NSManagedObjectContext,object: Self){
        do {
            
            try context.save()
        } catch {
            print("Error saving Object \(error)")
        }
    }
    
    func deleteObject(in context: NSManagedObjectContext, object: Self){
        context.delete(object)
        do {
            try context.save()
        } catch {
            print("Error saving Object \(error)")
        }
    }
    
    static func sendNonSynced(in context: NSManagedObjectContext) -> [Self] {
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        request.predicate = NSPredicate(format: "isSynced == %@", NSNumber(value: false))
        return try! context.fetch(request)
    }
    
    func checkifExist(in context:NSManagedObjectContext,objects:[Self], uniqueID: String,onSuccess: ((Self) -> Void)?) -> Bool {
       

        
        for checkObject in objects {
            if let updateKey = checkObject.value(forKey: "uniqueID") {
                if uniqueID == updateKey as! String {
                    onSuccess?(checkObject)
                    return true
                }
            }
            
        }
        return false
    }
    func checkifUpdated(updateDate: String,object: Self) -> Bool {
        if updateDate != object.value(forKey: "lastUpdated") as? String {
            return true
        }
        return false
    }
}
