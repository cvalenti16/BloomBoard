import SwiftUI

struct PortraitCropView: View {
    let post: Post
    private let targetAspect: CGFloat = 9.0 / 16.0
    
    var loadedImage: UIImage? {
        guard let data = post.image else { return nil }
        return UIImage(data: data)
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = width / targetAspect
            
            ZStack {
                if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: height)
                }
            }
            .frame(width: width, height: height)
            .background(Color.black)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }
}

#Preview {
    PortraitCropView(post: Post.testPosts[0])
}
