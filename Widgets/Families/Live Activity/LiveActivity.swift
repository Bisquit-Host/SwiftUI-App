#if canImport(ActivityKit)
import ScrechKit
import ActivityKit
import PteroNet

fileprivate extension Data {
    var hexadecimalString: String {
        self.reduce("") {
            $0 + String(format: "%02x", $1)
        }
    }
}

@MainActor
@Observable
final class LiveActivity {
    private var currentActivity: Activity<WidgetsAttributes>? = nil
    private var LAToken = ""
    
    var activityViewState: ActivityViewState? = nil
    var errorMessage: String? = nil
    
    func setup(_ activity: Activity<WidgetsAttributes>) {
        currentActivity = activity
        
        activityViewState = .init(
            activityState: activity.activityState,
            contentState: activity.content.state,
            pushToken: activity.pushToken?.hexadecimalString
        )
        
        observeActivity(activity)
    }
    
    private func cleanUpDismissedActivity() {
        currentActivity = nil
        activityViewState = nil
    }
    
    private func observeActivity(_ activity: Activity<WidgetsAttributes>) {
        let activityStateUpdates = activity.activityStateUpdates
        let contentUpdates = activity.contentUpdates
        let pushTokenUpdates = activity.pushTokenUpdates
        
        Task { @MainActor [activityStateUpdates] in
            for await activityState in activityStateUpdates {
                if activityState == .dismissed {
                    self.cleanUpDismissedActivity()
                } else {
                    self.activityViewState?.activityState = activityState
                }
            }
        }
        
        Task { @MainActor [contentUpdates] in
            for await contentState in contentUpdates {
                self.activityViewState?.contentState = contentState.state
            }
        }
        
        Task { @MainActor [pushTokenUpdates] in
            for await pushToken in pushTokenUpdates {
                let pushTokenString = pushToken.hexadecimalString
                self.LAToken = pushTokenString
                
                Logger().info("New push token: \(pushTokenString)")
            }
        }
    }
    
    //    private func observeActivity(_ activity: Activity<WidgetsAttributes>) {
    //        Task {
    //            await withTaskGroup(of: Void.self) { group in
    //                group.addTask { @MainActor in
    //                    for await activityState in activity.activityStateUpdates {
    //                        if activityState == .dismissed {
    //                            self.cleanUpDismissedActivity()
    //                        } else {
    //                            self.activityViewState?.activityState = activityState
    //                        }
    //                    }
    //                }
    //
    //                group.addTask { @MainActor in
    //                    for await contentState in activity.contentUpdates {
    //                        self.activityViewState?.contentState = contentState.state
    //
    //                        //                        guard let activity = self.currentActivity else {
    //                        //                            return
    //                        //                        }
    //                        //
    //                        //                        let state: WidgetsAttributes.ContentState
    //                        //
    //                        //                        state = WidgetsAttributes.ContentState(
    //                        //                            latestMessage: contentState.state.latestMessage
    //                        //                        )
    //                        //
    //                        //                        await activity.update(ActivityContent<WidgetsAttributes.ContentState>(
    //                        //                            state: state,
    //                        //                            staleDate: Date.now + 15,
    //                        //                            relevanceScore: 100
    //                        //                            //                                relevanceScore: alert ? 100 : 50
    //                        //                        )//,
    //                        //                                              //                                                  alertConfiguration: <#T##AlertConfiguration?#>
    //                        //
    //                        //                        )
    //                    }
    //                }
    //
    //                group.addTask { @MainActor in
    //                    for await pushToken in activity.pushTokenUpdates {
    //                        let pushTokenString = pushToken.hexadecimalString
    //
    //                        self.LAToken = pushTokenString
    //
    //                        Logger().info("New push token:", pushTokenString)
    //
    //                        //                        do {
    //                        //                            let frequentUpdateEnabled = ActivityAuthorizationInfo().frequentPushesEnabled
    //                        //
    //                        //                        try await self.sendPushToken(
    //                        //                            hero: activity.attributes.hero,
    //                        //                            pushTokenString: pushTokenString,
    //                        //                            frequentUpdateEnabled: frequentUpdateEnabled
    //                        //                        )
    //                        //                        } catch {
    //                        //                            self.errorMessage = """
    //                        //                            Failed to send push token to server
    //                        //                            ------------------------
    //                        //                            \(String(describing: error))
    //                        //                            """
    //                        //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    func startLiveActivity(_ server: ServerAttributes) async {
        grantAchievement("start_live_activity")
        
        let attributes = WidgetsAttributes(id: server.id, name: server.name, node: server.node)
        let contentState = WidgetsAttributes.ContentState(latestMessage: "Latest console output will display here")
        
        let activityContent = ActivityContent(state: contentState, staleDate: nil)
        
        do {
            let activity = try Activity<WidgetsAttributes>.request(attributes: attributes, content: activityContent, pushType: .token)
            
            setup(activity)
            try await Task.sleep(for: .seconds(2))
            
            await consoleDetails(server.id)
        } catch {
            Logger().error("Error starting live activity: \(error)")
        }
    }
    
    //    func updateLiveActivity() {
    //        Task {
    //            guard let activity = Activity<WidgetsAttributes>.activities.first(where: { $0.id == liveActivityId }) else {
    //                Logger().error("Activity not found")
    //                return
    //            }
    //
    //            let updatedState = WidgetsAttributes.ContentState(latestMessage: "Pyzh")
    //
    //            await activity.update(ActivityContent(
    //                state: updatedState,
    //                staleDate: nil
    //                //staleDate: Date().addingTimeInterval(3600)
    //            ))
    //        }
    //    }
    
    private func consoleDetails(_ id: String) async {
        do {
            let model = try await consoleDetailsAPI(id)
            let socket = model.socket
            let token = model.token
            
            try await postRequest(wsURL: socket.description, wsToken: token, liveActivityToken: LAToken)
        } catch {
            networkCallError(#function, error)
        }
    }
    
    func stopAllLiveActivities() {
        Task {
            for activity in Activity<WidgetsAttributes>.activities {
                await activity.end(.none, dismissalPolicy: .immediate)
            }
        }
    }
}
#endif
