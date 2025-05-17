import SwiftUI

struct InfoTabUsers: View {
    @Environment(UsersVM.self) private var vm
    
    @State private var sheetUsers = false
    
    var body: some View {
        Menu {
            Button {
                sheetUsers = true
                vm.sheetInvitation = true
            } label: {
                Label("New user", systemImage: "person.badge.plus")
            }
        } label: {
            Button {
                sheetUsers = true
            } label: {
                VStack(spacing: 12) {
                    if vm.users.count == 0 {
                        VStack(spacing: 5) {
                            Image(systemName: "person.3.fill")
                                .tertiary()
                            
                            Text("Users").semibold()
                        }
                        .footnote()
                    } else {
                        Text("Users")
                            .footnote(.semibold)
                        
                        HStack {
                            ForEach(vm.users.prefix(7)) { user in
                                InfoTabButtonsUserImg(user.image)
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
        } primaryAction: {
            sheetUsers = true
        }
        .sheet($sheetUsers) {
            UserListParent()
                .environment(vm)
        }
    }
}

#Preview {
    InfoTabUsers()
        .environment(UsersVM(""))
}
