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
    private var currentActivity: Activity<WidgetsAttributes>? = nil
    private var LAToken = ""
    
    var activityViewState: ActivityViewState? = nil
    var errorMessage: String? = nil
    
    func postRequest(
        wsUrl: String,
        wsToken: String,
        liveActivityToken: String
    ) async throws {
        
        guard
            let url = URL(string: "https://push-activity.bisquit.host/liveactivity/start")
        else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
#if DEBUG
        let environment = "development"
#else
        let environment = "production"
#endif
        let body = [
            "WSUrl":             wsUrl,
            "WSToken":           wsToken,
            "liveActivityToken": liveActivityToken,
            "environment":       environment,
            "appID":             Bundle.main.bundleIdentifier ?? "host.bisquit.Bisquit.Host"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
    }
    
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
        Task {
            for await activityState in activity.activityStateUpdates {
                if activityState == .dismissed {
                    self.cleanUpDismissedActivity()
                } else {
                    self.activityViewState?.activityState = activityState
                }
            }
        }
        
        Task {
            for await contentState in activity.contentUpdates {
                self.activityViewState?.contentState = contentState.state
            }
        }
        
        Task {
            for await pushToken in activity.pushTokenUpdates {
                let pushTokenString = pushToken.hexadecimalString
                self.LAToken = pushTokenString
                print("New push token:", pushTokenString)
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
    //                        print("New push token:", pushTokenString)
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
    
    @MainActor
    func startLiveActivity(_ server: ServerAttributes) async {
        grantAchievement("start_live_activity")
        
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
            
            try await Task.sleep(for: .seconds(2))
            
            Task { @MainActor in
                await self.consoleDetails(server.id)
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
            
            try await postRequest(
                wsUrl: socket.description,
                wsToken: token,
                liveActivityToken: LAToken
            )
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
