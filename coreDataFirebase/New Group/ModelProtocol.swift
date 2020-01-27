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
protocol Managed: class {
    static var entityName: String { get }
    
}
extension Managed where Self: NSManagedObject {
    static var entityName: String { return entity().name! }

}
