import BackgroundTasks

extension BisquitHostApp {
    struct BackgroundTaskManager {
        static func scheduleAppRefresh() {
            let request = BGAppRefreshTaskRequest(identifier: "host.bisquit.Bisquit-Host.Background-Task")
            request.earliestBeginDate = .now.addingTimeInterval(3600)
            
            try? BGTaskScheduler.shared.submit(request)
        }
    }
}
