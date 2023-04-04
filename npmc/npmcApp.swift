//
//  npmcApp.swift
//  npmc
//
//  Created by Morris Albers on 4/3/23.
//

import SwiftUI
import FirebaseCore

@main
struct npmcApp: App {
    @StateObject var CVModel = CommonViewModel()
    
    init() {
        FirebaseApp.configure()

    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(CVModel)
        }
    }
}
