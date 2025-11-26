//
//  ImageCropView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 11/26/25.
//

import SwiftUI

struct PortraitCropView: View {
    let post: Post
    private let targetAspect = CGSize(width: 9, height: 16)
    
    var loadedImage: UIImage? {
        guard let imageData = post.image else { return nil }
        return UIImage(data: imageData)
    }
    
    var body: some View {
        if let image = loadedImage {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                
            }
        }
    }
}

#Preview {
    PortraitCropView(post: Post.testPosts[0])
}

