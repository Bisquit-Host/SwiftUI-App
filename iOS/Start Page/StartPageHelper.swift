import Foundation

extension StartPage {
    func checkApiKey() async {
        await vm.fetchAccountDetails {
            if !keys.contains(where: { $0.key == vm.apiKey }) {
                let key = APIKey("", key: vm.apiKey)
                
                modelContext.insert(key)
            }
            
            store.authSucced()
        }
    }
}
