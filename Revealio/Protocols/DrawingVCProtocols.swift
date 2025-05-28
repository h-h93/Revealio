import UIKit
import PencilKit

protocol DrawingViewDelegate: AnyObject {
    func drawingDidChange(_ drawing: PKDrawing)
    func imagePlacedInCanvas()
    func drawingCleared()
}


protocol DrawingVCDelegate: AnyObject {
    func didFinishDrawing(with image: UIImage)
}


protocol ImagePlacementHandler: AnyObject {
    func placeImage(_ image: UIImage)
    func cancelImagePlacement()
}
