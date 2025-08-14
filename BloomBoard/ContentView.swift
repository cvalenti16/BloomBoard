//
//  ContentView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 6/30/25.
//

import SwiftUI
import SwiftData
//enum MainTab: Hashable {
//    case posts
//    case create
//    case plan
//}

struct ContentView: View {
//    @State private var selection: MainTab = .create // start on middle tab

    
    
    var body: some View {
        TabView {
            
            Tab(PostStrings.drafts, systemImage: UIIcons.posts) {
                PostDraftListView()
            }
            
            
            Tab(PostStrings.createPost, systemImage: UIIcons.addIcon) {
                AddPostHome()
            }
          
            Tab(PostStrings.published, systemImage: UIIcons.published) {
                PostPublishedListView()
            }
        }
    }
}

#Preview {
    ContentView()
}
