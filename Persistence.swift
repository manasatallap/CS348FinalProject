import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Cycle")
        container.loadPersistentStores { (storeDescription, error) in
                if let error = error as NSError? {
                    // Print descriptive error message instead of fatalError
                    print("Error loading persistent store: \(error), \(error.userInfo)")
                    // Handle the error gracefully
                }
            }
    }

    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
