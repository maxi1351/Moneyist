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
    private var currencySymbol = "€"
    private var currency = "EUR"
    
    public func getUID() -> String {
        return uid
    }
    
    public func setUID(id: String) {
        uid = id
    }
    
    public func getCurrencySymbol() -> String {
        return currencySymbol
    }
    
    public func setCurrencySymbol(symbol: String) {
        currencySymbol = symbol
    }
    
    public func getCurrency() -> String {
        return currency
    }
    
    public func setCurrency(newCurrency: String) {
        currency = newCurrency
    }
}
