import Foundation
import CloudKit

struct CloudDebugger {
    /// Fetch and print all Expense records stored in CloudKit for debugging.
    static func fetchExpenses() {
        let container = CloudContainer.shared
        let database = container.privateCloudDatabase
//        let database = container.sharedCloudDatabase
        
        let query = CKQuery(recordType: "CD_Expense", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        
        var fetchedRecords: [CKRecord] = []

        operation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                fetchedRecords.append(record)
            case .failure(let error):
                print("CloudKit record error for \(recordID): \(error.localizedDescription)")
            }
        }
        operation.queryResultBlock = { result in
            switch result {
            case .failure(let error):
                print("CloudKit fetch error: \(error.localizedDescription)")
            case .success(_):
                // On success, the fetchedRecords list is already populated via recordMatchedBlock
                print("Faetched \(fetchedRecords.count) Expense records from CloudKit:")
                fetchedRecords.forEach { record in
                    let amount = record["CD_amount"] as? Double ?? 0
                    let date = record["CD_date"] as? Date ?? Date.distantPast
                    let memo = record["CD_memo"] as? String ?? ""
                    print("• ID: \(record.recordID.recordName), amount: \(amount), memo: '\(memo)', date: \(date)")
                }
            }
        }
        database.add(operation)
    }
    
    /// Fetch and print all Expense records from SharedDB for debugging.
    static func fetchSharedExpenses() {
        let container = CloudContainer.shared
        let database = container.sharedCloudDatabase
        
        let query = CKQuery(recordType: "CD_Expense", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        
        var fetchedRecords: [CKRecord] = []

        operation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                fetchedRecords.append(record)
            case .failure(let error):
                print("SharedDB record error for \(recordID): \(error.localizedDescription)")
            }
        }
        operation.queryResultBlock = { result in
            switch result {
            case .failure(let error):
                print("SharedDB fetch error: \(error.localizedDescription)")
            case .success(_):
                print("Fetched \(fetchedRecords.count) Expense records from SharedDB:")
                fetchedRecords.forEach { record in
                    let amount = record["CD_amount"] as? Double ?? 0
                    let date = record["CD_date"] as? Date ?? Date.distantPast
                    let memo = record["CD_memo"] as? String ?? ""
                    let shareInfo = record.share != nil ? "Shared" : "Not shared"
                    print("• ID: \(record.recordID.recordName), amount: \(amount), memo: '\(memo)', date: \(date), status: \(shareInfo)")
                }
            }
        }
        database.add(operation)
    }
    
    /// Fetch and print all shared records (CKShare) for debugging.
    static func fetchShares() {
        let container = CloudContainer.shared
        let database = container.privateCloudDatabase // Shares are stored in private database
        
        let query = CKQuery(recordType: "cloudkit.share", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        
        var fetchedShares: [CKShare] = []

        operation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                if let share = record as? CKShare {
                    fetchedShares.append(share)
                }
            case .failure(let error):
                print("Share record error for \(recordID): \(error.localizedDescription)")
            }
        }
        operation.queryResultBlock = { result in
            switch result {
            case .failure(let error):
                print("Shares fetch error: \(error.localizedDescription)")
            case .success(_):
                print("Fetched \(fetchedShares.count) shares:")
                fetchedShares.forEach { share in
                    let ownerEmail = share.owner.userIdentity.lookupInfo?.emailAddress ?? "Unknown"
                    let participantCount = share.participants.count
                    let shareURL = share.url?.absoluteString ?? "No URL"
                    print("• Share ID: \(share.recordID.recordName)")
                    print("  Owner: \(ownerEmail)")
                    print("  Participants: \(participantCount)")
                    print("  URL: \(shareURL)")
                    // Note: Root record information may need to be fetched separately
                    print("  Share Record ID: \(share.recordID.recordName)")
                }
            }
        }
        database.add(operation)
    }
    
    /// Comprehensive debug function that fetches from both databases and shares.
    static func debugAll() {
        print("=== CloudKit Debug Information ===")
        print("\n1. Private Database Expenses:")
        fetchExpenses()
        
        print("\n2. Shared Database Expenses:")
        fetchSharedExpenses()
        
        print("\n3. Shares Information:")
        fetchShares()
    }
    
    /// Check CloudKit account status for debugging.
    static func checkAccountStatus() {
        let container = CloudContainer.shared
        
        container.accountStatus { accountStatus, error in
            if let error = error {
                print("Account status error: \(error.localizedDescription)")
                return
            }
            
            switch accountStatus {
            case .available:
                print("CloudKit account: Available")
            case .noAccount:
                print("CloudKit account: No iCloud account")
            case .restricted:
                print("CloudKit account: Restricted")
            case .couldNotDetermine:
                print("CloudKit account: Could not determine")
            case .temporarilyUnavailable:
                print("CloudKit account: Temporarily unavailable")
            @unknown default:
                print("CloudKit account: Unknown status")
            }
        }
    }
}
