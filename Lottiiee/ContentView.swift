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
    
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var parent: WebView
        // 添加 webView 属性以便在 Coordinator 中访问
        weak var webView: WKWebView?
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("收到Web消息:", message.body)
            if message.name == "bridge" {
                if let messageBody = message.body as? [String: Any] {
                    let action = messageBody["action"] as? String
                    let data = messageBody["data"] as? [String: Any]
                    let callbackId = messageBody["callbackId"] as? String
                    
                    // 处理来自 React 的调用
                    handleReactAction(action: action, data: data, callbackId: callbackId)
                }
            }
        }
        // 处理具体的 React 调用
        func handleReactAction(action: String?, data: [String: Any]?, callbackId: String?) {
            switch action {
            case "callSwiftFunction":
                if let value = data?["value"] as? String {
                    print("Received from React: \(value)")
                    
                    // 回调 JavaScript
                    if let callbackId = callbackId {
                        sendResponseToReact(callbackId: callbackId, message: "Swift received: \(value)")
                    }
                }
            default:
                print("Unknown action: \(action ?? "")")
            }
        }
        
        // 向 React 发送回调
        func sendResponseToReact(callbackId: String, message: String) {
            let script = """
                        window.bridge.callbacks["\(callbackId)"]("\(message)");
                        delete window.bridge.callbacks["\(callbackId)"];
                    """
            webView?.evaluateJavaScript(script, completionHandler: {
                if let err = $1 {
                    print("callback failed: \(err.localizedDescription)")
                } else {
                    print("callback complete")
                }
            })
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = config.userContentController
        
        // 注入消息处理器
        contentController.add(context.coordinator, name: "bridge")
        
        // 创建 WKWebView
        let webView = WKWebView(frame: .zero, configuration: config)
        context.coordinator.webView = webView
        webView.isInspectable = true
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        //        if let url = Bundle.main.url(forResource: htmlFileName, withExtension: "html", subdirectory: "build") {
        //            print("加载HTML文件:", url)
        //            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        //        } else {
        //            print("错误: 未找到HTML文件")
        //        }
        webView.load(URLRequest(url: URL(string: "http://localhost:3000/")!))
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
