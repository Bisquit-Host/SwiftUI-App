import SwiftUI
import PteroNet

struct LogList: View {
    @Environment(LogVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            LogTopbar()
            
            ForEach(vm.logsByMonth.indices, id: \.self) { index in
                let logs = vm.logsByMonth[index]
                
                Section(vm.monthName(for: logs.first!.timestamp)) {
                    ForEach(logs) { log in
                        LogCard(log)
                    }
                }
                .transparentSection()
            }
        }
        .navigationTitle("Logs")
#if !os(tvOS)
        .toolbarTitleDisplayMode(.large)
#endif
        .toolbarTitleDisplayMode(.inline)
        .ornamentDismissButton()
        .transparentList()
        .refreshableTask {
            vm.fetchLogs()
        }
#if os(iOS)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if !System.lowPowerMode {
                vm.fetchLogs()
            }
        }
#endif
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissButton {
                    dismiss()
                }
            }
            
#if !os(watchOS)
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Section {
                        Button {
                            withAnimation {
                                vm.selectedActor = nil
                            }
                        } label: {
                            Label {
                                Text("All")
                            } icon: {
                                if vm.selectedActor == nil {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                    
                    ForEach(vm.actors, id: \.self) { actor in
                        if let actor {
                            Button {
                                withAnimation {
                                    vm.selectedActor = actor
                                }
                            } label: {
                                if let username = actor.actor.attributes?.username {
                                    Text(username)
                                    
                                    if let email = actor.actor.attributes?.email {
                                        Text(email)
                                    }
                                } else {
                                    Text("System")
                                }
                                
                                if vm.selectedActor == actor {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .footnote(.bold)
                        .frame(width: 35, height: 35)
                        .background(.ultraThinMaterial, in: .circle)
                        .symbolVariant(vm.selectedActor == nil ? .none : .fill)
                }
                .foregroundStyle(.foreground)
            }
#endif
        }
    }
}

#Preview {
    NavigationView {
        LogList()
            .environment(LogVM(""))
            .environmentObject(ValueStore())
    }
}
