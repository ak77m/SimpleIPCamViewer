//
//  ContentView.swift
//  SimpleVideoViewer
//
//  Created by aleksey.kazakov on 10.01.2025.
//

import SwiftUI
import Combine

struct MainView: View {
    @EnvironmentObject var mgr: AppManager
    
    @State private var fullscreenItem: Int? = nil // Индекс элемента в полноэкранном режиме
    @State private var isSettingsVisible: Bool = false // Видимость модального окна настроек
   
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                if mgr.configuration.gridSize.width > 0 && mgr.configuration.gridSize.height > 0 {
                    let totalWidth = geometry.size.width
                    let cellWidth = totalWidth / CGFloat(mgr.configuration.gridSize.width)
                    let cellHeight = totalWidth / CGFloat(mgr.configuration.gridSize.width) / mgr.configuration.aspectRatio.value

                    VStack(spacing: 0) {
                        ForEach(0..<Int(mgr.configuration.gridSize.height), id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<Int(mgr.configuration.gridSize.width), id: \.self) { col in
                                    let index = row * Int(mgr.configuration.gridSize.width) + col
                                    SingleCameraView(index: index)
                                    .frame(width: cellWidth, height: cellHeight)
                                    .overlay(
                                        Rectangle()
                                            .stroke(mgr.configuration.borderColor, lineWidth: 2)
                                    )
                                    .contextMenu {
                                        Button("Show Settings") {
                                            isSettingsVisible.toggle()
                                        }
                                    }
                                    .onLongPressGesture(minimumDuration: 0.5) {
                                        fullscreenItem = index
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Text("Grid is hidden.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            if let fullscreenIndex = fullscreenItem {
                SingleCameraView(index: fullscreenIndex)
                .onTapGesture {
                    fullscreenItem = nil
                }
                .transition(.scale)
            }
        }
        .animation(.default, value: fullscreenItem)
        .sheet(isPresented: $isSettingsVisible) {
            SettingsView(isSettingsVisible: $isSettingsVisible)
        }
        .onAppear {
            mgr.loadSettings()
            mgr.startImageRefreshTimers()
        }
        .onDisappear {
            mgr.timers.forEach { $0.cancel() }
        }
    }

}




