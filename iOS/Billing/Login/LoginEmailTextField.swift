import SwiftUI

struct LoginEmailTextField: View {
    @Binding private var login: String
    
    init(_ login: Binding<String>) {
        _login = login
    }
    
    var body: some View {
        TextField("Email", text: $login)
            .autocorrectionDisabled()
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .loginButtonStyle()
    }
}

//#Preview {
//    LoginEmailTextField()
//}
