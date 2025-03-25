//
//  Date+Ext.swift
//  Revealio
//
//  Created by hanif hussain on 13/02/2025.
//
import Foundation

extension Date {
    func convertStringToDate(dateString: String) -> Date {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return outputFormatter.date(from: dateString) ?? Date()
    }


    func formatDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let result = formatter.string(from: date)
        return result
    }


    func formatStringToShortDate(string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let result = formatter.date(from: string)
        return result ?? Date()
    }


    func formatStringToShortDateForCellHeader(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E H:mm"
        let result = dateFormatter.string(from: date)
        return result
    }


    func formatStringToShortDateForMessage(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm"
        let result = dateFormatter.string(from: date)
        return result
    }
}
