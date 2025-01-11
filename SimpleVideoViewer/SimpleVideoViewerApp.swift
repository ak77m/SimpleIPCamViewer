//
//  SimpleVideoViewerApp.swift
//  SimpleVideoViewer
//
//  Created by aleksey.kazakov on 10.01.2025.
//

import SwiftUI
//import SwiftData

@main
struct MediaGridApp: App {
    
    let manager = AppManager()
    
    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(manager)
        }
    }
}
