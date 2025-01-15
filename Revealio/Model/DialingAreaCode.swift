//
//  DialingAreaCode.swift
//  Revealio
//
//  Created by hanif hussain on 05/01/2025.
//
import Foundation

struct DialingAreaCode: Codable, Identifiable {
    let id: String
    let name: String
    let flag: String
    let code: String
    let dial_code: String
    let pattern: String
    let limit: Int
}
