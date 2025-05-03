////
////  MediaManager.swift
////  Revealio
////
////  Created by hanif hussain on 24/01/2025.
////
//import UIKit
//import AVFoundation
//
//// Helper enum for media content
//enum MediaContent {
//    case image(UIImage)
//    case video(URL)
//    
//    var type: MessageType {
//        switch self {
//        case .image: return .image
//        case .video: return .video
//        }
//    }
//}
//
//
//// Configuration
//struct Config {
//    static let maxImageSize = 1024 * 1024 * 5 // 5MB
//    static let maxVideoSize = 1024 * 1024 * 15 // 15MB
//    static let imageCompressionQuality: CGFloat = 0.7
//    static let maxRetries = 3
//    static let retryDelay: TimeInterval = 2
//}
//
//class MediaManager {
//    static let shared = MediaManager()
//
//    
//    
//    // MARK: - Media Compression
//    func compressImage(_ image: UIImage) throws -> Data {
//        var compression: CGFloat = Config.imageCompressionQuality
//        var data = image.jpegData(compressionQuality: compression)!
//        
//        while data.count > Config.maxImageSize && compression > 0.1 {
//            compression -= 0.1
//            if let compressedData = image.jpegData(compressionQuality: compression) {
//                data = compressedData
//            }
//        }
//        
//        if data.count > Config.maxImageSize {
//            throw MessageError.exceededSizeLimit(size: data.count, limit: Config.maxImageSize)
//        }
//        
//        return data
//    }
//    
//    
//    func compressVideo(url: URL) async throws -> URL {
//        let asset = AVURLAsset(url: url)
//        let duration = try await asset.load(.duration)
//        
//        // Check if compression is needed
//        let fileSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
//        if fileSize <= Config.maxVideoSize {
//            return url
//        }
//        
//        let composition = AVMutableComposition()
//        guard let compositionTrack = composition.addMutableTrack(
//            withMediaType: .video,
//            preferredTrackID: kCMPersistentTrackID_Invalid
//        ) else {
//            throw MessageError.compressionFailed
//        }
//        
//        let videoTrack = try await asset.loadTracks(withMediaType: .video).first
//        try compositionTrack.insertTimeRange(
//            CMTimeRange(start: .zero, duration: duration),
//            of: videoTrack!,
//            at: .zero
//        )
//        
//        let preset = AVAssetExportPresetMediumQuality
//        let outputURL = FileManager.default.temporaryDirectory
//            .appendingPathComponent(UUID().uuidString)
//            .appendingPathExtension("mp4")
//        
//        guard let exportSession = AVAssetExportSession(
//            asset: composition,
//            presetName: preset
//        ) else {
//            throw MessageError.compressionFailed
//        }
//        
//        exportSession.outputURL = outputURL
//        exportSession.outputFileType = .mp4
//        
//        await exportSession.export()
//        
//        guard exportSession.status == .completed else {
//            throw MessageError.compressionFailed
//        }
//        
//        return outputURL
//    }
//    
//    
//}
