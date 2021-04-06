//
//  Reminder.swift
//  Moneyist
//
//  Created by Asma Nasir on 04/04/2021.
//

import Foundation

// Reminder struct
struct Reminder : Codable {
    //public var userID: String
    public var title: String
    //public var reminderID: String?            // Fix - nil returned
    public var date: String
}

struct ReminderID: Codable {
    var reminderID: String?
}

