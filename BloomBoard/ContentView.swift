//
//  ContentView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 6/30/25.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @Query(
        filter: #Predicate<Post> { $0.postDate == nil }
        ,sort: [
            SortDescriptor(\Post.creationDate)
        ]) var draftPosts: [Post]
    
    @Query(
        filter: #Predicate<Post> { $0.postDate != nil }
        ,sort: [
            SortDescriptor(\Post.postDate, order: .reverse)
        ]) var publishedPosts: [Post]
    
    @State var searchText = ""
    
    var body: some View {
        TabView {
            
            Tab(UIStrings.drafts, systemImage: UIIcons.posts) {
                PostListView(posts: draftPosts,  isDrafts: true)
            }
            
            Tab(UIStrings.published, systemImage: UIIcons.published) {
                PostListView(posts: publishedPosts, isDrafts: false)
            }
            
            Tab(role: .search) {
                NavigationStack {
                    Text(searchText)
                        .navigationTitle("Search")
                }
            }
        }
        .searchable(text: $searchText)
        
    }
}



#Preview {
    ContentView()
}
