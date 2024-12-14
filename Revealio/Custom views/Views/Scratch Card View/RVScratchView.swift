//
//  RVScratchView.swift
//  Revealio
//
//  Created by hanif hussain on 12/12/2024.
//
import UIKit
import SwiftUI

struct RVScratchView: View {
    @State private var points = [CGPoint]()
    @State private var image = Image(systemName: "heart")
    @State private var clearScratchArea = false
    private let lineWidth: CGFloat = 80
    private let scratchFrame = CGRect(x: 0, y: 0, width: 350, height: 400)
    private let gridSize = 5
    private let gridCellSize = 50
    private let scratchClearAmount: CGFloat = 0.5 // 50%
    @StateObject private var motionManager = MotionManager()
    private var scratchViewColor = Color.random
    private var hiddenViewColor = Color.random
    
    init (image: Image?) {
        self.image = image ?? Image.init(systemName: "heart")
    }
    
    var body: some View {
        ZStack {
            // Scratch view
            RoundedRectangle(cornerRadius: 20)
                .fill(scratchViewColor)
                .frame(width: scratchFrame.width, height: scratchFrame.height)
                .animation(.easeInOut, value: clearScratchArea)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .compositingGroup()
                .shadow(color: .black, radius: 5)
                .opacity(clearScratchArea ? 0 : 1)
            
            // partial reveal view
            // MARK: Partial REVEAL view
            RoundedRectangle(cornerRadius: 20)
                .fill(hiddenViewColor)
                .frame(width: scratchFrame.width, height: scratchFrame.height)
                .overlay {
                    self.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: scratchFrame.width - 50)
                }
                .mask(
                    Path { path in
                        path.addLines(points)
                    }.stroke(style: StrokeStyle(lineWidth: 50, lineCap: .round, lineJoin: .round))
                )
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged({ value in
                            points.append(value.location)
                        })
                        .onEnded { _ in
                            // Create a CGPath from the drawn points
                            let cgpath = Path { path in
                                path.addLines(points)
                            }.cgPath
                            
                            // Thicken the path to match the stroke width
                            let thickenedPath = cgpath.copy(strokingWithWidth: 50, lineCap: .round, lineJoin: .round, miterLimit: 10)
                            
                            var scratchedCount = 0
                            
                            // Check if each grid cell's center point is within the thickened path
                            for i in 0..<gridSize {
                                for j in 0..<gridSize {
                                    let point = CGPoint(x: gridCellSize / 2 + i * gridCellSize, y: gridCellSize / 2 + j * gridCellSize)
                                    if thickenedPath.contains(point) {
                                        scratchedCount += 1
                                    }
                                }
                            }
                            
                            // Calculate the percentage of scratched cells
                            let scratchedPercentage = Double(scratchedCount) / Double(gridSize * gridSize)
                            
                            // If scratched area exceeds the threshold, clear the top view
                            if scratchedPercentage > scratchClearAmount {
                                clearScratchArea = true
                                motionManager.isActive = true
                            }
                        }
                )
                .opacity(clearScratchArea ? 0 : 1)
            
            
            // MARK: Full REVEAL view
            RoundedRectangle(cornerRadius: 20)
                .fill(hiddenViewColor)
                .frame(width: scratchFrame.width, height: scratchFrame.height)
                .overlay {
                    self.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: scratchFrame.width - 50)
                }
                .compositingGroup()
                .shadow(color: .black, radius: 5)
                .opacity(clearScratchArea ? 1 : 0)
                .rotation3DEffect(.degrees(motionManager.x * 10), axis: (x: 0, y: 1, z: 0))
                .rotation3DEffect(.degrees(motionManager.y * 10), axis: (x: -1, y: 0, z: 0))
            
                .padding()
        }
    }
    
}
