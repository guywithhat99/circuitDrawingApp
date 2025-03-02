//
//  desmosWebView.swift
//  CircuitDrawingApp
//
//  Created by Jack Miller on 3/1/25.
//

import SwiftUI
import WebKit

struct DesmosView: UIViewRepresentable {
    let htmlFileName: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = Bundle.main.url(forResource: htmlFileName, withExtension: "html") {
            uiView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
}
