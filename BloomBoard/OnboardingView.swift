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
            Spacer()
        }
    }
}


#Preview {
    OnboardingView()
}
