//
//  PostItemView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/3/25.
//

import SwiftUI

struct PostItemView: View {
    let post: Post
    let onSelect: (Post) -> Void
    var body: some View {
        
        VStack (alignment: .leading) {
            Button {
                onSelect(post)
            } label: {
                Text(post.title)
                    .bold()
                    .font(.title3)
                    .foregroundStyle(.text)
            }
            
            HStack {
                
                if let postedDate = post.postDate {
                    Text("\(PostStrings.posted)\(Punctuation.colon)\(Punctuation.space)\(postedDate, style: .date)")
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(PostStrings.created)\(Punctuation.colon)\(Punctuation.space)\(post.creationDate, style: .date)")
                        .foregroundStyle(.secondary)
                }
                
                Image(systemName: post.image == nil ? "text.document.fill" : "photo")
                    .foregroundStyle(.secondary)
                
            }
            
            if let postPerformance = post.performance {
                Text("\(PostStrings.performance)\(Punctuation.colon)\(Punctuation.space)\(postPerformance.rawValue)")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    PostItemView(post: Post.testPost) { post in
        
    }
    .preferredColorScheme(.dark)
}
