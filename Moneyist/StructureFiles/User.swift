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
    private var currencySymbol = ""
    private var currency = ""
    private let SERVER_ADDRESS = "http://localhost:4000/"
    
    // The colour names and the associated colours for spending categories and chart
    private let colours: [Colour] = [Colour(name : "Red", colour : #colorLiteral(red: 0.740345693, green: 0, blue: 0, alpha: 1)), Colour(name : "Pink", colour : #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)), Colour(name : "Purple", colour : #colorLiteral(red: 0.5181954339, green: 0.1377481533, blue: 0.4142243851, alpha: 1)), Colour(name : "Blue", colour : #colorLiteral(red: 0.0295518333, green: 0.6683234873, blue: 0.6948065091, alpha: 1)), Colour(name : "Dark Blue", colour : #colorLiteral(red: 0.08545940347, green: 0.4380371363, blue: 0.7108970207, alpha: 1)), Colour(name : "Green", colour : #colorLiteral(red: 0.4226264084, green: 0.7824036593, blue: 0.04489424754, alpha: 1)), Colour(name : "Dark Green", colour : #colorLiteral(red: 0.06251720995, green: 0.44866765, blue: 0.1985127027, alpha: 1)), Colour(name : "Yellow", colour : #colorLiteral(red: 1, green: 0.7656800151, blue: 0, alpha: 1)), Colour(name : "Orange", colour : #colorLiteral(red: 0.9372549057, green: 0.4632681085, blue: 0.1670947782, alpha: 1)), Colour(name : "Teal", colour : #colorLiteral(red: 0.3625314095, green: 0.1753686065, blue: 0.7204906088, alpha: 1)), Colour(name : "Pastel Red", colour : #colorLiteral(red: 0.9999001622, green: 0.6027976274, blue: 0.5306107402, alpha: 1)), Colour(name : "Pastel Pink", colour : #colorLiteral(red: 0.9736151099, green: 0.7306614518, blue: 0.8117393851, alpha: 1)), Colour(name : "Pastel Purple", colour : #colorLiteral(red: 0.7313332107, green: 0.6118800604, blue: 0.9341402202, alpha: 1)), Colour(name : "Pastel Blue", colour : #colorLiteral(red: 0.6872427152, green: 0.9401760697, blue: 0.932405972, alpha: 1)), Colour(name : "Pastel Dark Blue", colour : #colorLiteral(red: 0.5633886456, green: 0.6930433512, blue: 0.9462428689, alpha: 1)), Colour(name : "Pastel Light Green", colour : #colorLiteral(red: 0.7925249338, green: 0.9459932446, blue: 0.6460326314, alpha: 1)), Colour(name : "Pastel Dark Green", colour : #colorLiteral(red: 0.5353135467, green: 0.8256990314, blue: 0.7526711822, alpha: 1)), Colour(name : "Pastel Yellow", colour : #colorLiteral(red: 1, green: 0.9514554593, blue: 0.3695297286, alpha: 1)),Colour(name : "Pastel Orange", colour : #colorLiteral(red: 0.9991378188, green: 0.7395963667, blue: 0.515700481, alpha: 1)), Colour(name : "Grey", colour : #colorLiteral(red: 0.6351621814, green: 0.7064645402, blue: 0.6943587715, alpha: 1))]
    
    // Converts ISO Date string to Swift Date format
    func convertISOTime(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return formatter.date(from: date)!
    }
    
    public func getColours() -> [Colour] {
        return colours
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
        
        switch (newCurrency) {
        case "EUR":
            currencySymbol = "€"
            break
        case "GBP":
            currencySymbol = "£"
            break
        case "JPY":
            currencySymbol = "JP¥"
        default:
            break
        }
    }
    
    public func getServerAddress() -> String {
        return SERVER_ADDRESS
    }
}
