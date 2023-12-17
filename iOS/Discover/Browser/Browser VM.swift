import ScrechKit
import CloudKit

@Observable
final class BrowserVM {
    var chosenLink = ""
    var filterRule = "Minecraft"
    var currencyImg = "rublesign.square"
    var showSafari = false
    var planDictionary: [CKRecord.ID: Plan] = [:]
    private let db = CKContainer.default().publicCloudDatabase
    
    private var plans: [Plan] {
        planDictionary.values.compactMap { $0 }
    }
    
    var sortedPlans: [Plan] {
        plans.sorted {
            $0.disk < $1.disk
        }
    }
    
    var filteredPlans: [Plan] {
        if filterRule.isEmpty {
            sortedPlans
        } else {
            sortedPlans.filter {
                $0.type.lowercased().contains(filterRule.lowercased())
            }
        }
    }
    
    func fetchPlans() async {
        do {
            try await populatePlans()
        } catch {
            print("Error loading plans: \(error)")
        }
    }
    
    func populatePlans() async throws {
        let query = CKQuery(recordType: PlanRecordKeys.type.rawValue, predicate: NSPredicate(value: true))

        let result = try await db.records(matching: query)
        
        let records = result.matchResults.compactMap {
            try? $0.1.get()
        }
        
        let plans = records.compactMap {
            Plan(record: $0)
        }
        
        main {
            withAnimation {
                self.planDictionary = Dictionary(uniqueKeysWithValues: plans.map {
                    ($0.recordId!, $0)
                })
            }
        }
    }
    
    func currencyImage(_ currency: String) -> String {
        switch currency {
        case "₽":
            "rublesign.square"
            
        case "€":
            "eurosign.square"
            
        case "$":
            "dollarsign.square"
            
        default:
            "exclamationmark.triangle"
        }
    }
}
