//
//  User.swift
//  Moneyist
//
//  Created by Maxi Rapa on 29/03/2021.
//

import Foundation

class UserDetails {
    static let sharedInstance = UserDetails()
    private var uid = ""
    
    public func getUID() -> String {
        return uid
    }
    
    public func setUID(id: String) {
        uid = id
    }
}
