import SwiftUI

struct CloudKeysParent: View {
    @Binding private var apiKey: String
    private let validate: () -> Void
    
    init(_ apiKey: Binding<String>, validate: @escaping () -> Void = {}) {
        _apiKey = apiKey
        self.validate = validate
    }
    
    var body: some View {
        NavigationStack {
            CloudKeyList($apiKey, validate: validate)
        }
        .presentationDetents([.medium])
    }
}
