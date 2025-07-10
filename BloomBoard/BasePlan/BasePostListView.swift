//
//  DailyPostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/2/25.
//

import SwiftUI

struct BasePostListView: View {
    var socialPost: [SocialPost]
    var day: Day
    
    let rowHeight: CGFloat = 70
    let maxHeight: CGFloat = 325
    
    var listHeight: CGFloat {
        let totalHeight = rowHeight * CGFloat(filteredPost.count)
        return min(totalHeight,maxHeight)
    }
    
    var filteredPost: [SocialPost] {
        socialPost
            .filter { $0.postDay == day}
            .sorted { $0.platform.rawValue < $1.platform.rawValue}
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            if(!filteredPost.isEmpty) {
                Text(day.rawValue)
                    .padding()
                    .font(.largeTitle)
                    .bold()
                
                
                List (filteredPost) { post in
                    BasePostView(socialPost: post)
                    
                }
                .listStyle(.plain)
                .frame(height: listHeight)
                
            }
            
            
        
//            if (filteredPost.isEmpty) {
//                Text(UIStrings.restDayString.rawValue)
//                    .padding()
//                    .padding(.top, -20)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                
//                
//            } else {
//                List (filteredPost) { post in
//                    BasePostView(socialPost: post)
//                    
//                }
//                .listStyle(.plain)
//                .frame(height: listHeight)
//            }
        }
    }
}
