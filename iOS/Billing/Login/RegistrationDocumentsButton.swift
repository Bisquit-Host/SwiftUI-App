import SwiftUI

struct RegistrationDocumentsButton: View {
    @State private var sheetDocuments = false
    
    @Binding private var hasAcceptedDocuments: Bool
    
    init(_ hasAcceptedDocuments: Binding<Bool>) {
        _hasAcceptedDocuments = hasAcceptedDocuments
    }
    
    var body: some View {
        Button {
            sheetDocuments = true
        } label: {
            HStack {
                Text(hasAcceptedDocuments ? "Documents accepted" : "Review & accept documents")
                
                Spacer()
                
                Image(systemName: hasAcceptedDocuments ? "checkmark.circle.fill" : "doc.text")
                    .secondary()
            }
        }
        .foregroundStyle(.foreground)
        .frame(maxWidth: .infinity)
        .loginButtonStyle()
        .sheet($sheetDocuments) {
            NavigationStack {
                LoginSignupDocumentList($hasAcceptedDocuments)
            }
        }
    }
}
