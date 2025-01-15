//
//  MotionManager.swift
//  ScratchCard
//
//  Created by Anup D'Souza on 01/09/24.
//  🕸️ https://www.anupdsouza.com
//  🔗 https://twitter.com/swift_odyssey
//  👨🏻‍💻 https://github.com/anupdsouza
//  ☕️ https://www.buymeacoffee.com/adsouza
//  🫶🏼 https://patreon.com/adsouza
//

import Foundation
import CoreMotion
import SwiftUI

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published private(set) var x = 0.0
    @Published private(set) var y = 0.0
    @Published var isActive: Bool = false {
        didSet {
            if isActive {
                startMotionUpdates()
            } else {
                stopMotionUpdates()
            }
        }
    }
    
    private func startMotionUpdates() {
        motionManager.deviceMotionUpdateInterval = 1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let motion = data?.attitude else { return }
            self?.x = motion.yaw
            // motion on y axis
            //self?.y = motion.pitch
        }
    }
    
    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
        x = 0
        y = 0
    }
}
