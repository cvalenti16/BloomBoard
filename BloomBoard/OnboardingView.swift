import SwiftUI

struct OnboardingView: View {
    enum OnboardingStep: Int, CaseIterable {
        case welcome, drafts, performance, crossPost, nineBySixteen
    }
    
    @AppStorage("needsOnboarding") private var needsOnboarding = true

    @State private var currentStep: OnboardingStep = .welcome
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: imageName(for: currentStep))
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.text)
                .padding()
            
            Text(title(for: currentStep))
                .font(.largeTitle)
                .bold()
                .padding(.horizontal, 5)
            
            Text(subtitle(for: currentStep))
                .font(.title3)
                .padding(.top, 5)
            
            Spacer()

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
                    if currentStep == .nineBySixteen {
                        needsOnboarding = false
                    } else if let next = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                        currentStep = next
                    }
                } label: {
                    Text(currentStep == .nineBySixteen ? "Finish" : "Next")
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
        case .welcome: return "party.popper"
        case .drafts: return "tray.and.arrow.down.fill"
        case .performance: return "chart.bar.fill"
        case .crossPost: return "square.grid.2x2.fill"
        case .nineBySixteen: return "square.dashed"
        }
    }
    
    func title(for step: OnboardingStep) -> String {
        switch step {
        case .welcome: return "Meet BloomBoard"
        case .drafts: return "Store Post Ideas"
        case .performance: return "Track Performance"
        case .crossPost: return "Manage Platforms"
        case .nineBySixteen: return "Convert to 9:16"
        }
    }
    
    func subtitle(for step: OnboardingStep) -> String {
        switch step {
        case .welcome: return "Made to support your content workflow"
        case .drafts: return "Build your content pipeline"
        case .performance: return "Rate posts by views for feedback"
        case .crossPost: return "See where you’ve shared your content"
        case .nineBySixteen: return "Format images for vertical platforms"
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
