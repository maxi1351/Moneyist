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
    private let SERVER_ADDRESS = "http://localhost:4000/"
    
    // Converts ISO Date string to Swift Date format
    func convertISOTime(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return formatter.date(from: date)!
    }
    
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
    
    public func getServerAddress() -> String {
        return SERVER_ADDRESS
    }
}
