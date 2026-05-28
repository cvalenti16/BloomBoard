import SwiftUI
import SwiftData

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
