//
//  ContentView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 6/30/25.
//

import SwiftUI

//enum MainTab: Hashable {
//    case posts
//    case create
//    case plan
//}

struct ContentView: View {
//    @State private var selection: MainTab = .create // start on middle tab
    
    var body: some View {
        TabView {
            
            Tab(PostStrings.postString, systemImage: UIIcons.posts) {
                PostListView()
            }
          
            Tab(UIStrings.basePlanString, systemImage: UIIcons.basePlan) {
                BasePlanView()
            }
        }
    }
}

#Preview {
    ContentView()
}
