import Foundation

extension StartPage {
    func checkApiKey() async {
        await vm.fetchAccountDetails {
            if !keys.contains(where: { $0.key == vm.apiKey }) {
                modelContext.insert(APIKey("", key: vm.apiKey))
            }
            
            store.authSucced()
        }
    }
}
