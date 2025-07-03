//
//  SkeletonPostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/2/25.
//

import SwiftUI

struct SkeletonPostView: View {
    var socialPost: SocialPost
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(socialPost.platform.rawValue)
                .bold()
                .font(.title3)
                
            Text(socialPost.postType.rawValue)
              
        }
    }
}

#Preview {
    SkeletonPostView(socialPost: SocialPost.skeletonWeekExample[0])
}
