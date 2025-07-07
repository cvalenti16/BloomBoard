//
//  HomeView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/2/25.
//

import SwiftUI

struct BasePlanView: View {
    var socialPosts = SocialPost.skeletonWeekExample
    
    var body: some View {
        
        ScrollView {
            ForEach(Day.allCases, id: \.self) { day in
                SkeletonListView(socialPost: socialPosts, day: day)
            }
        }
        .scrollIndicators(.hidden)

    }
}

#Preview {
    BasePlanView()
}
