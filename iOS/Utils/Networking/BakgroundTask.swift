import BackgroundTasks
import Calagopus

extension BisquitHost {
    struct BackgroundTaskManager {
        static func scheduleAppRefresh(after interval: TimeInterval = 3600) {
            let req = BGAppRefreshTaskRequest(identifier: "host.bisquit.Bisquit-Host.Background-Task")
            req.earliestBeginDate = .now.addingTimeInterval(interval)
            
            try? BGTaskScheduler.shared.submit(req)
        }
        
        static func handleAppRefresh() async {
            scheduleAppRefresh()
            await refreshServersIfNeeded()
        }
        
        private static func refreshServersIfNeeded() async {
            let store = ValueStore()
            let hasSelectedAPIKey = !(Keychain.load(key: "selectedApiKey")?.isEmpty ?? true)
            let hasBillingSession = accessToken() != nil
            
            guard
                (store.isApiKeyValid && hasSelectedAPIKey) || hasBillingSession
            else {
                return
            }
            
            let vm = ServerListVM()
            await vm.fetchServers(store.adminServerList)
        }
    }
}
