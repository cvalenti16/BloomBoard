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
                    .foregroundStyle(.white)
            }
            
            HStack {
                Text(PostStrings.created) +
                Text(Punctuation.colon) +
                Text(Punctuation.space) +
                Text(post.creationDate, style: .date)
            }
            .foregroundStyle(.secondary)
            
            if let postDate = post.postDate {
                HStack {
                    Text(PostStrings.posted) +
                    Text(Punctuation.colon) +
                    Text(Punctuation.space) +
                    Text(postDate, style: .date)
                }
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
