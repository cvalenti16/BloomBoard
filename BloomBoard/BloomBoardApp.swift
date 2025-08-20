//
//  BloomBoardApp.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 6/30/25.
//

import SwiftUI
import SwiftData

@main
struct BloomBoardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [SocialPost.self, Post.self])
    }
}
