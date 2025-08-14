#if canImport(ActivityKit)
import ScrechKit
import ActivityKit
import PteroNet

private extension Data {
    var hexadecimalString: String {
        self.reduce("") {
            $0 + String(format: "%02x", $1)
        }
    }
}

@Observable
final class LiveActivity {
    var liveActivityId = ""
    var newEmoji = ""
    
    private var currentActivity: Activity<WidgetsAttributes>? = nil
    var activityViewState: ActivityViewState? = nil
    var errorMessage: String? = nil
    
    var LAToken = ""
    
    func postRequest(WSUrl: String, WSToken: String, liveActivityToken: String) {
        guard
            let url = URL(string: "https://push-activity.bisquit.host/liveactivity/start")
        else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
#if DEBUG
        let environment = "development"
#else
        let environment = "production"
#endif
        
        let body: [String: Any] = [
            "WSUrl":             WSUrl,
            "WSToken":           WSToken,
            "liveActivityToken": liveActivityToken,
            "environment":       environment,
            "appID":             Bundle.main.bundleIdentifier ?? "host.bisquit.Bisquit.Host"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            guard error == nil else {
                return
            }
            //            guard let data, error == nil else { return }
            // Handle the response and data here
        }
        .resume()
    }
    
    func consoleDetails(_ id: String) async {
        do {
            let model = try await consoleDetailsAPI(id)
            let socket = model.socket
            let token = model.token
            
            postRequest(
                WSUrl: socket.description,
                WSToken: token,
                liveActivityToken: LAToken
            )
        } catch {
            networkCallError(#function, error)
        }
    }
    
    func setup(_ activity: Activity<WidgetsAttributes>) {
        currentActivity = activity
        
        activityViewState = .init(
            activityState: activity.activityState,
            contentState: activity.content.state,
            pushToken: activity.pushToken?.hexadecimalString
        )
        
        observeActivity(activity: activity)
    }
    
    func cleanUpDismissedActivity() {
        currentActivity = nil
        activityViewState = nil
    }
    
    func observeActivity(activity: Activity<WidgetsAttributes>) {
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { @MainActor in
                    for await activityState in activity.activityStateUpdates {
                        if activityState == .dismissed {
                            self.cleanUpDismissedActivity()
                        } else {
                            self.activityViewState?.activityState = activityState
                        }
                    }
                }
                
                group.addTask { @MainActor in
                    for await contentState in activity.contentUpdates {
                        self.activityViewState?.contentState = contentState.state
                        //
                        //                        guard let activity = self.currentActivity else {
                        //                            return
                        //                        }
                        //
                        //                        let state: WidgetsAttributes.ContentState
                        //
                        //                        state = WidgetsAttributes.ContentState(
                        //                            latestMessage: contentState.state.latestMessage
                        //                        )
                        //
                        //                        await activity.update(ActivityContent<WidgetsAttributes.ContentState>(
                        //                            state: state,
                        //                            staleDate: Date.now + 15,
                        //                            relevanceScore: 100
                        //                            //                                relevanceScore: alert ? 100 : 50
                        //                        )//,
                        //                                              //                                                  alertConfiguration: <#T##AlertConfiguration?#>
                        //
                        //                        )
                    }
                }
                
                group.addTask { @MainActor in
                    for await pushToken in activity.pushTokenUpdates {
                        let pushTokenString = pushToken.hexadecimalString
                        
                        self.LAToken = pushTokenString
                        
                        print("New push token: \(pushTokenString)")
                        
                        //                        do {
                        //                            let frequentUpdateEnabled = ActivityAuthorizationInfo().frequentPushesEnabled
                        //
                        //                            try await self.sendPushToken(hero: activity.attributes.hero,
                        //                                                         pushTokenString: pushTokenString,
                        //                                                         frequentUpdateEnabled: frequentUpdateEnabled)
                        //                        } catch {
                        //                            self.errorMessage = """
                        //                            Failed to send push token to server
                        //                            ------------------------
                        //                            \(String(describing: error))
                        //                            """
                        //                        }
                    }
                }
            }
        }
    }
    
    func startLiveActivity(_ server: ServerAttributes) async {
        let attributes = WidgetsAttributes(
            id: server.id,
            name: server.name,
            node: server.node
        )
        
        let contentState = WidgetsAttributes.ContentState(
            latestMessage: "Latest console output will display here"
        )
        
        let activityContent = ActivityContent(
            state: contentState,
            staleDate: nil
        )
        
        do {
            let activity = try Activity<WidgetsAttributes>.request(
                attributes: attributes,
                content: activityContent,
                pushType: .token
            )
            
            setup(activity)
            
            delay(2) {
                Task {
                    await self.consoleDetails(server.id)
                }
            }
        } catch {
            print("Error starting live activity:", error.localizedDescription)
        }
    }
    
    //    func updateLiveActivity() {
    //        Task {
    //            guard let activity = Activity<WidgetsAttributes>.activities.first(where: { $0.id == liveActivityId }) else {
    //                print("Activity not found")
    //                return
    //            }
    //
    //            let updatedState = WidgetsAttributes.ContentState(latestMessage: "Пыж")
    //            await activity.update(ActivityContent(state: updatedState,
    //                                                  staleDate: nil
    //                                                  //                                                  staleDate: Date().addingTimeInterval(3600)
    //                                                 ))
    //        }
    //    }
    
    func stopAllLiveActivities() {
        Task {
            for activity in Activity<WidgetsAttributes>.activities {
                await activity.end(.none, dismissalPolicy: .immediate)
            }
        }
    }
}
#endif
