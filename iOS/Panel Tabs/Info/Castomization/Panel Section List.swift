import SwiftUI

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

import SwiftUI

struct ContentView: View {
    @State private var vm = PanelSectionListVM()
    
    var body: some View {
        List {
            Section {
                Text("Reorder or hide sections to personalize your view")
                    .foregroundStyle(.secondary)
                    .padding(-20)
            }
            .listRowBackground(Color.clear)
            
            ForEach(vm.items) { item in
                ItemRowView(item: item) {
                    vm.toggle(item)
                    vm.save()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .onMove { from, to in
                vm.move(from: from, to: to)
            }
        }
        .navigationTitle("Customize & Reorder")
        .environment(\.editMode, .constant(.active))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Reset", role: .destructive) {
                    vm.items = [
                        .init("Resource Usage"),
                        .init("Allocations"),
                        .init("Users"),
                        .init("Logs"),
                        .init("Subdomains"),
                        .init("Location")
                    ]
                    
                    vm.save()
                }
                .foregroundStyle(.red.gradient)
                .semibold()
            }
        }
    }
}

#Preview {
    ContentView()
        .darkSchemePreferred()
}
