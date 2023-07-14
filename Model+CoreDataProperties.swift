//
//  Model+CoreDataProperties.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 7/14/23.
//
//

import Foundation
import CoreData


extension Model {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Model> {
        return NSFetchRequest<Model>(entityName: "Model")
    }

    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var importance: String?
    @NSManaged public var isDone: Bool
    @NSManaged public var creationDate: Date?
    @NSManaged public var modificationDate: Date?
    @NSManaged public var deadline: Date?

}

extension Model : Identifiable {

}
