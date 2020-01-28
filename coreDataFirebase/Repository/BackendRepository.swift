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
    func loadFromJson(_ dict: [String:Any],in context: NSManagedObjectContext,onSuccess: ((CategoryRepository.ModelType) -> Void)?) {
        let category = CategoryRepository.ModelType(context: context)
        for (k, v) in dict {
            
                category.setValue(v, forKey: k)
            
            
        }
       onSuccess?(category)
        
    }
    
    func fetchDataBackEnd(in context: NSManagedObjectContext,onSuccess: (([CategoryRepository.ModelType]) -> Void)?){
        
        
        let categoryRequest = CategoryRequest()
        let categoryRepo = CategoryRepository()
        var categories = [CategoryRepository.ModelType]()
        var category = CategoryRepository.ModelType()
        
        let _ = categoryRequest.fetchDataBackend(onSuccess: { result in
            
            
                for i in result {
                    context.rollback()
                    let _ = self.loadFromJson(i, in: context, onSuccess: {result in
                        category = result
                        let checkExistence = categoryRepo.checkExistence(in: context, uniqueID: category.uniqueID!)
                        if checkExistence.count == 1 {
                            categoryRepo.saveObjects(in: context, object: category)
                            categories.append(category)
                            
                        }
                    })
                    
                   
                    
                
                
                
                
            }
            onSuccess?(categories)
        })
        
    }
}
