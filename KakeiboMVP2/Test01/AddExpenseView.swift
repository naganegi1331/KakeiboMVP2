
import SwiftUI
import CoreData

struct AddExpenseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
        animation: .default
    ) private var items: FetchedResults<Expense>
    
    @State private var inputAmount: String = ""
    @State private var inputMemo: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
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
                .padding()
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
}




#Preview {
    AddExpenseView()
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//
}
