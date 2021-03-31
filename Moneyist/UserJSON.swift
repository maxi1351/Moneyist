//
//  UserJSON.swift
//  Moneyist
//
//  Created by Maxi Rapa on 30/03/2021.
//

import Foundation


// Budget Struct
struct User : Codable {
    public var __v: Int32
    public var _id: String
    public var dateOfBirth: String
    public var email: String
    public var firstName: String
    public var mobileNumber: String
    //public var passwordHash: String
    public var surname: String
}
