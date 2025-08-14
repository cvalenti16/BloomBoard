//
//  ContentView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 6/30/25.
//

import SwiftUI
import SwiftData

enum MainTab: Hashable {
    case posts
    case create
    case plan
    case calendar
}

struct ContentView: View {
    @State private var selection: MainTab = .create // start on middle tab
    
    var body: some View {
        TabView(selection: $selection) {
            
            Tab(PostStrings.drafts, systemImage: UIIcons.posts, value: .posts) {
                PostDraftListView()
            }
            
            Tab(PostStrings.createPost, systemImage: UIIcons.addIcon, value: .create) {
                AddPostHome()
            }
            
            Tab(PostStrings.published, systemImage: UIIcons.published, value: .plan) {
                PostPublishedListView()
            }
        }
    }
}

#Preview {
    ContentView()
}
