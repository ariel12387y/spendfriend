import SwiftUI

struct BrandSelectionView: View {
    @Binding var currentStep: OnboardingStep
    @Binding var brands: [Brand]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 10) {
                Text("Choose Your Brands")
                    .font(.system(size: 34, weight: .bold))
                
                Text("Tap the companies you spend money with\nto start owning their stock.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.textSecondary)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 40)
            
            // Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 25) {
                    ForEach(brands.indices, id: \.self) { index in
                        BrandGridItem(brand: $brands[index])
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
            Spacer()
            
            // CTA Button
            Button(action: {
                withAnimation { currentStep = .amountConfig }
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.accent)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
}

struct BrandGridItem: View {
    @Binding var brand: Brand
    
    var body: some View {
        Button(action: {
            brand.isEnabled.toggle()
        }) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.secondaryBackground)
                        .frame(width: 72, height: 72)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(brand.isEnabled ? Theme.accent : Color.white.opacity(0.1), lineWidth: 2)
                        )
                    
                    Image(brand.logoName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .cornerRadius(8)
                }
                
                Text(brand.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(brand.isEnabled ? .white : Theme.textSecondary)
                    .lineLimit(1)
            }
        }
    }
}
