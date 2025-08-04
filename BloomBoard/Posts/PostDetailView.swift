//
//  PostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/18/25.
//

import SwiftUI

struct PostDetailView: View {
    private let testPost = Post.testPost
    
    var body: some View {
        VStack {
            Text(testPost.title)
                .font(.title3)
            
            Text(testPost.community ?? "")
            
            Text(testPost.date, format: .dateTime.day().month().year())
            
            Image(testPost.image ?? "")
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    PostDetailView()
        .preferredColorScheme(.dark)
}
