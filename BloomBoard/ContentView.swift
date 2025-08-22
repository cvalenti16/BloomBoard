//
//  ContentView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 6/30/25.
//

import SwiftUI
import SwiftData

enum MainTab: Hashable {
    case drafts
    case create
    case published
}

struct ContentView: View {
    @State private var selection: MainTab = .drafts // start in left tab
    @State var showAddPostSheet = false
    
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
    
//    @Query(
//        filter: #Predicate<Post> { $0.image != nil }
//    ) var postsWithImages: [Post]
    
    var body: some View {
        TabView(selection: $selection) {
            
            Tab(PostStrings.drafts, systemImage: UIIcons.posts, value: .drafts) {
                PostListView(posts: draftPosts, isDrafts: true)
            }
            
            Tab(PostStrings.createPost, systemImage: UIIcons.addIcon, value: .create) {
                Text("")
            }
            
            Tab(PostStrings.published, systemImage: UIIcons.published, value: .published) {
                PostListView(posts: publishedPosts, isDrafts: false)
            }
        }
        .onChange(of: selection) { oldValue, newValue in
            if selection == .create {
                showAddPostSheet.toggle()
                selection = .drafts
            }
           
        }
        .sheet(isPresented: $showAddPostSheet) {
            AddPostSheet()
        }
        
//        .onAppear {
//            for posts in postsWithImages {
//                print(posts.image ?? "")
//            }
//        }
        
        
//        .onAppear {
//            let keep = Set(postsWithImages.compactMap {
//                $0.image
//            })
//            
//            Task.detached {
//                let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                
//                
//                do {
//                    let files = try FileManager.default.contentsOfDirectory(
//                                       at: docs, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]
//                                   )
//                    let jpgs = files.filter { $0.pathExtension.lowercased() == "jpg" }
//                    
//                    var deleted = 0
//                    
//                    for url in jpgs where !keep.contains(url.lastPathComponent) {
//                              try? FileManager.default.removeItem(at: url)
//                              deleted += 1
//                              print("🗑️ Deleted unused image:", url.lastPathComponent)
//                          }
//                          print("🧹 Image GC done — kept \(keep.count), deleted \(deleted)")
//                    
//                } catch {
//                    print("GC error:", error)
//                }
//                
//            }
//        }
    }
}



#Preview {
    ContentView()
}
