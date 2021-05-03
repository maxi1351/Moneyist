//
//  Reminder.swift
//  Moneyist
//
//  Created by Asma Nasir on 04/04/2021.
//

import Foundation

// Reminder struct
struct Reminder : Codable {
    public var title: String
    public var reminderId: String
    public var date: String
    public var description : String?
}

