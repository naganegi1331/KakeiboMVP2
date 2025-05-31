import SwiftUI
import CoreData
import CloudKit

struct AddExpenseView: View {
    // Wrapper to allow UICloudSharingController to be used with .sheet(item:)
    struct CloudShareControllerWrapper: Identifiable {
        let id = UUID()
        let controller: UICloudSharingController
    }

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
        animation: .default
    ) private var items: FetchedResults<Expense>
    
    @State private var inputAmount: String = ""
    @State private var inputMemo: String = ""
    @State private var monthlyBudget: Double = 0
    @State private var shareController: CloudShareControllerWrapper?
    
    var body: some View {
        NavigationView {
            VStack {
                
                Text("合計金額: \(totalAmount, format: .currency(code: "JPY"))")
                    .font(.headline)
                    .padding()
                
                VStack(alignment: .leading) {
                    Text("今月の予算: \(Int(monthlyBudget), format: .currency(code: "JPY"))")
                        .font(.subheadline)
                    
                    TextField("予算を入力", value: $monthlyBudget, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .padding()
                    
                    
                    ProgressView(value: budgetProgress)
                        .progressViewStyle(.linear)
                        .accentColor(budgetProgress >= 1.0 ? .red : .blue)
                    
                }.padding(.horizontal)
                
                TextField("支出金額を入力", text: $inputAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .padding()
                
                TextField("memoを入力", text: $inputMemo)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.default)
                    .padding()
                
                Button {
                    addExpense()
                } label: {
                    Label("保存", systemImage: "square.and.arrow.up")
                }

                // デバッグ画面への遷移ボタンを追加
                NavigationLink(destination: DebugView()) {
                    Label("デバッグ画面", systemImage: "gear")
                        .foregroundColor(.orange)
                }
                .padding(.top, 10)
                
                Button("家族と共有") {
                    let ids = items.map(\.objectID)
                    ShareManager.shared.share(objects: ids, in: PersistenceController.shared.container) { result in
                        switch result {
                        case .success(let ckShare):
                            let uiController = UICloudSharingController(share: ckShare,
                                                                        container: CloudContainer.shared)
                            shareController = CloudShareControllerWrapper(controller: uiController)
                        case .failure(let e):
                            print("Share error:", e)
                        }
                    }
                }
                .sheet(item: $shareController) { wrapper in
                    ShareSheet(controller: wrapper.controller)
                }
                
                
                List {
                    ForEach(items) { item in
                        HStack {
                            Text(item.amount, format: .currency(code: "JPY"))
                            Spacer()
                            Text(item.memo ?? "")
                            Spacer()
                            if let date = item.date {
                                Text(date, formatter: itemFormatter)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(PlainListStyle())
                .navigationTitle("支出追加")
            }
        }
    }
    
    private func addExpense() {
        guard let amount = Double(inputAmount) else { return }
        let newExpense = Expense(context: viewContext)
        newExpense.amount = amount
        newExpense.memo = inputMemo
        newExpense.date = Date()
        newExpense.id = UUID()
        do {
            try viewContext.save()
            inputAmount = ""
            inputMemo = ""
            
        } catch {
            print("保存失敗: \(error.localizedDescription)")
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        offsets.forEach { index in
            viewContext.delete(items[index])
        }
        do {
            try viewContext.save()
        } catch {
            print("削除失敗: \(error.localizedDescription)")
        }
    }
    
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private var totalAmount: Double {
        items.reduce(0) {$0 + $1.amount}
    }
    
    private var budgetProgress: Double {
        guard monthlyBudget > 0 else { return 0 }
        return min(totalAmount / monthlyBudget, 1)
    }
    
    struct ShareSheet: UIViewControllerRepresentable {
        let controller: UICloudSharingController
        func makeUIViewController(context: Context) -> UICloudSharingController { controller }
        func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {}
    }
}



#Preview {
    AddExpenseView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
