//
//  NotesModel.swift
//  coreDataFirebase
//
//  Created by Abdelrahman-Arw on 1/23/20.
//  Copyright © 2020 Abdelrahman-Arw. All rights reserved.
//

import Foundation
import CoreData


struct CategoryRepository: DeviceRepository,BackendRepository {
    var url: String
    var isSynced: String
    var uniqueID: String
    typealias BackEndModelType = Category
    typealias ModelType = Category
}
extension Category: Managed {
}

protocol Managed: class {
    static var entityName: String { get }
}
extension Managed where Self: NSManagedObject {
    static var entityName: String { return entity().name! }
}

