//
//  UILabel+Ext.swift
//  Revealio
//
//  Created by hanif hussain on 02/12/2024.
//
import UIKit

extension String {
    var isValidName: Bool {
        // check if minimum 7 characters and maximum 16 characters long
        let RegEx = "^\\w{7,16}$"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: self)
    }
    
    
    // check if email is valid
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    // basic check to see if password is valid
    func isValidPassword(_ password: String) -> Bool {
        // least one uppercase,
        // least one digit
        // least one lowercase
        // least one symbol
        //  min 8 characters total
        let password = self.trimmingCharacters(in: CharacterSet.whitespaces)
        let passwordRegx = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{8,}$"
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@",passwordRegx)
        return passwordCheck.evaluate(with: password)
    }
    
    
    func removeCountryCode(from phoneNumber: String) -> String? {
        // First remove all spaces
        let noSpaces = phoneNumber.replacingOccurrences(of: " ", with: "")
        
        // Find where the numbers start after the country code (+XX)
        if let range = noSpaces.range(of: "\\+\\d+", options: .regularExpression) {
            // Get everything after the country code and filter to keep only numbers
            let afterCode = noSpaces[range.upperBound...]
            return String(afterCode.filter { $0.isNumber })
        }
        
        // If no country code found, just return numbers
        return noSpaces.filter { $0.isNumber }
    }
    
    
    func extractLocalNumber(from phoneNumber: String) -> String? {
        let numbersOnly = String(phoneNumber).filter { $0.isNumber }
        return numbersOnly.isEmpty ? nil : numbersOnly
    }
}
