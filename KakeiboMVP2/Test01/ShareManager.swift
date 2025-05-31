import CoreData
import CloudKit

final class ShareManager {
    static let shared = ShareManager()
    private init() {}

    func share(objects objectIDs: [NSManagedObjectID],
               in container: NSPersistentCloudKitContainer,
               completion: @escaping (Result<CKShare,Error>) -> Void) {

        let context = container.viewContext
        let objectsToShare = objectIDs.map { context.object(with: $0) }

        container.share(objectsToShare, to: nil) { sharedObjectIDs, share, ckContainer, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let share = share else {
                let err = NSError(domain: "ShareManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing CKShare"])
                completion(.failure(err))
                return
            }
            share[CKShare.SystemFieldKey.title] = "家計簿を共有" as CKRecordValue
            do {
                try context.save()
                completion(.success(share))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
