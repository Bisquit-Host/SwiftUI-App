import SwiftUI

struct InfoTabUsers: View {
    @State private var vm: UsersVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        vm = UsersVM(id)
    }
    
    @State private var sheetUsers = false
    
    var body: some View {
        Button {
            sheetUsers = true
        } label: {
            VStack(spacing: 12) {
                if vm.users.count == 0 {
                    VStack(spacing: 5) {
                        Image(systemName: "person.3.fill")
                            .tertiary()
                        
                        Text("Users")
                            .semibold()
                    }
                    .footnote()
                } else {
                    Text("Users")
                        .footnote(.semibold)
                    
                    HStack {
                        ForEach(vm.users.prefix(7)) {
                            InfoTabUserAvatar($0.image)
                        }
                    }
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.foreground)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.gray.opacity(0.25), lineWidth: 1)
            }
        }
        .task {
            await vm.fetchUsers(true)
        }
        .sheet($sheetUsers) {
            UserListParent()
                .environment(vm)
        }
        .contextMenu {
            Button("New user", systemImage: "person.badge.plus") {
                sheetUsers = true
                vm.sheetInvitation = true
            }
        }
    }
}

#Preview {
    InfoTabUsers("")
        .darkSchemePreferred()
        .environment(UsersVM(""))
}
