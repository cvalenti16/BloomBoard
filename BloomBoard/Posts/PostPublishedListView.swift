//
//  PostPublishedListView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/11/25.
//

import SwiftUI
import SwiftData

struct PostPublishedListView: View {
    
    @Query(
        filter: #Predicate<Post> { $0.postDate != nil }
        ,sort: [
            SortDescriptor(\Post.postDate, order: .reverse)
        ]) var completedPosts: [Post]
    
    @State private var postDetailPath = NavigationPath()
    @State private var postToSchedule: Post?
    
    var body: some View {
        NavigationStack(path: $postDetailPath) {
            if (completedPosts.isEmpty) {
                
                Text(PostStrings.noPublishedPosts)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundStyle(.white)
                    .padding()
                
            } else {
                List(completedPosts) { post in
                    PostItemView(post: post) { post in
                        postDetailPath.append(post)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            postToSchedule = post
                        } label: {
                            Image(systemName: UIIcons.calendar)
                                .tint(.yellow)
                        }
                    }
                }
                .navigationDestination(for: Post.self) { post in
                    PostDetailView(post: post)
                }
                .navigationTitle(PostStrings.publishedPosts)
            }
        }
        .tint(.text)
        .sheet(item: $postToSchedule) { post in
            SchedulePostView(post: post)
        }
    }
}
