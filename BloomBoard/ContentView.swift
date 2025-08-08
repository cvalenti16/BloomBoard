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
                
                Tab(PostStrings.postString,
                    systemImage: UIIcons.posts) {
                   PostListView()
                }
                
                Tab(UIStrings.basePlanString,
                    systemImage: UIIcons.basePlan) {
                    CalendarMonthView()
                }
                
                
            }
        }
    }
}

#Preview {
    ContentView()
}
