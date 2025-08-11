//
//  ContentView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 6/30/25.
//

import SwiftUI

enum MainTab: Hashable {
    case posts
    case create
    case plan
}

struct ContentView: View {
    @State private var selection: MainTab = .create // start on middle tab
    
    var body: some View {
        TabView(selection: $selection) {
            
            Tab(PostStrings.postString, systemImage: UIIcons.posts, value: .posts) {
                PostListView()
            }
            
            Tab(PostStrings.createPost, systemImage: UIIcons.addIcon, value: .create) {
                AddPostView()
            }
            
            Tab(UIStrings.basePlanString, systemImage: UIIcons.basePlan, value: .plan) {
                BasePlanView()
            }
        }
    }
}

#Preview {
    ContentView()
}
