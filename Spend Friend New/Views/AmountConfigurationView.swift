import SwiftUI

struct AmountConfigurationView: View {
    @Binding var currentStep: OnboardingStep
    @Binding var brands: [Brand]
    var onComplete: () -> Void
    
    var selectedBrands: [Int] {
        brands.indices.filter { brands[$0].isEnabled }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 10) {
                Text("How Much to Invest?")
                    .font(.system(size: 34, weight: .bold))
                
                Text("Set the amount to invest automatically\nwith every purchase at these companies.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.textSecondary)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 40)
            
            // Scrollable List
            ScrollView {
                VStack(spacing: 20) {
                    if selectedBrands.isEmpty {
                        Text("No brands selected. Go back to choose some!")
                            .foregroundColor(Theme.textSecondary)
                            .padding(.top, 50)
                    } else {
                        ForEach(selectedBrands, id: \.self) { index in
                            BrandAmountCard(brand: $brands[index])
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
            }
            
            Spacer()
            
            // CTA Button
            Button(action: {
                onComplete()
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

struct BrandAmountCard: View {
    @Binding var brand: Brand
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                Image(brand.logoName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(brand.name).font(.headline)
                    Text("$\(brand.investmentAmount, specifier: "%.2f")").font(.subheadline.bold()).foregroundColor(Theme.accent)
                }
                
                Spacer()
                
                Toggle("", isOn: $brand.isEnabled).labelsHidden()
            }
            
            HStack {
                Text("Amount").font(.caption).foregroundColor(Theme.textSecondary)
                Spacer()
                Text("$\(brand.investmentAmount, specifier: "%.2f")").font(.caption.bold())
            }
            
            Slider(value: $brand.investmentAmount, in: 1...50, step: 1)
                .accentColor(Theme.accent)
        }
        .padding(20)
        .background(Theme.secondaryBackground)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
