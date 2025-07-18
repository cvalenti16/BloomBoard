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
                Tab(UIStrings.basePlanString.rawValue, systemImage: UIIcons.plan.rawValue) {
                    BasePlanView()
                }
                
                Tab(UIStrings.postString.rawValue, systemImage: UIIcons.posts.rawValue) {
                    Text("Hello World")
                }
                
                
            }
            
    
        }
    }
}

#Preview {
    ContentView()
}
