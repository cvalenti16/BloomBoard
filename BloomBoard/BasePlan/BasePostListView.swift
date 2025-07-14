//
//  DailyPostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/2/25.
//

import SwiftUI

struct BasePostListView: View {
    @Environment(\.modelContext) var modelContext
    
    @State private var postToDelete: SocialPost?
    @State private var showDeleteAlert = false
    
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
                        .swipeActions(edge: .trailing) {
                            Button {
                                postToDelete = post
                                showDeleteAlert.toggle()
                            } label: {
                                Image(systemName: UIIcons.trashIcon.rawValue)
                                    .tint(.red)
                            }
                        }
                }
                .listStyle(.plain)
                .frame(height: listHeight)
            }
                
        }
        .alert(UIStrings.removeBasePost.rawValue, isPresented: $showDeleteAlert) {
            Button(UIStrings.deleteString.rawValue, role: .destructive) {
                if let post = postToDelete {
                    modelContext.delete(post)
                }
            }
            Button(UIStrings.cancelString.rawValue, role: .cancel) {
                postToDelete = nil
            }
        }
    }
}

