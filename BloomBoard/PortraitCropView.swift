import SwiftUI
import Photos

struct PortraitCropView: View {
    @Environment(\.dismiss) var dismiss
    
    // Drag
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    // Zoom
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    @State private var backgroundColor: Color = .black
    @State private var userFeedback: String? = nil
    
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
                
                ZStack (alignment: .bottom) {
                        if let image = loadedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: width, height: height)
                                .scaleEffect(scale)
                                .offset(offset)
                                .gesture(
                                    SimultaneousGesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newOffset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                                offset = boundedOffset(
                                                    newOffset,
                                                    in: CGSize(width: width, height: height)
                                                )
                                            }
                                            .onEnded { _ in
                                                lastOffset = offset
                                            },
                                        
                                        // Pinch zoom
                                        MagnificationGesture()
                                            .onChanged { value in
                                                scale = lastScale * value
                                            }
                                            .onEnded { _ in
                                                lastScale = scale
                                            }
                                    )
                                )
                        }
                    
                        Text(userFeedback ?? "")
                            .defaultMessageStyle()
                            .animation(.easeInOut, value: userFeedback)
                }
                .frame(width: width, height: height)
                .clipped()
                .background(backgroundColor)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .navigationTitle("Convert to 9:16")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: UIIcons.cancel)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    ColorPicker(
                        "",
                        selection: $backgroundColor,
                        supportsOpacity: false
                    )
                    .labelsHidden()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        exportImage(width: UIScreen.main.bounds.width)
                    } label: {
                        Image(systemName: UIIcons.download)
                    }
                }
            }
        }
    }
    
    private func exportImage(width: CGFloat) {
        let height = width / targetAspect
        let view = CropCanvas(width: width, height: height)

        let renderer = ImageRenderer(content: view)

        // Render as UIImage
        if let uiImage = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            showFeedback(message: FeedbackMessages.downloadSucceeded)
        }
    }
    
    @ViewBuilder
    private func CropCanvas(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            backgroundColor
            
            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .scaleEffect(scale)
                    .offset(offset)
            }
        }
        .frame(width: width, height: height)
        .clipped()
    }
    
    // MARK: - Drag Bounds
    private func boundedOffset(_ proposed: CGSize, in frameSize: CGSize) -> CGSize {
        let maxX = frameSize.width / 2
        let maxY = frameSize.height / 2
        
        let clampedX = proposed.width.clamped(to: -maxX...maxX)
        let clampedY = proposed.height.clamped(to: -maxY...maxY)
        
        return CGSize(width: clampedX, height: clampedY)
    }
    
    func showFeedback(message: String) {
        userFeedback = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.userFeedback = nil
        }
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
