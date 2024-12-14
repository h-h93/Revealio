//
//  Constants.swift
//  Revealio
//
//  Created by hanif hussain on 01/12/2024.
//
import UIKit

enum DeviceTypes {
    static let idiom = UIDevice.current.userInterfaceIdiom
    static let nativeScale = UIScreen.main.nativeScale
    static let scale = UIScreen.main.scale
    
    // Check based on screen size and resolution
    static let isiPhoneSE = idiom == .phone && UIScreen.main.bounds.size.height == 568.0
    static let isiPhone8Standard = idiom == .phone && UIScreen.main.bounds.size.height == 667.0 && scale == nativeScale
    static let isiPhone8Zoomed = idiom == .phone && UIScreen.main.bounds.size.height == 667.0 && scale > nativeScale
    static let isiPhone8PlusStandard = idiom == .phone && UIScreen.main.bounds.size.height == 736.0 && scale == nativeScale
    static let isiPhone8PlusZoomed = idiom == .phone && UIScreen.main.bounds.size.height == 736.0 && scale > nativeScale
    static let isiPhoneX = idiom == .phone && UIScreen.main.bounds.size.height == 812.0
    static let isiPhoneXsMaxAndXr = idiom == .phone && UIScreen.main.bounds.size.height == 896.0
    static let isiPhone12 = idiom == .phone && UIScreen.main.bounds.size.height == 844.0
    static let isiPhone13 = idiom == .phone && UIScreen.main.bounds.size.height == 926.0
    static let isiPhone14 = idiom == .phone && UIScreen.main.bounds.size.height == 926.0
    static let isiPhone15 = idiom == .phone && UIScreen.main.bounds.size.height == 1080.0
    static let isiPad = idiom == .pad && UIScreen.main.bounds.size.height >= 1024.0
    
    // Zoomed detection for devices that can have different display modes
    static func isZoomed() -> Bool {
        return scale > nativeScale
    }
    
    
    // Convenience method for checking zoomed mode for specific devices
    static func isZoomedForiPhone8Plus() -> Bool {
        return isiPhone8PlusStandard && isZoomed()
    }
    
    
    static func isZoomedForiPhone8() -> Bool {
        return isiPhone8Standard && isZoomed()
    }
}


enum Images {
    static let homeTabImage = UIImage(systemName: "house")
}
