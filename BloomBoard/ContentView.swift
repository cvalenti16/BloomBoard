//
//  ContentView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 4/20/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(
        filter: #Predicate<Post> { $0.postDate == nil },
        sort: [
            SortDescriptor(\Post.creationDate)
        ]) var draftPosts: [Post]
    
    @Query(
        filter: #Predicate<Post> { $0.postDate != nil },
        sort: [
            SortDescriptor(\Post.postDate)
        ]) var publishedPosts: [Post]
        
    var body: some View {
        TabView {
            Tab("Drafts", systemImage: "square.and.pencil") {
                PostListView(posts: draftPosts)
            }
            
            Tab("Published", systemImage: "checkmark.seal.text.page.rtl" ) {
                PostListView(posts: publishedPosts)
            }
        }
    }
}

