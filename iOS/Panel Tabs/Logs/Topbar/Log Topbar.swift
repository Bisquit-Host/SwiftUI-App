import SwiftUI

struct LogTopbar: View {
    @Environment(LogVM.self) private var vm
    
    var body: some View {
        if !vm.searchedLogs.isEmpty {
            Section {
                HStack {
                    LogTopbarCard(
                        title: "Total Entries",
                        icon: "rectangle.stack.fill",
                        iconColor: .indigo,
                        value: vm.filteredLogs.count
                    )
                    
                    Divider()
                        .background(.primary)
                        .padding(.leading)
                    
                    LogTopbarCard(
                        title: "Users Logged",
                        icon: "person.crop.rectangle.stack.fill",
                        iconColor: .blue,
                        value: vm.loggedUserCount
                    )
                    
                    if let daysLogged = vm.daysLogged {
                        Divider()
                            .background(.primary)
                            .padding(.leading)
                        
                        LogTopbarCard(
                            title: "Days Logged",
                            icon: "calendar",
                            iconColor: .red,
                            value: daysLogged
                        )
                    }
#if os(tvOS)
                    Spacer()
                    
                    LogListFilter()
#endif
                }
                .footnote()
            }
        }
    }
}

#Preview {
    List {
        LogTopbar()
    }
    .darkSchemePreferred()
    .environment(LogVM(""))
}
