import SwiftUI

// デバッグ画面用のView
struct DebugView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("デバッグ画面")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            VStack(spacing: 15) {
                Button("Fetch and print all Expense records from SharedDB for debugging") {
                    CloudDebugger.fetchExpenses()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.blue)
                
                Button("Fetch and print all Expense records from SharedDB for debugging") {
                    CloudDebugger.fetchSharedExpenses()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.green)
                
                Button("Fetch and print all shared records (CKShare) for debugging") {
                    CloudDebugger.fetchShares()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.green)
                
                Button("Comprehensive debug function that fetches from both databases and shares") {
                    CloudDebugger.debugAll()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.green)
                
                Button("Check CloudKit account status for debugging") {
                    CloudDebugger.checkAccountStatus()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.green)
            }
            
            Spacer()
        }
        .navigationTitle("デバッグ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DebugView()
}
