//
//  User.swift
//  Revealio
//
//  Created by hanif hussain on 01/01/2025.
//
import Foundation
// Models/User.swift
struct User: Codable {
    let id: String
    let displayName: String
    let photoURL: String?
    let createdAt: Date
    let lastSeen: Date
}
