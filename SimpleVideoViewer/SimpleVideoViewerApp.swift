//
//  SimpleVideoViewerApp.swift
//  SimpleVideoViewer
//
//  Created by aleksey.kazakov on 10.01.2025.
//

import SwiftUI
//import SwiftData

//@main
//struct MediaGridApp: App {
//    
//    let manager = AppManager()
//    
//    var body: some Scene {
//        WindowGroup {
//            MainView().environmentObject(manager)
//        }
//    }
//}


@main
struct MediaGridApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    let manager = AppManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(manager)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    switch newPhase {
                    case .active:
                        manager.loadSettings()
                        manager.startImageRefreshTimers()
                    case .inactive, .background:
                        manager.timers.forEach { $0.cancel() }
                    @unknown default:
                        break
                    }
                }
        }
    }
}
