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
    
    let rowHeight: CGFloat = 70
    let maxHeight: CGFloat = 325
    
    var listHeight: CGFloat {
        let totalHeight = rowHeight * CGFloat(filteredPost.count)
        return min(totalHeight,maxHeight)
    }
    
    var filteredPost: [SocialPost] {
        socialPost.filter { $0.postDay == day}
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(day.rawValue)
                .padding()
                .font(.largeTitle)
            
            if (filteredPost.isEmpty) {
                Text(UIStrings.restDayString.rawValue)
                    .padding()
                    .padding(.top, -20)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    
            } else {
                
                List (filteredPost) { post in
                    SkeletonPostView(socialPost: post)
                    
                }
                .listStyle(.plain)
                .frame(height: listHeight)
            }
        }
    }
}

#Preview {
    SkeletonListView(socialPost: SocialPost.skeletonWeekExample, day: Day.Saturday)
}
