import SwiftUI

struct LogListFilter: View {
    @Environment(LogVM.self) private var vm
    
    var body: some View {
        Menu {
            Section {
                Button {
                    vm.selectedActor = nil
                } label: {
                    Label {
                        Text("All users")
                    } icon: {
                        if vm.selectedActor == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
            ForEach(vm.actors, id: \.self) {
                LogToolbarActor($0)
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .symbolVariant(vm.selectedActor == nil ? .none : .fill)
                .animation(.default, value: vm.selectedActor)
        }
    }
}

#Preview {
    LogListFilter()
        .environment(LogVM(""))
}
