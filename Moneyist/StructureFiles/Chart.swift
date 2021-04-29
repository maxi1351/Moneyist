//
//  Chart.swift
//  Moneyist
//
//  Created by Asma Nasir on 27/04/2021.
//

import Foundation

// Pie chart struct
/*struct PieChart : Codable {
    public var category : pieDetails
}*/

//struct pieDetails : Codable {
struct PieChart : Codable {
    public var categoryId: String
    public var name: String 
    //public var category : Category
    public var amount: Int32
}

// Bar chart struct
struct BarChart : Codable {
    public var incomeAmount: Int32
    public var outcomeAmount: Int32
}

struct Category : Codable {
    public var id : String
    public var name : String
}
