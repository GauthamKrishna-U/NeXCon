// NeXConApp.swift
// NeXCon — Student Productivity App
// Entry point for the SwiftUI application

import SwiftUI

@main
struct NeXConApp: App {
    
    // Single shared ViewModel injected into the environment
    @StateObject private var viewModel = TaskViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
