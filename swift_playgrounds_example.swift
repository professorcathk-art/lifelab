// LifeLab - Swift Playgrounds Example
// Copy this to Swift Playgrounds app on iPad/iPhone to test your UI

import SwiftUI
import PlaygroundSupport

// Example: Test your InitialScanView
struct TestInitialScan: View {
    @State private var selectedInterests: Set<String> = []
    @State private var timeRemaining = 60
    
    var body: some View {
        VStack(spacing: 20) {
            Text("興趣選擇")
                .font(.largeTitle)
                .bold()
            
            Text("剩餘時間: \(timeRemaining)秒")
                .font(.title2)
                .foregroundColor(.blue)
            
            // Example interest keywords
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(["設計", "程式", "音樂", "寫作", "攝影"], id: \.self) { interest in
                    Button(action: {
                        if selectedInterests.contains(interest) {
                            selectedInterests.remove(interest)
                        } else {
                            selectedInterests.insert(interest)
                        }
                    }) {
                        Text(interest)
                            .padding()
                            .background(selectedInterests.contains(interest) ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedInterests.contains(interest) ? .white : .primary)
                            .cornerRadius(8)
                    }
                }
            }
            
            Text("已選擇: \(selectedInterests.count) 個")
                .font(.caption)
        }
        .padding()
    }
}

// Example: Test your ValuesRankingView
struct TestValuesRanking: View {
    @State private var values = ["創造力", "穩定性", "影響力", "自由", "成長"]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(values, id: \.self) { value in
                    Text(value)
                        .font(.headline)
                }
                .onMove { from, to in
                    values.move(fromOffsets: from, toOffset: to)
                }
            }
            .navigationTitle("價值觀排序")
            .toolbar {
                EditButton()
            }
        }
    }
}

// Run the playground
PlaygroundPage.current.setLiveView(
    TabView {
        TestInitialScan()
            .tabItem {
                Label("興趣", systemImage: "heart.fill")
            }
        
        TestValuesRanking()
            .tabItem {
                Label("價值觀", systemImage: "list.number")
            }
    }
    .frame(width: 400, height: 600)
)
