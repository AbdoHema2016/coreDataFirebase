//
//  Request.swift
//  coreDataFirebase
//
//  Created by Abdelrahman-Arw on 1/27/20.
//  Copyright © 2020 Abdelrahman-Arw. All rights reserved.
//

import Foundation

class CategoryRequest {
    
    func fetchDataBackend(onSuccess: (([[String:Any]]) -> Void)?)
    {
        
        let urlString = "http://localhost:3000/categories"
        
        URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            
            guard let data = data else { return }
            
            if let error = error {
                print(error)
                return
            }
            
           // let dataString = String(data: data, encoding: .utf8)
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
