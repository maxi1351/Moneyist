//
//  SpendingCategory.swift
//  Moneyist
//
//  Created by Asma Nasir on 19/04/2021.
//

import Foundation
import UIKit

// Spending Category struct
struct SpendingCategory : Codable {
    public var _id: String
    public var name: String
    public var colour: String
}

struct Colour {
    public var name : String
    public var colour : UIColor
}
