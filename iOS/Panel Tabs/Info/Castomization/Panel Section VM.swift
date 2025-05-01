import Foundation

@Observable
class PanelSectionVM {
    var sections: [PanelSection] = []
    
    var activeSections: [PanelSection] {
        sections.filter(\.isChecked)
    }
    
    let defaultSections: [PanelSection] = [
        .init("Resource Usage"),
        .init("Allocations"),
        .init("Users"),
        .init("Logs"),
        .init("Subdomains"),
        .init("Location")
    ]
    
    private let storageKey = "savedItems"
    
    init() {
        load()
    }
    
    func toggle(_ item: PanelSection) {
        guard let index = sections.firstIndex(of: item) else {
            return
        }
        
        sections[index].isChecked.toggle()
        save()
    }
    
    func move(from: IndexSet, to: Int) {
        sections.move(fromOffsets: from, toOffset: to)
        save()
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(sections) else {
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
            sections = defaultSections
            
            return
        }
        
        sections = decoded
    }
}
