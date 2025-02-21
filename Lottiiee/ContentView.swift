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
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("收到消息:", message.body)
            guard let dict = message.body as? [String: Any] else { 
                print("消息格式错误")
                return 
            }
            
            print("消息内容:", dict)
            
            switch message.name {
            case "nativeAction":
                if let action = dict["action"] as? String {
                    print("执行动作:", action)
                    handleNativeAction(action, params: dict["params"])
                }
            default:
                print("未知的消息名称:", message.name)
                break
            }
        }
        
        private func handleNativeAction(_ action: String, params: Any?) {
            // 处理具体的原生动作
            switch action {
            case "showAlert":
                if let message = (params as? [String: String])?["message"] {
                    DispatchQueue.main.async {
                        // 显示系统弹窗
                        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                    }
                }
            default:
                break
            }
        }
        
        // 添加导航委托方法
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("页面加载完成")
            // 修改检查方式
            webView.evaluateJavaScript("typeof window.Bridge !== 'undefined'", completionHandler: { result, error in
                if let error = error {
                    print("检查Bridge时出错:", error)
                } else {
                    print("Bridge是否存在:", result as? Bool ?? false)
                }
            })
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("页面加载失败:", error)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // 添加日志
        print("正在初始化WebView配置")
        
        userContentController.add(context.coordinator, name: "nativeAction")
        
        let bridge = """
            console.log('正在注入Bridge');
            
            window.Bridge = {
                showAlert: function(message) {
                    console.log('调用showAlert:', message);
                    window.webkit.messageHandlers.nativeAction.postMessage({
                        action: 'showAlert',
                        params: { message: message }
                    });
                }
            };
            console.log('Bridge注入完成');
        """
        
        let script = WKUserScript(source: bridge, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        userContentController.addUserScript(script)
        
        config.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isInspectable = true
        // 添加导航委托来监控页面加载
        webView.navigationDelegate = context.coordinator
        
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
//        if let url = Bundle.main.url(forResource: htmlFileName, withExtension: "html", subdirectory: "build") {
//            print("找到HTML文件:", url)
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
