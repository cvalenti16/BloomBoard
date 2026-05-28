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
        sort: [
            SortDescriptor(\Post.creationDate, order:  .reverse)
        ]) var allPosts: [Post]
    
    var body: some View {
        PostListView(posts: allPosts, listType: .drafts)
    }
}
