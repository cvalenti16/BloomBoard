import SwiftUI
import SwiftData

// MARK: Onboarding not completed
private enum OnboardingPage: Int {
    case welcome
    case training
    case refine
    case remix
    case complete
    
    var next: OnboardingPage? {
        switch self {
        case .welcome: .training
        case .training: .refine
        case .refine: .remix
        case .remix: .complete
        case .complete: nil
        }
    }
}

struct OnboardingView: View {
    @AppStorage("needsOnboarding") private var needsOnboarding = true
    
    @State private var currentPage: OnboardingPage = .welcome
    
    private var isLastPage: Bool {
        currentPage == .complete
    }
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                WelcomeView()
                    .tag(OnboardingPage.welcome)
                
                TrainingView()
                    .tag(OnboardingPage.training)
            }
        }
    }
}

private struct WelcomeView: View {
    var body: some View {
        VStack {
            AppIcon()
            
            Text("Welcome to BloomBoard")
                .font(.title)
                .bold()
            
            Text("Made to help you write better X posts")
                .font(.title3)
            
        }
        .padding()
    }
}

private struct TrainingView: View {
    @Query(filter: #Predicate<Post> { post in
        post.isAITrainingPost == true
    }) var aiTrainingPosts: [Post]
    
    var body: some View {
        List {
            Section(header: Text("Grab three of your best X posts")) {
                ForEach(aiTrainingPosts) { post in
                    AITraingItemView(post: post)
                }
            }
        }
        .overlay {
            if aiTrainingPosts.isEmpty {
                ContentUnavailableView {
                    Label("These will help train your AI", systemImage: "wand.and.rays")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                // MARK Wire up the editor, might need to change it so it auto makes it remix
            } label: {
                Text("Add Post")
            }
            .foregroundStyle(.text)
            .padding()
        }
    }
}

private struct AITraingItemView: View {
    let post: Post
    
    var body: some View {
        VStack {
            Text(post.title)
                .bold()
                .font(.title3)
                .foregroundStyle(.text)
                .lineLimit(2)
                .truncationMode(.tail)
        }
    }
}

extension Bundle {
    public var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}

struct AppIcon: View {
    var body: some View {
        Image(uiImage: Bundle.main.icon ?? UIImage())
            .resizable()
            .scaledToFill()
            .clipped()
            .clipShape(.rect(cornerRadius: 22))
            .frame(width: 100, height: 100)
    }
}

#Preview {
    OnboardingView()
}
