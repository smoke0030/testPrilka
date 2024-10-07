//
//  ContentView.swift
//  testPrilka
//
//  Created by Сергей on 03.10.2024.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    @State private var isShowWebView = false
    @State private var isLoading = false
    
    
    var body: some View {
        VStack {
            if viewModel.isFirstLaunch {
                OpenWebView()
            } else {
                OpenGame()
            }
        }
        .onAppear {
            viewModel.checkFirstLaunch()
        }
        
    }
    
    @ViewBuilder
    
    func CustomProgressView() -> some View {
        ProgressView("Загрузка")
    }
    
    func OpenWebView() -> some View {
        ZStack {
            if isShowWebView {
                if let url = viewModel.url {
                    WebView(url: url, isLoading: $isLoading)
                        .ignoresSafeArea()
                    if isLoading {
                        CustomProgressView()
                    }
                }
            } else {
                CustomProgressView()
                    .onAppear {
                        viewModel.getURL { fetchedURL in
                            DispatchQueue.main.async {
                                viewModel.url = fetchedURL
                                isShowWebView = true
                            }
                        }
                    }
            }
        }
    }
    
    func OpenGame() -> some View {
        ZStack {
            WebView(url: URL(string: Constants.gameUrl)!, isLoading: $isLoading)
                .ignoresSafeArea()
                .statusBarHidden(true)
            if isLoading {
                CustomProgressView()
            }
            
        }
    }
}

#Preview {
    ContentView()
}
