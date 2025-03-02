//
//  drawingWithGraphs.swift
//  CircuitDrawingApp
//
//  Created by Jack Miller on 3/1/25.
//
import SwiftUI

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        )
    }
}


struct drawAndGraphView: View {
    @State private var showGraph = false
    
    let desmosView = DesmosView(htmlFileName: "desmos")
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            drawView()
            
            if showGraph {
                DesmosView(htmlFileName: "desmos")
                    .frame(width: 500, height: 500)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .transition(.moveAndFade)
                    .padding([.top, .trailing], 20)
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showGraph.toggle()
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .padding()
                    }
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .padding()
                }
            }
        }
        
    }
}
