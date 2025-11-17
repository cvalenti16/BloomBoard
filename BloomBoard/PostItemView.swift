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
    var hasImage: Bool {
        post.image != nil
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            Button {
                onSelect(post)
            } label: {
                Text(post.title)
                    .bold()
                    .font(.title3)
                    .foregroundStyle(.text)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            
            HStack {
                if let postDate = post.postDate {
                    Text("\(UIStrings.posted)\(postDate, style: .date)")
                } else {
                    Text("\(UIStrings.created)\(post.creationDate, style: .date)")
                }
                
                Image(systemName: hasImage ? UIIcons.photo : UIIcons.document)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            if let postPerformance = post.performance {
                Text((postPerformance.rawValue))
                    .padding(5)
                    .background(postPerformance.color.opacity(0.5))
                    .clipShape(.rect(cornerRadius: 10))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
