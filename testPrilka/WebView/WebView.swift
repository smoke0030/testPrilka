//
//  WebView.swift
//  testPrilka
//
//  Created by Сергей on 03.10.2024.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    @Binding var isLoading: Bool
    let url: URL
    init(url: URL, isLoading: Binding<Bool>) {
        self.url = url
        self._isLoading = isLoading
    }
    
    func makeUIView(context: Context) -> some UIView {
        let wkwebView = WKWebView()
        wkwebView.navigationDelegate = context.coordinator
        let request = URLRequest(url: url)
        wkwebView.load(request)
        return wkwebView
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    func makeCoordinator() -> (Coordinator) {
        Coordinator(self)
    }
    
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            parent.isLoading = false
        }
    }
    
}

