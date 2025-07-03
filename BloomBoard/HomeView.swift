//
//  HomeView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/2/25.
//

import SwiftUI

struct HomeView: View {
    var socialPosts = SocialPost.skeletonWeekExample
    
    var body: some View {
     
            ScrollView {
                SkeletonListView(socialPost: socialPosts, day: Day.Sunday)
                
                SkeletonListView(socialPost: socialPosts, day: Day.Monday)
                
                SkeletonListView(socialPost: socialPosts, day: Day.Tuesday)
                
                
                SkeletonListView(socialPost: socialPosts, day: Day.Wednesday)
                
                
                SkeletonListView(socialPost: socialPosts, day: Day.Thursday)
                
                
                SkeletonListView(socialPost: socialPosts, day: Day.Friday)
                
                SkeletonListView(socialPost: socialPosts, day: Day.Saturday)
            }
    }
}

#Preview {
    HomeView()
}
