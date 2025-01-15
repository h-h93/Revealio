//
//  RVScratchView.swift
//  Revealio
//
//  Created by hanif hussain on 12/12/2024.
//
import UIKit
import SwiftUI

protocol RVScratchViewDelegate: AnyObject {
    func didTapRandomiseButton()
}

struct RVScratchView: View {
    @State private var points = [CGPoint]()
    private var image: Image!
    @State private var clearScratchArea = false
    private let lineWidth: CGFloat = 80
    private var scratchFrame: CGRect!
    private let gridSize = 5
    private let gridCellSize = 40
    private let scratchClearAmount: CGFloat = 0.80 // 80%
    @StateObject private var motionManager = MotionManager()
    @State private var scratchViewColor = Color.random
    @State private var hiddenViewColor = Color.random
    @State var selection = 1
    weak var delegate: RVScratchViewDelegate?
    
    init (frame: CGRect, image: Image?) {
        self.scratchFrame = frame
        self.image = image ?? Image(systemName: "questionmark.circle")
    }
    
    var body: some View {
        ZStack {
            // Scratch view
            RoundedRectangle(cornerRadius: 20)
                .fill(scratchViewColor)
                .frame(width: scratchFrame.width, height: scratchFrame.height)
                .overlay {
                    Image(systemName: "drop.degreesign")
                        .resizable()
                        .scaledToFit()
                        .frame(width: scratchFrame.width - 50)
                }
                .animation(.easeInOut, value: clearScratchArea)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .compositingGroup()
                .shadow(color: .black, radius: 5)
                .opacity(clearScratchArea ? 0 : 1)
            
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
                .rotation3DEffect(.degrees(motionManager.x * 2.5), axis: (x: 0, y: 5, z: 5))
            // Uncomment below if we want to add motion on y axis
            //.rotation3DEffect(.degrees(motionManager.y * 5), axis: (x: -1, y: 0, z: 0))
        }
        
        Button(action: {
            selection += 1
            print(selection)
        },
               label: {
            Text("Next")
                .font(.title2)
                .bold()
                .foregroundStyle(.indigo)
                .frame(width: 220)
                .padding(.vertical, 10)
        })
        .buttonStyle(.borderedProminent)
        .tint(.white)
        .overlay {
            Capsule().stroke(Color.black, lineWidth: 1.0)
                .padding(3)
                .overlay {
                    Capsule().stroke(Color.black, lineWidth: 5.0)
                }
        }
        .clipShape(Capsule())
        .padding(.vertical, 20)
        .onChange(of: selection) { value, _ in
            scratchViewColor = Color.random
            hiddenViewColor = Color.random
            points = []
            clearScratchArea = false
        }
        
    }

}
