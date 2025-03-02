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
    @State private var speed: CGFloat = 10
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
                        .padding()
                        Menu {
                            List(AnalysisType.allCases, id: \.self) { type in
                                        
                                Button(action: {
                                    processDrawing()
                                }) {
                                    Image(systemName: "wand.and.stars")
                                        .font(.title)
                                        .padding()
                                        .background(Color.white.opacity(0.8))
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                    Text(type.rawValue)
                                }

                                    }
                            // Add more options as needed
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(radius: 3)
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

enum AnalysisType: String, CaseIterable {
    case Transient = "Transient"
    case AC = "AC"
    case DC = "DC"
}
