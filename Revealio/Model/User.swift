//
//  User.swift
//  Revealio
//
//  Created by hanif hussain on 01/01/2025.
//
import UIKit
// Models/User.swift
struct User: Codable {
    let id: String?
    let displayName: String
    var photoURL: String?
    let createdAt: Date
    let lastSeen: Date
    let phoneNumber: String
}
