//
//  Budget.swift
//  Moneyist
//
//  Created by Maxi Rapa on 26/03/2021.
//

import Foundation

struct Budget : Codable {
    public var __v: Int32
    public var _id: String
    public var amountAfterExpenses: Int32
    public var amountForNeeds: Int32
    public var amountForWants: Int32
    public var endDate: String
    public var initialAmount: Int32
    public var name: String?
    public var savingsAndDebts: Int32
    public var startDate: String
    public var userID: String?
}


