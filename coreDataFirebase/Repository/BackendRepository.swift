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
    var uniqueID: String { get }
    var url: String { get }
    func fetchDataBackEnd(onSuccess: (([[String : Any]]) -> Void)?)
    func loadFromJson(_ dict: [String:Any],in context: NSManagedObjectContext,with object:NSManagedObject,onSuccess: ((NSManagedObject) -> Void)?) 
    
}
extension BackendRepository {
    
    //MARK:- Instance Method
    func loadFromJson(_ dict: [String:Any],in context: NSManagedObjectContext,with object:NSManagedObject,onSuccess: ((NSManagedObject) -> Void)?) {
        for (k, v) in dict {
            if object.entity.propertiesByName.keys.contains(k){
               object.setValue(v, forKey: k)
            }
        }
        if object.value(forKey: uniqueID) != nil{
           onSuccess?(object)
        }
       
    }
    
    func fetchDataBackEnd(onSuccess: (([[String : Any]]) -> Void)?){
        
        
        let categoryRequest = CategoryRequest()
        let _ = categoryRequest.fetchDataBackend(urlString: url, onSuccess: { result in
            
            onSuccess?(result)
        })
        
    }
}
