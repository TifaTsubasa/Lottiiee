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
    // 添加 webView 属性以便在 Coordinator 中访问
    private(set) weak var webView: WKWebView?
    
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var parent: WebView
//        var bridge: WKWebViewJavascriptBridge
        init(_ parent: WebView) {
            self.parent = parent
//            bridge = WKWebViewJavascriptBridge(webView: parent.webView!)
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("收到Web消息:", message.body)
            guard let dict = message.body as? [String: Any] else { 
                print("消息格式错误")
                return 
            }
            
            print("消息内容:", dict)
            
            switch message.name {
            case "nativeAction":
                if let action = dict["action"] as? String {
                    print("执行原生动作:", action)
                    handleNativeAction(action, params: dict["params"], callbackId: dict["callbackId"] as? String)
                }
            default:
                print("未知的消息名称:", message.name)
                break
            }
        }
        
        private func handleNativeAction(_ action: String, params: Any?, callbackId: String?) {
            print("处理原生动作:", action, "callbackId:", callbackId ?? "nil")
            
            switch action {
            case "getVersion":
                DispatchQueue.main.async { [weak self] in
                    print("正在获取版本信息...")
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                       let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                        print("获取到版本信息 - version:", version, "build:", build)
                        self?.invokeJSCallback(callbackId: callbackId, data: [
                            "success": true,
                            "version": version,
                            "build": build
                        ])
                    } else {
                        print("无法获取版本信息")
                        self?.invokeJSCallback(callbackId: callbackId, data: [
                            "success": false,
                            "error": "无法获取版本信息"
                        ])
                    }
                }
            default:
                print("未知的原生动作:", action)
                break
            }
        }
        
        private func invokeJSCallback(callbackId: String?, data: [String: Any]) {
            guard let callbackId = callbackId else {
                print("没有callbackId，无法执行回调")
                return
            }
            
            let jsonData = try? JSONSerialization.data(withJSONObject: data)
            if let jsonString = String(data: jsonData ?? Data(), encoding: .utf8) {
                let js = "window.Bridge.handleCallback('\(callbackId)', \(jsonString))"
                print("执行JS回调:", js)
                
                DispatchQueue.main.async { [weak self] in
                    self?.parent.webView?.evaluateJavaScript(js) { result, error in
                        if let error = error {
                            print("回调执行错误:", error)
                        } else {
                            print("回调执行成功")
                        }
                    }
                }
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
        
        print("正在初始化WebView配置")
        
        userContentController.add(context.coordinator, name: "nativeAction")
        
        let bridge = """
            console.log('正在注入Bridge');
            window.Bridge = {
                callbacks: {},
                callbackId: 0,
                
                getVersion: function() {
                    console.log('调用getVersion方法');
                    return new Promise((resolve, reject) => {
                        const callbackId = 'cb_' + (++this.callbackId);
                        console.log('生成callbackId:', callbackId);
                        this.callbacks[callbackId] = { resolve, reject };
                        
                        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeAction) {
                            console.log('发送消息到原生端');
                            window.webkit.messageHandlers.nativeAction.postMessage({
                                action: 'getVersion',
                                callbackId: callbackId
                            });
                        } else {
                            console.error('原生消息处理器未找到');
                            reject('原生消息处理器未找到');
                        }
                    });
                },
                
                handleCallback: function(callbackId, data) {
                    console.log('收到原生回调:', callbackId, data);
                    const callback = this.callbacks[callbackId];
                    if (callback) {
                        console.log('执行回调');
                        callback.resolve(data);
                        delete this.callbacks[callbackId];
                    } else {
                        console.log('未找到对应的回调');
                    }
                }
            };
            console.log('Bridge注入完成');
        """
        
        let script = WKUserScript(source: bridge, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        userContentController.addUserScript(script)
        
        config.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
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
