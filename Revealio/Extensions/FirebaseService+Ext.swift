//
//  FirebaseService+Ext.swift
//  Revealio
//
//  Created by hanif hussain on 01/05/2025.
//
import UIKit

extension FirebaseService {
    // Create a safe filename from URL string
    func createSafeFilename(from urlString: String) -> String {
        // Get the last path component if possible
        if let url = URL(string: urlString), let lastPathComponent = url.pathComponents.last {
            // Clean up the last component in case it has query parameters
            let cleanComponent = lastPathComponent.components(separatedBy: "?").first ?? lastPathComponent
            // Create a unique string by combining the last path component with a hash of the full URL
            let urlHash = String(urlString.hash)
            return "image_\(cleanComponent)_\(urlHash).jpg"
        }

        // Fallback: Use URL hash only
        return "image_\(urlString.hash).jpg"
    }

    // Save image to disk
    func saveImageToDisk(_ image: UIImage, withFilename filename: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) ?? image.pngData() else {
            print("Could not get image data")
            return
        }

        let fileManager = FileManager.default
        guard let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("Could not access caches directory")
            return
        }

        let cacheDirectory = cachesDirectory.appendingPathComponent(StorageLocationPath.cacheDirectoryName.rawValue)

        // Create cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Created cache directory at: \(cacheDirectory.path)")
            } catch {
                print("Error creating cache directory: \(error.localizedDescription)")
                return
            }
        }

        let fileURL = cacheDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL, options: .atomic)
            print("Successfully saved image to: \(fileURL.path)")
        } catch {
            print("Error saving to disk: \(error.localizedDescription)")
        }
    }

    // Load image from disk
    func loadImageFromDisk(withFilename filename: String) -> UIImage? {
        let fileManager = FileManager.default
        guard let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }

        let cacheDirectory = cachesDirectory.appendingPathComponent(StorageLocationPath.cacheDirectoryName.rawValue)
        let fileURL = cacheDirectory.appendingPathComponent(filename)

        if !fileManager.fileExists(atPath: fileURL.path) {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Error loading from disk: \(error.localizedDescription)")
            return nil
        }
    }

    // Get documents directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

