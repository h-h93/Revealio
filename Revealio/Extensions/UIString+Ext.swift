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


    func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }

    
    // Remove the whitespace from text if no other characters are entered
    func formatText(_ text: String) -> String {
        // Split the text into lines
        var lines = text.components(separatedBy: .newlines)

        // Find the last line with content
        var lastNonEmptyLineIndex = lines.count - 1
        while lastNonEmptyLineIndex >= 0 && lines[lastNonEmptyLineIndex].trimmingCharacters(in: .whitespaces).isEmpty {
            lastNonEmptyLineIndex -= 1
        }

        // If we found a line with content, keep only up to that line
        if lastNonEmptyLineIndex >= 0 {
            lines = Array(lines[0...lastNonEmptyLineIndex])
            return lines.joined(separator: "\n")
        }

        return text
    }


    // Format the text to display the short end of the text right at the end using to display date of message sent
    func formatTextWithStylingForSubstring(text: String, smallTextSubstring: String) -> NSAttributedString {
        // First apply the whitespace formatting
        let formattedText = formatText(text)

        // Create attributed string with default attributes
        let attributedString = NSMutableAttributedString(string: formattedText)

        // Define attributes for the main text
        let mainAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.black
        ]

        // Apply main attributes to the entire string
        attributedString.addAttributes(mainAttributes,
                                       range: NSRange(location: 0, length: formattedText.count))

        // Define attributes for the smaller text
        let smallTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.lightGray
        ]

        // Find the range of the substring to style
        if let range = formattedText.range(of: smallTextSubstring) {
            let nsRange = NSRange(range, in: formattedText)
            attributedString.addAttributes(smallTextAttributes, range: nsRange)
        }

        return attributedString
    }


    func estimatedFrameForText(text: String, fontSize: CGFloat) -> CGRect {
        let maxWidth = UIScreen.main.bounds.width * 0.7 // 70% of screen width
        let size = CGSize(width: maxWidth, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)

        let boundingRect = NSString(string: text).boundingRect(
            with: size,
            options: options,
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)],
            context: nil
        )

        // Add some extra height to account for padding and prevent squashing
        let extraHeight: CGFloat = 10
        return CGRect(
            x: 0,
            y: 0,
            width: ceil(boundingRect.width),
            height: ceil(boundingRect.height) + extraHeight
        )
    }
}
