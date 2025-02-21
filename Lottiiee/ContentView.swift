//
//  ContentView.swift
//  Lottiiee
//
//  Created by Yuri on 2025/2/21.
//

import SwiftUI
import UIKit
import WebKit

struct WebView: UIViewRepresentable {
    let htmlFileName: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isInspectable = true
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = Bundle.main.url(forResource: htmlFileName, withExtension: "html", subdirectory: "build") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
}

struct ContentView: View {
    var body: some View {
        WebView(htmlFileName: "index")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
