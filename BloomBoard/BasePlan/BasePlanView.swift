//
//  HomeView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/2/25.
//

import SwiftUI

struct BasePlanView: View {
    var socialPosts = SocialPost.skeletonWeekExample
    @State private var showAddSheet = false
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                ForEach(Day.allCases, id: \.self) { day in
                    BasePostListView(socialPost: socialPosts, day: day)
                }
            }
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet.toggle()
                    } label: {
                        Image(systemName: UIIcons.addIcon.rawValue)
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddBasePostView()
            }
            
        }
    }
}

#Preview {
    BasePlanView()
}
