//
//  Request.swift
//  coreDataFirebase
//
//  Created by Abdelrahman-Arw on 1/27/20.
//  Copyright © 2020 Abdelrahman-Arw. All rights reserved.
//

import Foundation

class CategoryRequest {
    
    func fetchDataBackend(urlString: String, onSuccess: (([[String:Any]]) -> Void)?)
    {
        
        
        
        URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            
            guard let data = data else { return }
            
            if let error = error {
                print(error)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                DispatchQueue.main.async(execute: { () -> Void in
                    onSuccess?(json as! [[String:Any]])
                })
                
            } catch {
                
            }
            
            
        }) .resume()

    }
    
}
