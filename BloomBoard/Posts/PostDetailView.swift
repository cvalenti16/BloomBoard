//
//  PostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/18/25.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post
    var body: some View {
        VStack {
            Text(post.title)
                .font(.title3)
                .padding()
            
            if let image = post.image {
                Image(image)
                    .resizable()
                    .scaledToFit()
            }
                        
//            Text(testPost.completedDate, format: .dateTime.day().month().year())
//            Image(testPost.image ?? "")
//                .resizable()
//                .scaledToFit()
        }
    }
}

#Preview {
    PostDetailView(post: Post.testPost)
        .preferredColorScheme(.dark)
}
