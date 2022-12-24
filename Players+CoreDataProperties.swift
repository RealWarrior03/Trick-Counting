//
//  Players+CoreDataProperties.swift
//  Rage
//
//  Created by Henry Krieger on 10.01.22.
//
//

import Foundation
import CoreData


extension Players {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Players> {
        return NSFetchRequest<Players>(entityName: "Players")
    }

    @NSManaged public var name: String
    @NSManaged public var points: Int64

}

extension Players : Identifiable {

}
