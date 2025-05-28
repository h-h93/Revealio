//
//  PersistenceManager.swift
//  Revealio
//
//  Created by hanif hussain on 08/01/2025.
//
import UIKit
import Contacts
import WebKit

enum PersistanceActionType {
    case add, remove
}


enum PersistenceManager {
    static let defaults = UserDefaults.standard

    static var cache = NSCache<NSString, UIImage>()

    // Add media cache for WebView content
    static var mediaCache = NSCache<NSString, NSData>()

    static func save(_ value: Any, forKey key: String) { defaults.setValue(value, forKey: key) }
    
    static func remove(forKey key: String) { defaults.removeObject(forKey: key) }
    
    static func retrieveContacts(saveFileName: String) -> [CNContact]? { return defaults.object(forKey: saveFileName) as? [CNContact] }


    // MARK: - WebView Setup
    static func setupWebViewCache() {
        // Configure URLCache for WebView
        let memoryCapacity = 50 * 1024 * 1024  // 50 MB
        let diskCapacity = 100 * 1024 * 1024   // 100 MB
        URLCache.shared = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)

        // Configure media cache limits
        mediaCache.countLimit = 50
        mediaCache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }

    // MARK: - Media Cache
    static func cacheMedia(_ data: Data, forURL url: String) {
        let key = NSString(string: url)
        mediaCache.setObject(data as NSData, forKey: key, cost: data.count)
    }

    static func getCachedMedia(forURL url: String) -> Data? {
        let key = NSString(string: url)
        return mediaCache.object(forKey: key) as Data?
    }


    // MARK: - Cache Cleanup
    static func clearAllCache() {
        cache.removeAllObjects()
        mediaCache.removeAllObjects()
        URLCache.shared.removeAllCachedResponses()
    }

    static func clearWebViewCache() {
        let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: Date(timeIntervalSince1970: 0)) {
            print("WebView cache cleared")
        }
    }



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

            // Clear old WebView cache too
            if olderThanDays <= 7 {
                clearWebViewCache()
            }
            

            print("Deleted \(deletedCount) cache files older than \(olderThanDays) days")
        } catch {
            print("Error reading cache directory: \(error.localizedDescription)")
        }
    }
}
