import SwiftUI
import PencilKit
import Vision
import CoreML

struct ContentView: View {
    // Core drawing state
    @State private var canvasView = PKCanvasView()
    @State private var showToolPicker: Bool = true
    @State private var isProcessing: Bool = false
    @State private var processedImage: UIImage? = nil
    
    // For development/debugging
    @State private var showDebugView: Bool = false
    
    var body: some View {
        ZStack {
        // Drawing canvas area
        CanvasViewWrapper(canvasView: $canvasView, showToolPicker: $showToolPicker)
            .edgesIgnoringSafeArea([.horizontal, .top])
        
            VStack(spacing: 0) {
                
                
                // Toggle button for showing/hiding the tool picker
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showToolPicker.toggle()
                        }) {
                            Image(systemName: showToolPicker ? "pencil.slash" : "pencil")
                                .font(.title)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        .padding()
                        Button(action: {
                            processDrawing()
                        }) {
                            Image(systemName: "wand.and.stars")
                                .font(.title)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        
                        .padding()
                        Button(action: {
                            showDebugView.toggle()
                        }) {
                            Image(systemName: "ladybug")
                                .font(.title2)
                                .frame(width: 44, height: 44)
                            
                        }
                        
                        .padding()
                        
                    }
                    
                }
            }
            
            // Debug overlay when enabled
            if showDebugView && processedImage != nil {
                ZStack {
                    Color.black.opacity(0.7)
                    
                    VStack {
                        Text("AI Processing Preview")
                            .font(.headline)
                            .foregroundColor(.white)
                        Button("Close") {
                            showDebugView = false
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        if let image = processedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        
                    }
                    .padding()
                    .frame(maxWidth: 500)
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    // Process the drawing for AI analysis
    private func processDrawing() {
        isProcessing = true
        
        // Create DrawingProcessor instance and process the drawing
        let processor = DrawingProcessor()
        
        // Process asynchronously to not block UI
        DispatchQueue.global(qos: .userInitiated).async {
            if let processedImage = processor.processForAIAnalysis(drawing: canvasView.drawing) {
                // Return to main thread to update UI
                DispatchQueue.main.async {
                    self.processedImage = processedImage
                    self.isProcessing = false
                    
                    // Show debug view automatically if enabled
                    if self.showDebugView == false {
                        self.showDebugView = true
                    }
                    
                    // In a production app, you would proceed to AI analysis here
                    // analyzeCircuit(processedImage: processedImage)
                }
            } else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    // Handle error - could display an alert
                }
            }
        }
    }
}

// Bridge between SwiftUI and UIKit for PencilKit
struct CanvasViewWrapper: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var showToolPicker: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        // Set up the canvas view optimized for circuit drawing
        canvasView.backgroundColor = .white
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        
        // Configure for circuit drawing - thinner lines work better for circuits
        let ink = PKToolPickerInkingItem.init(type:PKInkingTool.InkType.pen, color: .black, width: 1)
        let eraser = PKToolPickerEraserItem.init(type: PKEraserTool.EraserType.vector)
        
        // Optional: Add grid for better circuit alignment
        //canvasView.backgroundColor = UIColor(patternImage: createGridPattern())
        
        // Set up the tool picker
        let inkTool = PKInkingTool(.pen)
        let toolPicker = PKToolPicker(toolItems: [ink, eraser])
        toolPicker.setVisible(showToolPicker, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        
        // Restrict tools to those most useful for circuit drawing
        toolPicker.selectedToolItem = ink as PKToolPickerItem
        
        // Make canvas first responder to show the tool picker
        canvasView.becomeFirstResponder()
        context.coordinator.toolPicker = toolPicker
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update tool picker visibility when state changes
        if let toolPicker = context.coordinator.toolPicker {
            toolPicker.setVisible(showToolPicker, forFirstResponder: uiView)
            
            // Ensure canvas is first responder when we want to show picker
            if showToolPicker && !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            }
        }
    }
    
    // Create a subtle grid pattern to help with drawing circuits
    private func createGridPattern() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let pattern = renderer.image { context in
            UIColor.lightGray.withAlphaComponent(0.2).setStroke()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: size.height))
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.move(to: CGPoint(x: size.width, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.lineWidth = 0.5
            path.stroke()
        }
        
        return pattern
    }
    
    // Coordinator class for delegation and communication
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasViewWrapper
        var toolPicker: PKToolPicker?
        
        init(_ parent: CanvasViewWrapper) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Can be used to track changes and update state if needed
        }
    }
}

// Handles processing the PKDrawing for AI analysis
class DrawingProcessor {
    
    // Process a PKDrawing to make it suitable for AI analysis
    func processForAIAnalysis(drawing: PKDrawing) -> UIImage? {
        // Step 1: Convert PKDrawing to UIImage
        let imageSize = CGSize(width: 768, height: 768) // Standard size for many ML models
        let drawingImage = drawing.image(from: drawing.bounds, scale: 1.0)
        
        // Step 2: Apply preprocessing that helps ML models analyze circuits
        guard let processedImage = applyCircuitOptimization(to: drawingImage, targetSize: imageSize) else {
            return nil
        }
        
        return processedImage
    }
    
    // Apply optimizations specifically for circuit recognition
    private func applyCircuitOptimization(to image: UIImage, targetSize: CGSize) -> UIImage? {
        // Create a CIImage from the UIImage
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let context = CIContext()
        
        // Step 1: Enhance contrast and remove noise
        var processedImage = ciImage
        
        // Apply a contrast filter to make lines more distinct
        if let contrastFilter = CIFilter(name: "CIColorControls") {
            contrastFilter.setValue(processedImage, forKey: kCIInputImageKey)
            contrastFilter.setValue(1.1, forKey: kCIInputContrastKey) // Slightly boost contrast
            contrastFilter.setValue(0.0, forKey: kCIInputBrightnessKey) // Keep original brightness
            
            if let outputImage = contrastFilter.outputImage {
                processedImage = outputImage
            }
        }
        
        // Step 2: Apply edge detection to highlight circuit lines
        if let edgesFilter = CIFilter(name: "CIEdges") {
            edgesFilter.setValue(processedImage, forKey: kCIInputImageKey)
            edgesFilter.setValue(1.0, forKey: kCIInputIntensityKey) // Default intensity
            
            if let edgeImage = edgesFilter.outputImage {
                // Blend the edge detection with original for better results
                if let blendFilter = CIFilter(name: "CIMultiplyBlendMode") {
                    blendFilter.setValue(edgeImage, forKey: kCIInputImageKey)
                    blendFilter.setValue(processedImage, forKey: kCIInputBackgroundImageKey)
                    
                    if let blendedImage = blendFilter.outputImage {
                        processedImage = blendedImage
                    }
                }
            }
        }
        
        // Step 3: Normalize and resize for AI processing
        let transform = CGAffineTransform(
            scaleX: targetSize.width / processedImage.extent.width,
            y: targetSize.height / processedImage.extent.height
        )
        processedImage = processedImage.transformed(by: transform)
        
        // Convert back to UIImage
        guard let cgImage = context.createCGImage(processedImage, from: processedImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // Additional methods that would be used in the full app:
    
    // Detect circuit components using Vision framework (placeholder)
    func detectCircuitComponents(in image: UIImage) -> [CircuitComponent]? {
        // This would use Vision framework for initial detection
        // For a full implementation, you would create a Core ML model
        return []
    }
}

// Model for representing circuit components (placeholder)
struct CircuitComponent {
    enum ComponentType {
        case resistor, capacitor, diode, transistor, wire, junction, unknown
    }
    
    let type: ComponentType
    let boundingBox: CGRect
    let confidence: Float
}

@main
struct CircuitDrawingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
