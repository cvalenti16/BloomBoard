//
//  PostItemView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/3/25.
//

import SwiftUI

struct PostItemView: View {
    let post: Post
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(post.title)
                .bold()
                .font(.title3)
            
//            Text(testPost.completedDate, format: .dateTime.day().month().year())
//                .font(.subheadline)
        }
    }
}

#Preview {
    PostItemView(post: Post.testPost)
        .preferredColorScheme(.dark)
}
