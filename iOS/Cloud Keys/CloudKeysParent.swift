import SwiftUI

struct CloudKeysParent: View {
    @Binding private var apiKey: String
    private let validate: () async -> Void
    
    init(_ apiKey: Binding<String>, validate: @escaping () async -> Void = {}) {
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
