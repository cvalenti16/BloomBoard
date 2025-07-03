//
//  DailyPostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/2/25.
//

import SwiftUI

struct SkeletonListView: View {
    var socialPost: [SocialPost]
    var day: Day
    
    var filteredPost: [SocialPost] {
        socialPost.filter { $0.postDay == day}
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(day.rawValue)
                .padding()
                .font(.largeTitle)
            
            if (filteredPost.isEmpty) {
                Text("Rest Day")
                    .padding()
                    .padding(.top, -20)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    
            } else {
                
                List (filteredPost) { post in
                    SkeletonPostView(socialPost: post)
                    
                }
                .listStyle(.plain)
                .frame(height: 210)
            }
        }
    }
}

#Preview {
    SkeletonListView(socialPost: SocialPost.skeletonWeekExample, day: Day.Saturday)
}
