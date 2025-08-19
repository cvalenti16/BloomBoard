//
//  PostListView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/6/25.
//

import SwiftUI
import SwiftData

struct PostDraftListView: View {
    @Environment(\.modelContext) var modelContext
    
    
    @Query(
        filter: #Predicate<Post> { $0.postDate == nil }
        ,sort: [
            SortDescriptor(\Post.creationDate, order: .reverse)
        ]) var sortedPosts: [Post]
    
    @State private var showAddSheet = false
    @State private var postDetailPath = NavigationPath()
    @State private var showDeleteAlert = false
    @State private var postToDelete: Post?
    
    @State private var postToSchedule: Post?
    @State private var selectedPostDate = Date()
    
    
    var body: some View {
        NavigationStack(path: $postDetailPath) {
            if (sortedPosts.isEmpty) {
                Button {
                    showAddSheet.toggle()
                } label: {
                    Text(PostStrings.noDrafts)
                        .font(.headline)
                        .padding()
                }
                .navigationTitle(PostStrings.daftPosts)
            } else {
                List(sortedPosts) { post in
                    PostItemView(post: post) { post in
                        postDetailPath.append(post)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            postToDelete = post
                            showDeleteAlert.toggle()
                        } label: {
                            Image(systemName: UIIcons.trashIcon)
                                .tint(.red)
                        }
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
                .navigationTitle(PostStrings.daftPosts)
                
                .alert(PostStrings.deletePost, isPresented: $showDeleteAlert) {
                    Button(UIStrings.deleteString, role: .destructive) {
                        if let post = postToDelete {
                            
                            if let old = post.image {
                                deleteImageFromDisk(old)
                            }
                            
                            modelContext.delete(post)
                        }
                    }
                    Button(UIStrings.cancelString, role: .cancel) {
                        postToDelete = nil
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddPostSheet()
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(item: $postToSchedule) { post in
            SchedulePostView(post: post)
        }
    }
    
    func deleteImageFromDisk(_ filename: String) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }
}
