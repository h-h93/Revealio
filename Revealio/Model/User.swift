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
