import SwiftUI

struct AccountSettingsCredentials: View {
    @Environment(AccountVM.self) private var vm
    
    var body: some View {
        Section {
            if let account = vm.account {
                let name = account.firstName + " " + account.lastName
#if DEBUG
                param("ID", value: account.id.description)
#endif
                param("Name", value: name)
                param("Email", value: account.email)
            }
        }
    }
    
    private func param(_ param: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(param)
            Spacer()
            
            Text(value)
                .secondary()
        }
    }
}

#Preview {
    AccountSettingsCredentials()
}
