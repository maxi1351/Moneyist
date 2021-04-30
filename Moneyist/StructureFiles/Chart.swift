//
//  Chart.swift
//  Moneyist
//
//  Created by Asma Nasir on 27/04/2021.
//

import Foundation

// Pie chart struct
struct PieChart : Codable {
    public var categoryId: String
    public var name: String
    public var amount: Int32
}

// Bar chart struct
struct BarChart : Codable {
    public var incomeAmount: Int32
    public var outcomeAmount: Int32
}
