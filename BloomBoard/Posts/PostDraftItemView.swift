//
//  PostItemView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/3/25.
//

import SwiftUI

struct PostDraftItemView: View {
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
                    .foregroundStyle(.white)
            }
            
            if let postedDate = post.postDate {
                Text("\(PostStrings.posted)\(Punctuation.colon)\(Punctuation.space)\(postedDate, style: .date)")
                    .foregroundStyle(.secondary)
            } else {
                Text("\(PostStrings.created)\(Punctuation.colon)\(Punctuation.space)\(post.creationDate, style: .date)")
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
    PostDraftItemView(post: Post.testPost) { post in
        
    }
    .preferredColorScheme(.dark)
}
