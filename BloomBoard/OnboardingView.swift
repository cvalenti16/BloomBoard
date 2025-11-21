import SwiftUI

struct OnboardingView: View {
    enum OnboardingStep: Int, CaseIterable {
        case welcome, draftFeature, trackFeature, crossPostFeature
    }
    
    @AppStorage("needsOnboarding") private var needsOnboarding = true

    @State private var currentStep: OnboardingStep = .welcome
    
    var body: some View {
        VStack {
//            Spacer()
            
            Image(systemName: imageName(for: currentStep))
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.text)
                .padding()
            
            Text(title(for: currentStep))
                .font(.largeTitle)
                .bold()
            
            Text(subtitle(for: currentStep))
                .font(.title3)
                .padding(.top, 5)
            
//            Spacer()

            HStack {
                if currentStep != .welcome {
                    Button {
                        if let prev = OnboardingStep(rawValue: currentStep.rawValue - 1) {
                            currentStep = prev
                        }
                    } label: {
                        Text("Previous")
                            .onboardingButtonStyle()
                    }
                }
                
                Button {
                    if currentStep == .crossPostFeature {
                        needsOnboarding = false
                    } else if let next = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                        currentStep = next
                    }
                } label: {
                    Text("Next")
                        .onboardingButtonStyle()
                }
            }
            .padding()
            
            HStack {
                ForEach(OnboardingStep.allCases, id: \.self) { step in
                    Circle()
                        .frame(width: step == currentStep ? 12 : 8, height: step == currentStep ? 12 : 8)
                        .foregroundStyle(step == currentStep ? .accentColor : Color.gray.opacity(0.3))
                }
            }
        }
    }
    
    func imageName(for step: OnboardingStep) -> String {
        switch step {
        case .welcome: return "hand.wave.fill"
        case .draftFeature: return "tray.and.arrow.down.fill"
        case .trackFeature: return "chart.bar.fill"
        case .crossPostFeature: return "square.grid.2x2.fill"
        }
    }
    
    func title(for step: OnboardingStep) -> String {
        switch step {
        case .welcome: return "Welcome to BloomBoard"
        case .draftFeature: return "Store Post Ideas"
        case .trackFeature: return "Track Performance"
        case .crossPostFeature: return "Manage Platforms"
        }
    }
    
    func subtitle(for step: OnboardingStep) -> String {
        switch step {
        case .welcome: return "Plan, track, and manage your posts"
        case .draftFeature: return "Build your content pipeline"
        case .trackFeature: return "Rate posts by views to improve"
        case .crossPostFeature: return "See where you’ve shared your content"
        }
    }
}

extension Text {
    func onboardingButtonStyle() -> some View {
        self
            .font(.headline)
            .frame(minWidth: 130, minHeight: 45)
            .background(.thinMaterial)
            .foregroundStyle(.text)
            .clipShape(.rect(cornerRadius: 10))
    }
}

#Preview {
    OnboardingView()
}
