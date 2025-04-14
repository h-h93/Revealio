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

    // Add this function to periodically clean up old cache files
    static func clearOldCacheFiles(olderThanDays: Int = 20) {
        let fileManager = FileManager.default
        guard let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("Could not access caches directory")
            return
        }

        let cacheDirectory = cachesDirectory.appendingPathComponent(StorageLocationPath.cacheDirectoryName.rawValue)

        // Check if directory exists
        guard fileManager.fileExists(atPath: cacheDirectory.path) else {
            print("Cache directory doesn't exist yet")
            return
        }

        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )

            let cutoffDate = Date().addingTimeInterval(-Double(olderThanDays) * 24 * 60 * 60)
            var deletedCount = 0

            for fileURL in fileURLs {
                do {
                    let attributes = try fileURL.resourceValues(forKeys: [.contentModificationDateKey])
                    if let modificationDate = attributes.contentModificationDate,
                       modificationDate < cutoffDate {
                        try fileManager.removeItem(at: fileURL)
                        deletedCount += 1
                    }
                } catch {
                    print("Error processing \(fileURL.lastPathComponent): \(error.localizedDescription)")
                }
            }

            print("Deleted \(deletedCount) cache files older than \(olderThanDays) days")
        } catch {
            print("Error reading cache directory: \(error.localizedDescription)")
        }
    }
}
