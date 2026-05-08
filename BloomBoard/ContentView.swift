//
//  ContentView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 4/20/26.
//

import SwiftUI
import SwiftData

@available(iOS 18.0, *)
struct ContentView: View {
    @Query(
        filter: #Predicate<Post> { $0.postDate == nil },
        sort: [
            SortDescriptor(\Post.creationDate)
        ]) var draftPosts: [Post]
    
    @Query(
        filter: #Predicate<Post> { $0.postDate != nil },
        sort: [
            SortDescriptor(\Post.postDate, order: .reverse)
        ]) var publishedPosts: [Post]
        
    var body: some View {
        
        PostListView(posts: publishedPosts, listType: .drafts)
        
//        TabView {
//            Tab {
//                PostListView(posts: draftPosts, listType: .drafts)
//            } label: {
//                Image(systemName: "square.and.pencil")
//            }
//            
//            Tab {
//                PostListView(posts: publishedPosts, listType: .published)
//            } label: {
//                Image(systemName: "paperplane.fill")
//            }
//        }
        
    }
}
