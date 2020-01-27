//
//  Request.swift
//  coreDataFirebase
//
//  Created by Abdelrahman-Arw on 1/27/20.
//  Copyright © 2020 Abdelrahman-Arw. All rights reserved.
//

import Foundation
import Alamofire

class CategoryRequest {
    
    func fetchDataBackend(onSuccess: ((Any) -> Void)?)
    {
        var url:String!
        url = "http://localhost:3000/categories"
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result{
                case .success:
                    
                    let result = response.result.value
                    onSuccess?(result)
                    
                case .failure(let error):
                    print(error)
                }
        }
    }
    
}
