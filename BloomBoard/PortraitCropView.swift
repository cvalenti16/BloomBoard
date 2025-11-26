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
        guard let data = post.image else { return nil }
        return UIImage(data: data)
    }
     
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ScrollView(.horizontal) {
                    if let image = loadedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: geo.size.height)
                    }
                }
                
                cropOverlay(in: geo.size)
                    .allowsHitTesting(false)
            }
            .background(Color.black)
        }
    }
    
    private func cropOverlay(in size: CGSize) -> some View {
        let cropHeight = size.width * (targetAspect.height / targetAspect.width)
        let centerY = size.height / 2
        
        return ZStack {
            // Dim everything
            Color.black.opacity(0.55)
            
            // Punch hole in the middle
            Rectangle()
                .frame(width: size.width, height: cropHeight)
                .position(x: size.width / 2, y: centerY)
                .blendMode(.destinationOut)
        }
        .compositingGroup()
    }
}

#Preview {
    PortraitCropView(post: Post.testPosts[0])
}
