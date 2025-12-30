import SwiftUI

struct RegistrationDocumentsButton: View {
    @Binding private var isDocumentsSheetPresented: Bool
    @Binding private var hasAcceptedDocuments: Bool
    
    init(_ hasAcceptedDocuments: Binding<Bool>, isPresented: Binding<Bool>) {
        _hasAcceptedDocuments = hasAcceptedDocuments
        _isDocumentsSheetPresented = isPresented
    }
    
    var body: some View {
        Button {
            isDocumentsSheetPresented = true
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
        .sheet($isDocumentsSheetPresented) {
            NavigationStack {
                LoginSignupDocumentList($hasAcceptedDocuments)
            }
        }
    }
}
