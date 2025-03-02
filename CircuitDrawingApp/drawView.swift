//
//  drawView.swift
//  CircuitDrawingApp
//
//  Created by Jack Miller on 3/1/25.
//

import SwiftUI
import PencilKit

struct drawView: View {
    @State private var canvasView = PKCanvasView()
    @State private var showToolPicker: Bool = true
    var body: some View {
        ZStack {
            // Drawing canvas area
            CanvasViewWrapper(canvasView: $canvasView, showToolPicker: $showToolPicker)
                .edgesIgnoringSafeArea([.horizontal, .top, .bottom, .leading])
        }
    }
}
