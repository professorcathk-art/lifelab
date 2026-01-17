import SwiftUI

struct PaymentView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @State private var selectedPackage: SubscriptionPackage = .yearly
    
    enum SubscriptionPackage: String, CaseIterable {
        case yearly = "yearly"
        case quarterly = "quarterly"
        case monthly = "monthly"
        
        var title: String {
            switch self {
            case .yearly: return "年付"
            case .quarterly: return "季付"
            case .monthly: return "月付"
            }
        }
        
        var price: String {
            switch self {
            case .yearly: return "$7.9"
            case .quarterly: return "$9.9"
            case .monthly: return "$18.99"
            }
        }
        
        var period: String {
            switch self {
            case .yearly: return "/月（年付）"
            case .quarterly: return "/月（季付，90天週期）"
            case .monthly: return "/月（月付）"
            }
        }
        
        var savings: String? {
            switch self {
            case .yearly: return "節省 58%"
            case .quarterly: return "節省 48%"
            case .monthly: return nil
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("解鎖初版生命藍圖")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("選擇訂閱方案，即可查看AI為您生成的個人化生命藍圖")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 32)
                
                // Subscription packages
                VStack(spacing: 16) {
                    ForEach(SubscriptionPackage.allCases, id: \.self) { package in
                        PackageCard(
                            package: package,
                            isSelected: selectedPackage == package,
                            onSelect: {
                                selectedPackage = package
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Button(action: {
                    viewModel.completePayment()
                }) {
                    HStack(spacing: BrandSpacing.sm) {
                        Image(systemName: "lock.open.fill")
                        Text("訂閱並解鎖")
                    }
                    .font(BrandTypography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BrandSpacing.lg)
                    .background(BrandColors.primaryGradient)
                    .cornerRadius(BrandRadius.medium)
                    .shadow(color: BrandColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, BrandSpacing.xxxl)
                
                Text("註：現階段為測試版本，無需實際支付")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 32)
            }
        }
    }
}

struct PackageCard: View {
    let package: PaymentView.SubscriptionPackage
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(package.title)
                            .font(.headline)
                        
                        if let savings = package.savings {
                            Text(savings)
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(package.price)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(package.period)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding()
            .background(isSelected ? BrandColors.primaryBlue.opacity(0.15) : BrandColors.secondaryBackground)
            .cornerRadius(BrandRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: BrandRadius.medium)
                    .stroke(isSelected ? BrandColors.primaryBlue : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? BrandColors.primaryBlue.opacity(0.2) : BrandShadow.small.color, 
                   radius: isSelected ? 8 : BrandShadow.small.radius, 
                   x: 0, 
                   y: isSelected ? 4 : BrandShadow.small.y)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaymentView()
        .environmentObject(InitialScanViewModel())
}

#Preview {
    PaymentView()
        .environmentObject(InitialScanViewModel())
}
