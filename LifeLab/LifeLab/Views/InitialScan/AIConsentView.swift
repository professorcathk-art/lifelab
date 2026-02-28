import SwiftUI

struct AIConsentView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @StateObject private var themeManager = ThemeManager.shared
    @State private var hasReadTerms = false
    @State private var showPrivacyPolicy = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: BrandSpacing.xxl) {
                // Header
                VStack(spacing: BrandSpacing.md) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 50))
                        .foregroundColor(BrandColors.actionAccent)
                        .padding(.top, BrandSpacing.xxxl)
                    
                    Text("AI 服務使用同意")
                        .font(BrandTypography.largeTitle)
                        .foregroundColor(BrandColors.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text("在我們為您生成個人化生命藍圖之前，請先了解我們如何使用您的資料")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, BrandSpacing.lg)
                }
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                
                // Consent Details Card
                VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                    Text("資料使用說明")
                        .font(BrandTypography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(BrandColors.primaryText)
                    
                    VStack(alignment: .leading, spacing: BrandSpacing.md) {
                        // What data is sent
                        ConsentDetailRow(
                            icon: "doc.text.fill",
                            title: "發送的資料",
                            description: "我們會將您填寫的問卷資料發送給第三方 AI 服務，包括：\n• 興趣關鍵詞\n• 天賦問卷回答與關鍵詞\n• 價值觀排序與回答\n• 基本資料（如已填寫）\n• 深化探索資料（如已填寫）"
                        )
                        
                        // Who receives the data
                        ConsentDetailRow(
                            icon: "person.2.fill",
                            title: "資料接收方",
                            description: "您的資料將發送給：\n• AIML API / Anthropic Claude Sonnet 4.5\n\n此服務提供商不會將您的資料用於訓練 AI 模型，僅用於為您生成個人化的生命藍圖建議。"
                        )
                        
                        // What it's used for
                        ConsentDetailRow(
                            icon: "sparkles",
                            title: "使用目的",
                            description: "您的資料將用於：\n• 生成個人化的 AI 分析總結\n• 生成專屬的生命藍圖與職涯建議\n• 提供個人化的行動計劃建議"
                        )
                        
                        // Privacy protection
                        ConsentDetailRow(
                            icon: "lock.shield.fill",
                            title: "隱私保護",
                            description: "重要說明：\n• 我們不會發送任何個人識別資訊（如姓名、電子郵件、電話號碼）給 AI 服務\n• 所有資料傳輸均使用 HTTPS 加密\n• 您的資料僅用於生成建議，不會用於其他目的"
                        )
                    }
                }
                .padding(BrandSpacing.xl)
                .background(BrandColors.secondaryBackground)
                .cornerRadius(BrandRadius.medium)
                .shadow(color: BrandShadow.medium.color, radius: BrandShadow.medium.radius, x: BrandShadow.medium.x, y: BrandShadow.medium.y)
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                
                // Privacy Policy Link
                Button(action: {
                    showPrivacyPolicy = true
                }) {
                    HStack(spacing: BrandSpacing.sm) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 14))
                        Text("查看完整隱私政策")
                            .font(BrandTypography.subheadline)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(BrandColors.actionAccent)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                
                // Consent Checkbox
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        hasReadTerms.toggle()
                    }
                }) {
                    HStack(alignment: .top, spacing: BrandSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(hasReadTerms ? BrandColors.actionAccent : Color.clear)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(hasReadTerms ? BrandColors.actionAccent : BrandColors.borderColor, lineWidth: 2)
                                )
                            
                            if hasReadTerms {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(
                                        // CRITICAL: Ensure proper contrast
                                        // Checkmark should be white on purple background
                                        Color.white
                                    )
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                            Text("我已閱讀並同意上述說明")
                                .font(BrandTypography.body)
                                .fontWeight(.semibold)
                                .foregroundColor(BrandColors.primaryText)
                            
                            Text("我理解我的問卷資料將被發送給第三方 AI 服務（AIML API / Anthropic Claude Sonnet 4.5）以生成個人化的生命藍圖建議")
                                .font(BrandTypography.caption)
                                .foregroundColor(BrandColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                
                // Continue Button
                Button(action: {
                    if hasReadTerms {
                        viewModel.saveAIConsentStatus() // Save consent persistently
                        viewModel.moveToNextStep()
                    }
                }) {
                    HStack(spacing: BrandSpacing.sm) {
                        Text("我同意並繼續")
                            .font(BrandTypography.headline)
                            .fontWeight(.bold)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(
                        // CRITICAL: Ensure proper contrast
                        // Enabled: White text on purple background
                        // Disabled: Muted gray text
                        hasReadTerms 
                            ? Color.white
                            : (themeManager.isDarkMode ? Color(hex: "9CA3AF") : Color(hex: "8E8E93"))
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        hasReadTerms 
                            ? BrandColors.actionAccent 
                            : (themeManager.isDarkMode ? Color(hex: "333333") : Color(hex: "E2DDFF"))
                    )
                    .clipShape(Capsule())
                    .shadow(
                        color: hasReadTerms 
                            ? BrandColors.buttonShadow.color 
                            : Color.clear,
                        radius: BrandColors.buttonShadow.radius,
                        x: BrandColors.buttonShadow.x,
                        y: BrandColors.buttonShadow.y
                    )
                }
                .buttonStyle(.plain)
                .disabled(!hasReadTerms)
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                .padding(.top, BrandSpacing.lg)
                .padding(.bottom, BrandSpacing.xxxl)
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
            }
            .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }
}

struct ConsentDetailRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: BrandSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(BrandColors.actionAccent)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                Text(title)
                    .font(BrandTypography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(BrandColors.primaryText)
                
                Text(description)
                    .font(BrandTypography.caption)
                    .foregroundColor(BrandColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                    Text("LifeLab 隱私政策")
                        .font(BrandTypography.largeTitle)
                        .foregroundColor(BrandColors.primaryText)
                        .padding(.top, BrandSpacing.lg)
                    
                    Text("最後更新日期：2026年2月21日")
                        .font(BrandTypography.caption)
                        .foregroundColor(BrandColors.secondaryText)
                    
                    // Key sections relevant to AI consent
                    VStack(alignment: .leading, spacing: BrandSpacing.xl) {
                        SectionView(
                            title: "1. 資料收集",
                            content: """
                            我們收集以下資料以提供 LifeLab 服務：
                            • 個人基本資料（可選）：地區、年齡、稱謂、職業、年薪、家庭狀況、教育程度
                            • 興趣與優勢：您選擇的興趣關鍵字、優勢問卷回答、優勢關鍵詞
                            • 價值觀：核心價值觀排序與問卷回答
                            • 深化探索資料（可選）：心流日記、價值觀反思、資源盤點、後天強項、可行性評估
                            
                            重要說明：
                            • 我們不會收集您的姓名、電話號碼或設備識別碼
                            • 基本資料和深化探索資料為可選填寫，您可以選擇不提供
                            """
                        )
                        
                        SectionView(
                            title: "2. 資料使用",
                            content: """
                            AI 服務使用：
                            • 我們僅在您明確同意後，才會將您提供的資料發送給第三方 AI 服務（AIML API / Anthropic Claude Sonnet 4.5）
                            • 發送給 AI 服務的資料不包含任何個人識別資訊（如姓名、電子郵件、電話號碼）
                            • AI 服務提供商不會將您的資料用於訓練 AI 模型
                            • 您的資料僅用於生成個人化的生命藍圖與職涯建議
                            
                            重要說明：
                            • 我理解我的問卷資料將被發送給第三方 AI 服務（AIML API / Anthropic Claude Sonnet 4.5）以生成個人化的生命藍圖建議
                            • 發送的資料包括：興趣關鍵詞、天賦問卷回答與關鍵詞、價值觀排序與回答、基本資料（如已填寫）、深化探索資料（如已填寫）
                            • 我們不會發送任何個人識別資訊（如姓名、電子郵件、電話號碼、設備識別碼）給 AI 服務
                            """
                        )
                        
                        SectionView(
                            title: "6. 第三方服務",
                            content: """
                            AI 服務（AIML API / Anthropic Claude Sonnet 4.5）：
                            • 用於生成個人化生命藍圖與職涯建議
                            • 我們僅在您明確同意後，才會將您提供的資料發送給 AI 服務
                            • 我們不會發送任何個人識別資訊（如姓名、電子郵件、電話號碼）給 AI 服務
                            • 所有資料傳輸均使用 HTTPS 加密
                            • AI 服務提供商不會將您的資料用於訓練 AI 模型（根據 AIML API 的隱私政策）
                            """
                        )
                    }
                    
                    // Link to full privacy policy
                    Link(destination: URL(string: "https://lifelab-tau.vercel.app/privacy.html")!) {
                        HStack {
                            Text("查看完整隱私政策")
                                .font(BrandTypography.subheadline)
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(BrandColors.actionAccent)
                    }
                    .padding(.top, BrandSpacing.lg)
                }
                .padding(BrandSpacing.xl)
            }
            .navigationTitle("隱私政策")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(BrandColors.actionAccent)
                }
            }
        }
    }
}

struct SectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
            Text(title)
                .font(BrandTypography.headline)
                .fontWeight(.bold)
                .foregroundColor(BrandColors.primaryText)
            
            Text(content)
                .font(BrandTypography.body)
                .foregroundColor(BrandColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(BrandSpacing.md)
        .background(BrandColors.secondaryBackground)
        .cornerRadius(BrandRadius.medium)
    }
}

#Preview {
    AIConsentView()
        .environmentObject(InitialScanViewModel())
}
