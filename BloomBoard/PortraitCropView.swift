import SwiftUI

struct PortraitCropView: View {
    @Environment(\.dismiss) var dismiss
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private let targetAspect: CGFloat = 9.0 / 16.0
    let post: Post
    
    var loadedImage: UIImage? {
        guard let data = post.image else { return nil }
        return UIImage(data: data)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let width = geo.size.width
                let height = width / targetAspect
                
                ZStack {
                    if let image = loadedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: width, height: height)
                            .offset(offset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                    }
                }
                .frame(width: width, height: height)
                .background(Color.black)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .navigationTitle("Convert to 9:16")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: UIIcons.cancel)
                    }
                }
            }
        }
    }
}

#Preview {
    PortraitCropView(post: Post.testPosts[0])
}
