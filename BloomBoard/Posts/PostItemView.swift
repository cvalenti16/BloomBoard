//
//  PostItemView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/3/25.
//

import SwiftUI

struct PostItemView: View {
    private let testPost = Post.testPost
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(testPost.title)
                .bold()
                .font(.title3)
            
            Text(testPost.date, format: .dateTime.day().month().year())
                .font(.subheadline)
        }
    }
}

#Preview {
    PostItemView()
        .preferredColorScheme(.dark)
}
