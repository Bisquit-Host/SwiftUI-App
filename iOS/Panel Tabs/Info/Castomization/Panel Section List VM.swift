import Foundation

@Observable
class PanelSectionListVM {
    var items: [PanelSection] = []
    
    private let storageKey = "savedItems"
    
    init() {
        load()
    }
    
    func toggle(_ item: PanelSection) {
        guard let index = items.firstIndex(of: item) else {
            return
        }
        
        items[index].isChecked.toggle()
        save()
    }
    
    func move(from: IndexSet, to: Int) {
        items.move(fromOffsets: from, toOffset: to)
        save()
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(items) else {
            print("❌ Save error")
            return
        }
        
        UserDefaults.standard.set(data, forKey: storageKey)
        
        print("✅ Saved")
    }
    
    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([PanelSection].self, from: data)
        else {
            items = [
                .init("Resource Usage"),
                .init("Allocations"),
                .init("Users"),
                .init("Logs"),
                .init("Subdomains"),
                .init("Map")
            ]
            
            return
        }
        
        items = decoded
    }
}
