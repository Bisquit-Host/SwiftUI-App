import BackgroundTasks
import PteroNet

extension BisquitHost {
    struct BackgroundTaskManager {
        static func scheduleAppRefresh(after interval: TimeInterval = 3600) {
            let request = BGAppRefreshTaskRequest(identifier: "host.bisquit.Bisquit-Host.Background-Task")
            request.earliestBeginDate = .now.addingTimeInterval(interval)
            
            try? BGTaskScheduler.shared.submit(request)
        }
        
        static func handleAppRefresh() async {
            scheduleAppRefresh()
            await refreshServersIfNeeded()
        }
        
        private static func refreshServersIfNeeded() async {
            let store = ValueStore()
            
            guard store.isApiKeyValid else {
                return
            }
            
            guard let apiKey = Keychain.load(key: "selectedApiKey"), !apiKey.isEmpty else {
                return
            }
            
            let vm = ServerListVM()
            await vm.fetchServers(store.adminServerList)
        }
    }
}
