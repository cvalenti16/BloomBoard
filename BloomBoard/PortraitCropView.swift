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
                                        let newOffset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                        // Bound the drag so image never leaves the frame
                                        offset = boundedOffset(newOffset, in: CGSize(width: width, height: height))
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                    }
                }
                .frame(width: width, height: height)
                .clipped()                  // Crops overflowing image
                .background(Color.black)    // Fills any letterboxed areas
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
    
    private func boundedOffset(_ proposed: CGSize, in frameSize: CGSize) -> CGSize {
        let maxX = frameSize.width / 2
        let maxY = frameSize.height / 2
        
        let clampedX = proposed.width.clamped(to: -maxX...maxX)
        let clampedY = proposed.height.clamped(to: -maxY...maxY)
        
        return CGSize(width: clampedX, height: clampedY)
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#Preview {
    PortraitCropView(post: Post.testPosts[0])
}
