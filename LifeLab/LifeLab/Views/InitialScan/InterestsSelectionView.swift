import SwiftUI

struct InterestsSelectionView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @State private var hasStarted = false
    
    var body: some View {
        if !hasStarted {
            // Welcome/Introduction Screen
            welcomeScreen
        } else {
            // Keywords Selection Screen
            keywordsSelectionScreen
        }
    }
    
    private var welcomeScreen: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                VStack(spacing: 16) {
                    Text("我喜歡的事")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("接下來，我們會請您選擇感興趣的關鍵詞")
                        .font(.title3)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "1.circle.fill")
                                .foregroundColor(.blue)
                            Text("點擊您感興趣的關鍵詞")
                                .font(.body)
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "2.circle.fill")
                                .foregroundColor(.blue)
                            Text("我們會根據您的選擇顯示相關詞語")
                                .font(.body)
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "3.circle.fill")
                                .foregroundColor(.blue)
                            Text("選擇越多，分析越準確")
                                .font(.body)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                }
                
                    VStack(spacing: BrandSpacing.md) {
                        HStack(spacing: BrandSpacing.sm) {
                            Image(systemName: "timer")
                                .foregroundColor(BrandColors.warning)
                            Text("點擊「開始」後，計時器將開始倒數")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.warning)
                                .fontWeight(.semibold)
                        }
                        .padding(BrandSpacing.lg)
                        .background(BrandColors.warning.opacity(0.1))
                        .cornerRadius(BrandRadius.medium)
                        
                        Text("剩餘時間：\(viewModel.timeRemaining)秒")
                            .font(BrandTypography.title2)
                            .foregroundColor(BrandColors.secondaryText)
                    }
                    .padding(.horizontal, BrandSpacing.xxxl)
            }
            
            Spacer()
            
            Button(action: {
                hasStarted = true
                viewModel.startInterestTimer()
            }) {
                HStack(spacing: BrandSpacing.sm) {
                    Text("開始")
                    Image(systemName: "play.fill")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BrandSpacing.lg)
                .background(BrandColors.primaryGradient)
                .cornerRadius(BrandRadius.medium)
                .shadow(color: BrandColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, BrandSpacing.xxxl)
            .padding(.bottom, 60)
        }
    }
    
    private var keywordsSelectionScreen: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("我喜歡的事")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if viewModel.isTimerActive {
                    HStack(spacing: BrandSpacing.sm) {
                        Image(systemName: "timer")
                            .foregroundColor(BrandColors.warning)
                        Text("剩餘時間：\(viewModel.timeRemaining)秒")
                            .font(BrandTypography.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(BrandColors.warning)
                    }
                    .padding(BrandSpacing.lg)
                    .background(BrandColors.warning.opacity(0.1))
                    .cornerRadius(BrandRadius.medium)
                } else {
                    Text("時間到！您可以繼續選擇或進入下一步")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
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
                
                if !viewModel.isTimerActive {
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
