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
    
    // Common regions - Expanded list
    let regions = [
        "香港", "台灣", "中國大陸", "新加坡", "馬來西亞", "泰國", "日本", "韓國",
        "美國", "加拿大", "澳洲", "紐西蘭", "英國", "愛爾蘭", "法國", "德國", "荷蘭", "瑞士", "西班牙", "義大利",
        "其他"
    ]
    
    var body: some View {
        ZStack {
            // Pure black background - NO gradients
            BrandColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: BrandSpacing.xxl) {
                        // Header Section
                        VStack(spacing: BrandSpacing.lg) {
                            // Hero Icon - Clean yellow circle, NO glow/shadow
                            ZStack {
                                Circle()
                                    .fill(BrandColors.brandAccent) // #FFC107
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.text.rectangle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(BrandColors.invertedText) // Black icon
                            }
                            // NO shadow, NO glow - clean and flat
                            
                            VStack(spacing: BrandSpacing.sm) {
                                Text("基本資料")
                                    .font(BrandTypography.largeTitle)
                                    .foregroundColor(BrandColors.primaryText) // Pure white
                                
                                Text("請填寫您的基本資料，這將幫助AI為您提供更精準的建議")
                                    .font(BrandTypography.body)
                                    .foregroundColor(BrandColors.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                            }
                        }
                        .padding(.top, BrandSpacing.xxxl)
                        
                        // Form Fields
                        VStack(spacing: BrandSpacing.lg) {
                            // Region Dropdown
                            ModernFormField(title: "居住地區 *", icon: "location.fill") {
                                CustomPicker(
                                    selection: $selectedRegion,
                                    placeholder: "請選擇",
                                    options: regions
                                )
                            }
                            
                            // Age Input
                            ModernFormField(title: "年齡 *", icon: "calendar") {
                                CustomTextField(
                                    placeholder: "例如：28",
                                    text: $ageText,
                                    keyboardType: .numberPad
                                )
                            }
                            
                            // Name Input
                            ModernFormField(title: "稱呼 *", icon: "person.fill") {
                                CustomTextField(
                                    placeholder: "例如：小明",
                                    text: $nameText
                                )
                            }
                            
                            // Occupation Input
                            ModernFormField(title: "職業 *", icon: "briefcase.fill") {
                                CustomTextField(
                                    placeholder: "例如：軟體工程師",
                                    text: $occupationText
                                )
                            }
                            
                            // Annual Salary (Optional)
                            ModernFormField(title: "年薪（USD，可選）", icon: "dollarsign.circle.fill") {
                                HStack {
                                    CustomTextField(
                                        placeholder: "例如：50000",
                                        text: $salaryText,
                                        keyboardType: .numberPad
                                    )
                                    Text("USD")
                                        .font(BrandTypography.body)
                                        .foregroundColor(BrandColors.secondaryText)
                                }
                            } footer: {
                                Text("此資訊僅用於提供更精準的市場分析，不會公開")
                                    .font(BrandTypography.caption)
                                    .foregroundColor(BrandColors.tertiaryText)
                            }
                            
                            // Family Status Dropdown
                            ModernFormField(title: "家庭狀況 *", icon: "house.fill") {
                                CustomPicker(
                                    selection: Binding(
                                        get: { selectedFamilyStatus?.rawValue ?? "" },
                                        set: { newValue in
                                            selectedFamilyStatus = BasicUserInfo.FamilyStatus.allCases.first { $0.rawValue == newValue }
                                        }
                                    ),
                                    placeholder: "請選擇",
                                    options: BasicUserInfo.FamilyStatus.allCases.map { $0.rawValue }
                                )
                            }
                            
                            // Education Dropdown
                            ModernFormField(title: "學歷 *", icon: "graduationcap.fill") {
                                CustomPicker(
                                    selection: Binding(
                                        get: { selectedEducation?.rawValue ?? "" },
                                        set: { newValue in
                                            selectedEducation = BasicUserInfo.EducationLevel.allCases.first { $0.rawValue == newValue }
                                        }
                                    ),
                                    placeholder: "請選擇",
                                    options: BasicUserInfo.EducationLevel.allCases.map { $0.rawValue }
                                )
                            }
                        }
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        .padding(.bottom, 100) // Space for fixed button
                        .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Fixed Bottom Button
                VStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            saveBasicInfo()
                            viewModel.moveToNextStep()
                        }
                    }) {
                        HStack(spacing: BrandSpacing.sm) {
                            Text("繼續")
                                .font(BrandTypography.headline)
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(BrandColors.invertedText) // Black text
                        .frame(maxWidth: .infinity)
                        .frame(height: 50) // Fixed height
                        .background(BrandColors.primaryText) // White background
                        .clipShape(Capsule()) // Pill shape
                    }
                    .buttonStyle(.plain)
                    .disabled(!canContinue)
                    .opacity(canContinue ? 1.0 : 0.5)
                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    .padding(.bottom, BrandSpacing.lg)
                    .padding(.top, BrandSpacing.md)
                    .background(BrandColors.background) // Pure black background for button area
                    .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                }
            }
        }
        .preferredColorScheme(ThemeManager.shared.isDarkMode ? .dark : .light)
        .onAppear {
            // Load existing data from viewModel when view appears (for review mode)
            if let region = viewModel.basicInfo.region, !region.isEmpty {
                selectedRegion = region
            }
            if let age = viewModel.basicInfo.age {
                ageText = String(age)
            }
            if let name = viewModel.basicInfo.name, !name.isEmpty {
                nameText = name
            }
            if let occupation = viewModel.basicInfo.occupation, !occupation.isEmpty {
                occupationText = occupation
            }
            if let salary = viewModel.basicInfo.annualSalaryUSD {
                salaryText = String(salary)
            }
            selectedFamilyStatus = viewModel.basicInfo.familyStatus
            selectedEducation = viewModel.basicInfo.education
        }
        .onChange(of: selectedRegion) { _ in
            saveBasicInfo()
        }
        .onChange(of: ageText) { _ in
            saveBasicInfo()
        }
        .onChange(of: nameText) { _ in
            saveBasicInfo()
        }
        .onChange(of: occupationText) { _ in
            saveBasicInfo()
        }
        .onChange(of: salaryText) { _ in
            saveBasicInfo()
        }
        .onChange(of: selectedFamilyStatus) { _ in
            saveBasicInfo()
        }
        .onChange(of: selectedEducation) { _ in
            saveBasicInfo()
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

// MARK: - Modern Form Field Component (Dark Mode Neon-Minimalist)
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
            // Label with purple icon and white text
            HStack(spacing: BrandSpacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(BrandColors.actionAccent) // Purple #8B5CF6
                    .font(.system(size: 16))
                Text(title)
                    .font(BrandTypography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(BrandColors.primaryText) // Pure white
            }
            
            // Input field content
            content()
            
            // Footer if provided
            if !(footer() is EmptyView) {
                footer()
            }
        }
    }
}

// MARK: - Custom Text Field (Dark Mode)
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Placeholder text (shown when empty)
            if text.isEmpty {
                Text(placeholder)
                    .font(BrandTypography.body)
                    .foregroundColor(Color(hex: "8E8E93")) // Light gray #8E8E93 for placeholder
                    .padding(.horizontal, BrandSpacing.md)
            }
            
            TextField("", text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .foregroundColor(BrandColors.primaryText) // Pure white text
                .font(BrandTypography.body)
                .focused($isFocused)
                .padding(.horizontal, BrandSpacing.md)
        }
        .frame(height: 50) // Fixed height for better tap target
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(BrandColors.surface) // #1C1C1E
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? BrandColors.actionAccent.opacity(0.5) : BrandColors.borderColor, lineWidth: 1)
        )
        .accentColor(BrandColors.actionAccent) // Purple cursor
    }
}

// MARK: - Custom Picker (Dark Mode - Looks like Input Field)
struct CustomPicker: View {
    @Binding var selection: String
    let placeholder: String
    let options: [String]
    @State private var showPicker = false
    
    var body: some View {
        Button(action: {
            showPicker = true
        }) {
            HStack {
                Text(selection.isEmpty ? placeholder : selection)
                    .font(BrandTypography.body)
                    .foregroundColor(selection.isEmpty ? Color(hex: "8E8E93") : BrandColors.primaryText) // Placeholder: #8E8E93, Selected: white
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(BrandColors.actionAccent) // Purple chevron
            }
            .frame(height: 50) // Fixed height
            .padding(.horizontal, BrandSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(BrandColors.surface) // #1C1C1E
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(BrandColors.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {
            NavigationStack {
                List {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selection = option
                            showPicker = false
                        }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(BrandColors.primaryText)
                                Spacer()
                                if selection == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(BrandColors.actionAccent)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle()) // Expand tap area to entire row
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(BrandColors.background)
                .scrollContentBackground(.hidden)
                .navigationTitle("選擇")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            showPicker = false
                        }
                        .foregroundColor(BrandColors.actionAccent)
                    }
                }
            }
            .preferredColorScheme(ThemeManager.shared.isDarkMode ? .dark : .light)
        }
    }
}

#Preview {
    BasicInfoView()
        .environmentObject(InitialScanViewModel())
}
