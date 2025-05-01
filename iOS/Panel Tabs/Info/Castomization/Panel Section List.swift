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
                PanelSectionRow(item: item) {
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
