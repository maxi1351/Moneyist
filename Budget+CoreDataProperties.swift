//
//  Budget+CoreDataProperties.swift
//  Moneyist
//
//  Created by Maxi Rapa on 26/03/2021.
//
//

import Foundation
import CoreData


extension Budget {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Budget> {
        return NSFetchRequest<Budget>(entityName: "Budget")
    }

    @NSManaged public var endDate: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var savingsAndDebts: Int32
    @NSManaged public var amountForWants: Int32
    @NSManaged public var amountForNeeds: Int32
    @NSManaged public var amountAfterExpenses: Int32
    @NSManaged public var initialAmount: Int32
    @NSManaged public var name: String?
    @NSManaged public var userID: String?

}

extension Budget : Identifiable {

}
