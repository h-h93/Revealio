//
//  RVScratchView.swift
//  Revealio
//
//  Created by hanif hussain on 12/12/2024.
//
import UIKit
import SwiftUI
import Lottie

protocol RVScratchViewDelegate: AnyObject {
    func didTapRandomiseButton()
}


@MainActor
class RVScratchViewModel: ObservableObject {
    @Published var vibes: [Vibes] = []
    @Published var images: [Image] = []
    @Published var isEmpty = true
    @Published var isLoading = false

    func loadVibesAndImages() async {
        // Only load if we haven't already loaded
        guard images.isEmpty && !isLoading else { return }

        isLoading = true

        do {
            // Get vibes in the background
            let newVibes = try await FirebaseService.shared.getVibes()

            self.vibes = newVibes

            // If we have vibes, download images in parallel
            if !newVibes.isEmpty {
                var downloadedImages = [Image]()

                await withTaskGroup(of: (Int, UIImage?).self) { group in
                    for (index, vibe) in newVibes.enumerated() {
                        group.addTask {
                            let uiImage = await FirebaseService.shared.getImages(urlString: vibe.location)
                            return (index, uiImage)
                        }
                    }

                    // Collect results - we need a better way to organize since we removed the placeholder array
                    var results = [(Int, UIImage)]()

                    for await (index, uiImage) in group {
                        if let uiImage = uiImage {
                            results.append((index, uiImage))
                        }
                    }

                    // Sort by index to maintain order
                    results.sort { $0.0 < $1.0 }

                    // Then convert to images
                    downloadedImages = results.map { Image(uiImage: $1) }
                }

                self.images = downloadedImages
                self.isEmpty = self.images.isEmpty
            }
        } catch {
            print("Error loading vibes: \(error)")
            self.isEmpty = true
        }

        isLoading = false
    }
}


struct RVScratchView: View {
    @StateObject private var viewModel = RVScratchViewModel()
    @State private var strokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []
    @State private var points = [CGPoint]()
    @State private var clearScratchArea = false
    private let lineWidth: CGFloat = 80
    private var scratchFrame: CGRect
    private let gridSize = 5
    private let gridCellSize = 40
    private let scratchClearAmount: CGFloat = 0.70
    @StateObject private var motionManager = MotionManager()
    @State private var borderColor = Color.clear
    @State private var hiddenViewColor = Color.clear
    @State private var selection = 0
    weak var delegate: RVScratchViewDelegate?


    init (frame: CGRect) {
        self.scratchFrame = frame
    }

    var body: some View {
        ZStack {
            // Scratch view
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.clear)
                .border(Color.blue, width: 2)
                .frame(width: scratchFrame.width, height: scratchFrame.height)
                .overlay {
                    LottieView(animation: .named("vibeAnimation"))
                        .playing(loopMode: .loop)
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
                    if !viewModel.isEmpty && !viewModel.images.isEmpty {
                        let safeIndex = min(selection, max(0, viewModel.images.count - 1))
                        viewModel.images[safeIndex]
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: scratchFrame.width, height: scratchFrame.height)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    } else {
                        // Use Color.white with zero opacity instead of Color.clear
                        Color.primary.opacity(0.60)
                            .frame(width: scratchFrame.width, height: scratchFrame.height)
                            .clipShape(RoundedRectangle(cornerRadius: 20))

                    }
                }
                .mask(
                    ZStack {
                        // Draw all completed strokes
                        ForEach(0..<strokes.count, id: \.self) { strokeIndex in
                            Path { path in
                                let strokePoints = strokes[strokeIndex]
                                if !strokePoints.isEmpty {
                                    path.move(to: strokePoints[0])
                                    for point in strokePoints.dropFirst() {
                                        path.addLine(to: point)
                                    }
                                }
                            }.stroke(style: StrokeStyle(lineWidth: 50, lineCap: .round, lineJoin: .round))
                        }

                        // Draw the current in-progress stroke
                        Path { path in
                            if !currentStroke.isEmpty {
                                path.move(to: currentStroke[0])
                                for point in currentStroke.dropFirst() {
                                    path.addLine(to: point)
                                }
                            }
                        }.stroke(style: StrokeStyle(lineWidth: 50, lineCap: .round, lineJoin: .round))
                    }
                )
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged({ value in
                            if currentStroke.isEmpty {
                                // Beginning a new stroke
                                currentStroke = [value.location]
                            } else {
                                currentStroke.append(value.location)
                            }
                        })
                        .onEnded { _ in
                            // Add the completed stroke to our array of strokes
                            strokes.append(currentStroke)

                            // Create a combined path from all strokes
                            let combinedPath = Path { path in
                                for stroke in strokes {
                                    if !stroke.isEmpty {
                                        path.move(to: stroke[0])
                                        for point in stroke.dropFirst() {
                                            path.addLine(to: point)
                                        }
                                    }
                                }
                            }.cgPath

                            // Thicken the path to match the stroke width
                            let thickenedPath = combinedPath.copy(strokingWithWidth: 50, lineCap: .round, lineJoin: .round, miterLimit: 10)

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

                            // Clear current stroke after processing
                            currentStroke = []
                        }
                )
                .opacity(clearScratchArea ? 0 : 1)

            // MARK: Full REVEAL view
            RoundedRectangle(cornerRadius: 20)
                .fill(hiddenViewColor)
                .frame(width: scratchFrame.width, height: scratchFrame.height)
                .overlay {
                    if viewModel.isEmpty || viewModel.images.isEmpty {
                        VStack {
                            LottieView(animation: .named("noVibesImageAnimation"))
                                .playing(loopMode: .loop)
                                .resizable()
                                .scaledToFit()
                                .frame(width: scratchFrame.width - 50)
                            Text("Nothing to see here...😢")
                                .font(.title).fontWeight(.bold)
                                .foregroundStyle(.foreground)
                            Text("Send someone a vibe!")
                                .font(.headline).fontWeight(.heavy)
                                .foregroundStyle(.foreground)
                        }
                    } else {
                        let safeIndex = min(selection, max(0, viewModel.images.count - 1))
                        viewModel.images[safeIndex]
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: scratchFrame.width, height: scratchFrame.height)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .compositingGroup()
                .shadow(color: .black, radius: 5)
                .opacity(clearScratchArea ? 1 : 0)
                .rotation3DEffect(.degrees(motionManager.x * 2.5), axis: (x: 0, y: 5, z: 5))
            // Uncomment below if we want to add motion on y axis
            //.rotation3DEffect(.degrees(motionManager.y * 5), axis: (x: -1, y: 0, z: 0))
        }

        Button(action: {
            // Add bounds checking for next button
            if !viewModel.images.isEmpty && selection < viewModel.images.count - 1 {
                selection += 1
            } else {
                selection = 0
            }
            print("Selection: \(selection), Images: \(viewModel.images.count)")
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
            hiddenViewColor = Color.clear
            points = []
            strokes = []  // Add this
            currentStroke = []  // Add this
            clearScratchArea = false
        }
        .onAppear {
            Task(priority: .background) {
                await viewModel.loadVibesAndImages()
            }
        }

    }
}
