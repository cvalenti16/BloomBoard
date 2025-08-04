//
//  ContentView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 6/30/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TabView {
                Tab(UIStrings.basePlanString,
                    systemImage: UIIcons.basePlan) {
                    BasePlanView()
                }
                
                Tab(UIStrings.postString,
                    systemImage: UIIcons.posts) {
                   PostDetailView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
