//
// Copyright © 2025 .
// All Rights Reserved.
import Foundation

extension Data {
    var fileExtension: String {
        guard !isEmpty else { return "unknown" }

        // Check file signatures (magic numbers)
        switch self[0] {
        case 0xFF:
            return "jpg"
        case 0x89:
            return "png"
        case 0x47:
            // Check if it's GIF (starts with "GIF")
            if count >= 3 && self[0] == 0x47 && self[1] == 0x49 && self[2] == 0x46 {
                return "gif"
            }
            return "unknown"
        case 0x52:
            // Check for WebP (RIFF...WEBP)
            if count >= 12 {
                let riffSignature = Array(self[0..<4])
                let webpSignature = Array(self[8..<12])
                if riffSignature == [0x52, 0x49, 0x46, 0x46] &&
                    webpSignature == [0x57, 0x45, 0x42, 0x50] {
                    return "webp"
                }
            }
            return "unknown"
        case 0x00:
            // Check for MP4 (....ftyp)
            if count >= 8 {
                let ftypSignature = Array(self[4..<8])
                if ftypSignature == [0x66, 0x74, 0x79, 0x70] {
                    return "mp4"
                }
            }
            return "unknown"
        default:
            // Check for other video formats
            if count >= 4 {
                // AVI files start with "RIFF" and contain "AVI "
                if Array(self[0..<4]) == [0x52, 0x49, 0x46, 0x46] && count >= 11 {
                    let aviSignature = Array(self[8..<11])
                    if aviSignature == [0x41, 0x56, 0x49] {
                        return "avi"
                    }
                }

                // MOV/QuickTime files
                if count >= 8 && Array(self[4..<8]) == [0x66, 0x74, 0x79, 0x70] {
                    return "mov"
                }
            }
            return "unknown"
        }
    }
}

