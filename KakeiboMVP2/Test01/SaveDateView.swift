//
//  TestView.swift
//  KakeiboMVP2
//
//  Created by Hiroki Kashihara on 2025/05/16.
//

import SwiftUI
import CoreData

struct SaveDateView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.date, order: .reverse)],
        animation: .default
    )
    private var items: FetchedResults<Expense>
    
    var body: some View {
        NavigationView {
            VStack {
                Button("+ Save the current time"){
                    addItem()

                }
                .padding()
                
                List {
                    ForEach(items) { item in
                        if item.date != nil {
                            Text(item.date!, formatter: itemFormatter)

                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            
        }
        .navigationTitle("Time log")
    }
    
    
    private func addItem() {
        withAnimation {


            let newItem = Expense(context: viewContext)
            newItem.date = Date()
            newItem.id = UUID()
            
            

            do {
                try viewContext.save()
                print("✅ 保存成功")
            } catch {
                print("保存に失敗しました: \(error.localizedDescription)")
            }

            print("📤 保存後のデータ:")
            for item in items {
                print("・\(item.objectID) \(item.date?.description ?? "nil")")
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            viewContext.delete(item)
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError(
                "Unresolved error \(nsError), \(nsError.userInfo)"
            )
        }
    }
    
}
/// 日付と時刻を簡潔に表示するための DateFormatter（短い日付形式 + 中程度の時刻形式）
/// 例: "5/17/25, 8:45:30 PM"
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    SaveDateView()

    //        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    
}
