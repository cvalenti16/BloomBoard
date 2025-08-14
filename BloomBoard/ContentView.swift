//
//  ContentView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 6/30/25.
//

import SwiftUI
import SwiftData

enum MainTab: Hashable {
    case posts
    case create
    case plan
    case calendar
}

struct ContentView: View {
    @State private var selection: MainTab = .create // start on middle tab
    
//    @Query(
//        filter: #Predicate<Post> { $0.image != nil }
//    ) var postsWithImages: [Post]
    
    var body: some View {
        TabView(selection: $selection) {
            
            Tab(PostStrings.drafts, systemImage: UIIcons.posts, value: .posts) {
                PostDraftListView()
            }
            
            Tab(PostStrings.createPost, systemImage: UIIcons.addIcon, value: .create) {
                AddPostHome()
            }
            
            Tab(PostStrings.published, systemImage: UIIcons.published, value: .plan) {
                PostPublishedListView()
            }
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
