//
//  Vibes.swift
//  Revealio
//
//  Created by hanif hussain on 01/05/2025.
//
import Foundation

struct Vibes: Codable, Hashable {
    var from: String
    var to: String
    var location: String
    var timestamp: Date
    var viewed: Bool
}

