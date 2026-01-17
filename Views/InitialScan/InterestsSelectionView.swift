import SwiftUI

struct InterestsSelectionView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @State private var hasStarted = false
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("我喜歡的事")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("點擊您感興趣的關鍵詞，我們會根據您的選擇顯示相關詞語")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                if viewModel.isTimerActive {
                    Text("剩餘時間：\(viewModel.timeRemaining)秒")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 32)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(viewModel.availableKeywords, id: \.self) { keyword in
                        KeywordButton(
                            keyword: keyword,
                            isSelected: false,
                            action: {
                                viewModel.selectInterest(keyword)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            VStack(spacing: 12) {
                if !viewModel.selectedInterests.isEmpty {
                    Text("已選擇：\(viewModel.selectedInterests.count)個")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.selectedInterests, id: \.self) { interest in
                                SelectedKeywordChip(keyword: interest)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                if !hasStarted {
                    Button(action: {
                        hasStarted = true
                        viewModel.startInterestTimer()
                    }) {
                        Text("開始")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                } else if !viewModel.isTimerActive {
                    Button(action: {
                        viewModel.moveToNextStep()
                    }) {
                        Text("繼續")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 32)
        }
    }
}

struct KeywordButton: View {
    let keyword: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(keyword)
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SelectedKeywordChip: View {
    let keyword: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(keyword)
                .font(.caption)
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
        }
        .foregroundColor(.blue)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
}

#Preview {
    InterestsSelectionView()
        .environmentObject(InitialScanViewModel())
}
