import UIKit

extension FirebaseService {
    // Create a safe filename from URL string - simplified
    func createSafeFilename(from urlString: String) -> String {
        guard let url = URL(string: urlString),
              let lastPathComponent = url.pathComponents.last else {
            return "image_\(urlString.hash).jpg"
        }

        let cleanComponent = lastPathComponent.components(separatedBy: "?").first ?? lastPathComponent
        return "image_\(cleanComponent)_\(urlString.hash).jpg"
    }

    // Save image to disk - streamlined error handling and file operations
    func saveImageToDisk(_ image: UIImage, withFilename filename: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) ?? image.pngData() else { return }

        do {
            let cacheDirectory = try getCacheDirectory()
            let fileURL = cacheDirectory.appendingPathComponent(filename)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Error saving image: \(error.localizedDescription)")
        }
    }

    // Load image from disk - simplified with better error handling
    func loadImageFromDisk(withFilename filename: String) -> UIImage? {
        do {
            let cacheDirectory = try getCacheDirectory()
            let fileURL = cacheDirectory.appendingPathComponent(filename)

            guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }

            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Error loading image: \(error.localizedDescription)")
            return nil
        }
    }

    // Helper method to get and create cache directory if needed
    private func getCacheDirectory() throws -> URL {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "FirebaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not access caches directory"])
        }

        let cacheDirectory = cachesDirectory.appendingPathComponent(StorageLocationPath.cacheDirectoryName.rawValue)

        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        return cacheDirectory
    }

    // Get documents directory - unchanged but kept for API consistency
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
