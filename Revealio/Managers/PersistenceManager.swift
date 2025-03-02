//
//  PersistenceManager.swift
//  Revealio
//
//  Created by hanif hussain on 08/01/2025.
//
import UIKit
import Contacts

enum PersistanceActionType {
    case add, remove
}


enum PersistenceManager {
    static let defaults = UserDefaults.standard
    
    static func save(_ value: Any, forKey key: String) { defaults.setValue(value, forKey: key) }
    
    static func remove(forKey key: String) { defaults.removeObject(forKey: key) }
    
    static func retrieveContacts(saveFileName: String) -> [CNContact]? { return defaults.object(forKey: saveFileName) as? [CNContact] }
}
