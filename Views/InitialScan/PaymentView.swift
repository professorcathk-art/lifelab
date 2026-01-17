import SwiftUI

struct PaymentView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("解鎖初版生命藍圖")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("支付後即可查看AI為您生成的個人化生命藍圖")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 12) {
                Text("價格")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("NT$ 299")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 40)
            
            Button(action: {
                viewModel.completePayment()
            }) {
                Text("立即支付")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Text("註：現階段為測試版本，無需實際支付")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    PaymentView()
        .environmentObject(InitialScanViewModel())
}
