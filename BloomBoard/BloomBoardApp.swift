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
    
    @AppStorage("selectedAppearance") private var selectedAppearance: Appearance = .dark
    let modelContainer: ModelContainer
    
    init() {
         do {
             modelContainer = try ModelContainer(
                 for: Post.self,
                 configurations: ModelConfiguration(
                     cloudKitDatabase: .automatic
                 )
             )
         } catch {
             fatalError(error.localizedDescription)
         }
     }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(selectedAppearance.colorScheme)
        }
        .modelContainer(modelContainer)
    }
}

enum Appearance: String, Codable, CaseIterable {
    case light, dark
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}
