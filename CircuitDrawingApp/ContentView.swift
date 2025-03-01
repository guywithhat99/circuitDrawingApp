//
//  ContentView.swift
//  CircuitDrawingApp
//
//  Created by Jack Miller on 3/1/25.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    @State private var canvasView = PKCanvasView()
    @State private var showToolPicker: Bool = true
    
    var body: some View {
        ZStack {
            // Canvas for drawing
            CanvasViewWrapper(canvasView: $canvasView, showToolPicker: $showToolPicker)
                .edgesIgnoringSafeArea(.all)
            
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
                }
            }
        }
    }
}

struct CanvasViewWrapper: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var showToolPicker: Bool
    
    
    // For communication between UIKit and SwiftUI
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        // Set up the canvas view
        canvasView.backgroundColor = .white
        canvasView.drawingPolicy = .anyInput  // Allow input from both finger and Apple Pencil
        canvasView.delegate = context.coordinator
        
        // Set up the tool picker
        let pen = PKToolPickerInkingItem(__inkType: .pen,color: .blue, width: 10)
        let eraser = PKToolPickerEraserItem(type: PKEraserTool.EraserType.vector)
        let toolPicker = PKToolPicker(toolItems: [pen, eraser])
        toolPicker.setVisible(showToolPicker, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        
        // Make canvas the first responder to show the tool picker
        context.coordinator.toolPicker = toolPicker
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update tool picker visibility when the state changes
        if let toolPicker = context.coordinator.toolPicker {
            toolPicker.setVisible(showToolPicker, forFirstResponder: uiView)
            
            // Make sure the canvas is the first responder when we want to show the picker
            if showToolPicker && !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            }
        }
    }
    
    // Coordinator class to handle delegation and communication
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasViewWrapper
        var toolPicker: PKToolPicker?
        
        init(_ parent: CanvasViewWrapper) {
            self.parent = parent
        }
        
        // You can implement delegate methods here if needed
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Handle drawing changes if needed
        }
    }
}

@main
struct PencilKitDrawingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
