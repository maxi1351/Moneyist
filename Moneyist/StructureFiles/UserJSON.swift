//
//  UserJSON.swift
//  Moneyist
//
//  Created by Maxi Rapa on 30/03/2021.
//

import Foundation


// User Data Struct
struct User : Codable {
    public var _id: String
    public var mobileNumber: String
    public var email: String
    public var firstName: String
    public var surname: String
    public var dateOfBirth: String
    public var currency: String
    public var createdAt: String
}
