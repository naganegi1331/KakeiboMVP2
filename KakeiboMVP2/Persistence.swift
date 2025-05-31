import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newExpense = Expense(context: viewContext)
            newExpense.amount = Double(1000 * (i + 1))          // ダミー金額
            newExpense.memo   = "サンプル \(i + 1)"              // ダミーメモ
            newExpense.date   = Date()
            newExpense.id     = UUID()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "KakeiboMVP2")
        // --- CloudKit options ---
        if let desc = container.persistentStoreDescriptions.first {
            // iCloud コンテナ ID を自分の Team ID / Bundle に合わせて変更
            desc.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
//                containerIdentifier: "iCloud.com.org.KakeiboMVP"
                containerIdentifier: CloudContainer.identifier
            )
            // 履歴トラッキングとリモート通知を有効化
            desc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            desc.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        let persistentContainer = container
        persistentContainer.loadPersistentStores { [persistentContainer] (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
#if DEBUG
            do {
                try persistentContainer.initializeCloudKitSchema(options: [.printSchema])
                print("✅ Successfully initialized CloudKit schema")
            } catch {
                print("❌ Failed to initialize CloudKit schema: \(error)")
            }
#endif
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
