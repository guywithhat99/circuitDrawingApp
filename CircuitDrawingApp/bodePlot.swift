//
//  bodePlot.swift
//  CircuitDrawingApp
//
//  Created by Jack Miller on 3/1/25.
//

import SwiftUI
import Charts

// Define your data model for frequency response
struct FrequencyResponse: Identifiable {
    let id = UUID()
    let frequency: Double   // Frequency in Hz
    let magnitude: Double   // Magnitude in dB
    let phase: Double       // Phase in degrees
}

// Sample data for the Bode plot
let sampleData: [FrequencyResponse] = [
    FrequencyResponse(frequency: 10, magnitude: -20, phase: -45),
    FrequencyResponse(frequency: 20, magnitude: -15, phase: -40),
    FrequencyResponse(frequency: 50, magnitude: -10, phase: -35),
    FrequencyResponse(frequency: 100, magnitude: -5, phase: -30),
    FrequencyResponse(frequency: 200, magnitude: 0, phase: -20),
    FrequencyResponse(frequency: 500, magnitude: 5, phase: -10),
    FrequencyResponse(frequency: 1000, magnitude: 10, phase: 0)
]

struct BodePlotView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Magnitude Plot
                VStack(alignment: .leading) {
                    Text("Magnitude Plot (dB)")
                        .font(.headline)
                    Chart {
                        ForEach(sampleData) { point in
                            // Use log10(frequency) to plot on a logarithmic scale.
                            LineMark(
                                x: .value("Frequency", log10(point.frequency)),
                                y: .value("Magnitude", point.magnitude)
                            )
                            .symbol(Circle())
                        }
                    }
                    .chartXAxis {
                        // Customize the x-axis to show the original frequency values.
                        AxisMarks(values: .automatic(desiredCount: 5)) { value in
                            if let logValue = value.as(Double.self) {
                                let frequency = pow(10, logValue)
                                AxisValueLabel(String(format: "%.0f", frequency))
                            }
                        }
                    }
                    .frame(height: 200)
                }
                
                // Phase Plot
                VStack(alignment: .leading) {
                    Text("Phase Plot (°)")
                        .font(.headline)
                    Chart {
                        ForEach(sampleData) { point in
                            LineMark(
                                x: .value("Frequency", log10(point.frequency)),
                                y: .value("Phase", point.phase)
                            )
                            .symbol(Circle())
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 5)) { value in
                            if let logValue = value.as(Double.self) {
                                let frequency = pow(10, logValue)
                                AxisValueLabel(String(format: "%.0f", frequency))
                            }
                        }
                    }
                    .frame(height: 200)
                }
            }
            .padding()
        }
    }
}

struct BodePlotView_Previews: PreviewProvider {
    static var previews: some View {
        BodePlotView()
    }
}
