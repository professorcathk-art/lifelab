import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let profile = dataService.userProfile {
                        VStack(spacing: 16) {
                            Text("個人檔案")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 32)
                            
                            if !profile.interests.isEmpty {
                                ProfileSection(title: "興趣", items: profile.interests)
                            }
                            
                            if !profile.strengths.isEmpty {
                                ProfileSection(title: "天賦", items: profile.strengths.flatMap { $0.selectedKeywords })
                            }
                            
                            if !profile.values.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("核心價值觀")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 20)
                                    
                                    ForEach(profile.values.sorted { $0.rank < $1.rank }.prefix(5)) { value in
                                        HStack {
                                            Text("\(value.rank). \(value.value.rawValue)")
                                                .font(.headline)
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("尚未建立個人檔案")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("個人檔案")
        }
    }
}

struct ProfileSection: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(DataService.shared)
}
