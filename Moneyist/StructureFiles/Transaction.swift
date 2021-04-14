//
//  Transaction.swift
//  Moneyist
//
//  Created by Maxi Rapa on 29/03/2021.
//

import Foundation

// Transaction Struct
struct Transaction : Codable {
    public var _id: String?
    public var date: String
    public var status: String // CONFIRMED / PENDING
    public var amount: Int32 // 0 minimum
    public var currency: String // GBP / EUR
    public var type: String // INCOME / OUTCOME
    public var userID: String
}
