//
//  SavingSpace.swift
//  Moneyist
//
//  Created by Maxi Rapa on 05/04/2021.
//

import Foundation

// Saving Space Struct
struct SavingSpace : Codable {
    public var userID: String?
    public var category: String
    public var amount: Int32
    //public var description: String
    public var endDate: String
}
