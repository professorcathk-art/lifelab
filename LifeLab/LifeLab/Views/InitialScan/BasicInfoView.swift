import SwiftUI

struct BasicInfoView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @State private var selectedRegion: String = ""
    @State private var ageText: String = ""
    @State private var nameText: String = ""
    @State private var occupationText: String = ""
    @State private var salaryText: String = ""
    @State private var selectedFamilyStatus: BasicUserInfo.FamilyStatus? = nil
    @State private var selectedEducation: BasicUserInfo.EducationLevel? = nil
    
    // Common regions
    let regions = ["香港", "台灣", "中國大陸", "新加坡", "美國", "加拿大", "澳洲", "英國", "其他"]
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                colors: [
                    Color(hex: "667eea").opacity(0.1),
                    Color(hex: "764ba2").opacity(0.1),
                    Color(hex: "f093fb").opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: BrandSpacing.xl) {
                    VStack(spacing: BrandSpacing.lg) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(BrandColors.primaryGradient)
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.text.rectangle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.white)
                        }
                        .shadow(color: BrandColors.primaryBlue.opacity(0.3), radius: 15, x: 0, y: 8)
                        
                        VStack(spacing: BrandSpacing.sm) {
                            Text("基本資料")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(BrandColors.primaryText)
                            
                            Text("請填寫您的基本資料，這將幫助AI為您提供更精準的建議")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(BrandColors.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, BrandSpacing.xl)
                        }
                    }
                    .padding(.top, BrandSpacing.xxxl)
                    
                    VStack(spacing: BrandSpacing.lg) {
                        // Region
                        ModernFormField(title: "居住地區 *", icon: "location.fill") {
                            Picker("居住地區", selection: $selectedRegion) {
                                Text("請選擇").tag("")
                                ForEach(regions, id: \.self) { region in
                                    Text(region).tag(region)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        // Age
                        ModernFormField(title: "年齡 *", icon: "calendar") {
                            TextField("例如：28", text: $ageText)
                                .keyboardType(.numberPad)
                        }
                        
                        // Name
                        ModernFormField(title: "稱呼 *", icon: "person.fill") {
                            TextField("例如：小明", text: $nameText)
                        }
                        
                        // Occupation
                        ModernFormField(title: "職業 *", icon: "briefcase.fill") {
                            TextField("例如：軟體工程師", text: $occupationText)
                        }
                        
                        // Annual Salary (Optional)
                        ModernFormField(title: "年薪（USD，可選）", icon: "dollarsign.circle.fill") {
                            HStack {
                                TextField("例如：50000", text: $salaryText)
                                    .keyboardType(.numberPad)
                                Text("USD")
                                    .foregroundColor(BrandColors.secondaryText)
                            }
                        } footer: {
                            Text("此資訊僅用於提供更精準的市場分析，不會公開")
                                .font(BrandTypography.caption)
                                .foregroundColor(BrandColors.tertiaryText)
                        }
                        
                        // Family Status
                        ModernFormField(title: "家庭狀況 *", icon: "house.fill") {
                            Picker("家庭狀況", selection: $selectedFamilyStatus) {
                                Text("請選擇").tag(nil as BasicUserInfo.FamilyStatus?)
                                ForEach(BasicUserInfo.FamilyStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status as BasicUserInfo.FamilyStatus?)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        // Education
                        ModernFormField(title: "學歷 *", icon: "graduationcap.fill") {
                            Picker("學歷", selection: $selectedEducation) {
                                Text("請選擇").tag(nil as BasicUserInfo.EducationLevel?)
                                ForEach(BasicUserInfo.EducationLevel.allCases, id: \.self) { level in
                                    Text(level.rawValue).tag(level as BasicUserInfo.EducationLevel?)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .padding(.horizontal, BrandSpacing.xl)
                    .padding(.bottom, BrandSpacing.md)
                    
                    // Continue Button
                    Button(action: {
                        saveBasicInfo()
                        viewModel.moveToNextStep()
                    }) {
                        HStack(spacing: BrandSpacing.sm) {
                            Text("繼續")
                                .font(.system(size: 18, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, BrandSpacing.lg)
                        .background(
                            canContinue ?
                            BrandColors.primaryGradient :
                            LinearGradient(colors: [BrandColors.tertiaryBackground], startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(16)
                        .shadow(color: canContinue ? BrandColors.primaryBlue.opacity(0.3) : .clear, radius: 15, x: 0, y: 8)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canContinue)
                    .padding(.horizontal, BrandSpacing.xl)
                    .padding(.bottom, BrandSpacing.xxxl)
                }
            }
        }
    }
    
    private var canContinue: Bool {
        !selectedRegion.isEmpty &&
        !ageText.isEmpty &&
        Int(ageText) != nil &&
        !nameText.isEmpty &&
        !occupationText.isEmpty &&
        selectedFamilyStatus != nil &&
        selectedEducation != nil
    }
    
    private func saveBasicInfo() {
        viewModel.basicInfo = BasicUserInfo(
            region: selectedRegion,
            age: Int(ageText),
            name: nameText,
            occupation: occupationText,
            annualSalaryUSD: salaryText.isEmpty ? nil : Int(salaryText),
            familyStatus: selectedFamilyStatus,
            education: selectedEducation
        )
    }
}

// Modern Form Field Component
struct ModernFormField<Content: View, Footer: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content
    @ViewBuilder let footer: () -> Footer
    
    init(title: String, icon: String, @ViewBuilder content: @escaping () -> Content, @ViewBuilder footer: @escaping () -> Footer = { EmptyView() }) {
        self.title = title
        self.icon = icon
        self.content = content
        self.footer = footer
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
            HStack(spacing: BrandSpacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(BrandColors.primaryBlue)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(BrandColors.primaryText)
            }
            
            content()
                .padding(BrandSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(BrandColors.secondaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(BrandColors.primaryBlue.opacity(0.2), lineWidth: 1)
                        )
                )
            
            if !(footer() is EmptyView) {
                footer()
            }
        }
    }
}

#Preview {
    BasicInfoView()
        .environmentObject(InitialScanViewModel())
}
