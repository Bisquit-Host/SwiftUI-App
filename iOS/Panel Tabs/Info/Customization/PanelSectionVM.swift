import Foundation
import PteroNet

@Observable
class PanelSectionVM {
    var sections: [PanelSection] = []
    
    var activeSections: [PanelSection] {
        sections.filter(\.isChecked)
    }
    
    let defaultSections: [PanelSection] = [
        .init("Resource Graphs"),
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
            Logger().error("Save error")
            return
        }
        
        UserDefaults.standard.set(data, forKey: storageKey)
        
        Logger().info("Saved")
    }
    
    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? BigAssDecoder.decode([PanelSection].self, from: data)
        else {
            sections = defaultSections
            
            return
        }
        
        var updated = decoded.filter { section in
            defaultSections.contains(where: { $0.name == section.name })
        }
        
        for item in defaultSections where !updated.contains(where: { $0.name == item.name }) {
            updated.append(item)
        }
        
        sections = updated
    }
}
