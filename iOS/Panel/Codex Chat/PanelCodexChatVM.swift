import Foundation
import Calagopus

@Observable
final class PanelCodexChatVM {
    private static let codexIntegrationLoggedOutKey = "codexIntegrationLoggedOut"
    
    private var chatID: String?
    private var isCodexIntegrationLoggedOut: Bool {
        get {
            UserDefaults.standard.bool(forKey: Self.codexIntegrationLoggedOutKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.codexIntegrationLoggedOutKey)
        }
    }
    
    var title = "Codex Chat"
    var phase = "idle"
    var configured = true
    var message = ""
    var codexModel = "gpt-5"
    var codexModelOptions = ["gpt-5"]
    var codexReasoningEffort = "medium"
    var codexReasoningEffortOptions = ["low", "medium", "high", "extra_high"]
    var messages: [PanelCodexChatMessage] = []
    var pendingApproval: PanelCodexPendingApproval?
    var oauthStart: PanelCodexOAuthStart?
    var errorMessage: String?
    var hasLoadedStatus = false
    var isLoading = false
    var isSending = false
    var isResolvingApproval = false
    
    var shouldPoll: Bool {
        phase == "running" || phase == "waiting_approval" || phase == "waiting_for_approval"
    }
    
    func load() async {
        guard !isCodexIntegrationLoggedOut else {
            resetCodexIntegration()
            return
        }
        
        guard chatID == nil else {
            await refresh()
            return
        }
        
        await createChat()
    }
    
    func createChat(keepDisconnected: Bool = false) async {
        await performLoading {
            let client = try CalagopusClientFactory.client()
            let endpoint = try CalagopusGeneratedOperations.postApiClientExtensionsDevYolkiServeragentChats.endpoint()
            apply(try await client.sendJSON(endpoint), keepDisconnected: keepDisconnected)
            
            if let chatID {
                let endpoint = try CalagopusGeneratedOperations.getApiClientExtensionsDevYolkiServeragentChatsChatUuid.endpoint(pathValues: ["chat_uuid": chatID])
                apply(try await client.sendJSON(endpoint), statusLoaded: true, keepDisconnected: keepDisconnected)
            }
        }
    }
    
    func refresh() async {
        guard let chatID else { return }
        
        await performLoading {
            let client = try CalagopusClientFactory.client()
            let endpoint = try CalagopusGeneratedOperations.getApiClientExtensionsDevYolkiServeragentChatsChatUuid.endpoint(pathValues: ["chat_uuid": chatID])
            apply(try await client.sendJSON(endpoint), statusLoaded: true)
        }
    }
    
    func sendMessage() async {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        if chatID == nil {
            await createChat()
        }
        
        guard let chatID else { return }
        
        message = ""
        isSending = true
        errorMessage = nil
        
        do {
            let client = try CalagopusClientFactory.client()
            
            let endpoint = try CalagopusGeneratedOperations.postApiClientExtensionsDevYolkiServeragentChatsChatUuidMessage.endpoint(
                pathValues: ["chat_uuid": chatID],
                body: PanelCodexChatMessageRequest(message: trimmedMessage)
            )
            
            apply(try await client.sendJSON(endpoint), statusLoaded: true)
        } catch {
            message = trimmedMessage
            errorMessage = error.localizedDescription
            SystemAlert.error(error)
        }
        
        isSending = false
    }
    
    func stop() async {
        guard let chatID else { return }
        
        await performLoading {
            let client = try CalagopusClientFactory.client()
            let endpoint = try CalagopusGeneratedOperations.postApiClientExtensionsDevYolkiServeragentChatsChatUuidStop.endpoint(pathValues: ["chat_uuid": chatID])
            apply(try await client.sendJSON(endpoint), statusLoaded: true)
        }
    }
    
    func updatePreferences() async {
        if chatID == nil {
            await createChat()
        }
        
        guard let chatID else { return }
        
        await performLoading {
            let client = try CalagopusClientFactory.client()
            
            let endpoint = try CalagopusGeneratedOperations.putApiClientExtensionsDevYolkiServeragentChatsChatUuidPreferences.endpoint(
                pathValues: ["chat_uuid": chatID],
                body: PanelCodexChatPreferencesRequest(
                    codexModel: codexModel,
                    codexReasoningEffort: codexReasoningEffort
                )
            )
            
            apply(try await client.sendJSON(endpoint), statusLoaded: true)
        }
    }
    
    func startCodexOAuth() async -> URL? {
        if chatID == nil {
            await createChat(keepDisconnected: true)
        }
        
        guard let chatID else { return nil }
        
        do {
            let client = try CalagopusClientFactory.client()
            let endpoint = try CalagopusGeneratedOperations.postApiClientExtensionsDevYolkiServeragentChatsChatUuidCodexOauthStart.endpoint(pathValues: ["chat_uuid": chatID])
            
            if let oauthStart = PanelCodexOAuthStart(try await client.sendJSON(endpoint)) {
                self.oauthStart = oauthStart
                configured = false
                return oauthStart.verificationURL
            }
        } catch {
            errorMessage = error.localizedDescription
            SystemAlert.error(error)
        }
        
        return nil
    }
    
    func finishCodexOAuth() async {
        guard let chatID else { return }
        
        await performLoading {
            let client = try CalagopusClientFactory.client()
            let endpoint = try CalagopusGeneratedOperations.postApiClientExtensionsDevYolkiServeragentChatsChatUuidCodexOauthFinish.endpoint(
                pathValues: ["chat_uuid": chatID],
                body: PanelCodexOAuthFinishRequest()
            )
            let json = try await client.sendJSON(endpoint)
            isCodexIntegrationLoggedOut = false
            apply(json, statusLoaded: true)
        }
    }
    
    func logoutCodexIntegration() async {
        guard let chatID else {
            isCodexIntegrationLoggedOut = true
            resetCodexIntegration()
            return
        }
        
        await performLoading {
            let client = try CalagopusClientFactory.client()
            let endpoint = try CalagopusGeneratedOperations.deleteApiClientExtensionsDevYolkiServeragentChatsChatUuid.endpoint(pathValues: ["chat_uuid": chatID])
            _ = try await client.send(endpoint, as: EmptyCalagopusResponse.self)
            isCodexIntegrationLoggedOut = true
            resetCodexIntegration()
        }
    }
    
    func resolveApproval(approved: Bool) async {
        guard let chatID else { return }
        
        isResolvingApproval = true
        
        do {
            let client = try CalagopusClientFactory.client()
            
            let endpoint = try CalagopusGeneratedOperations.postApiClientExtensionsDevYolkiServeragentChatsChatUuidApproval.endpoint(
                pathValues: ["chat_uuid": chatID],
                body: PanelCodexChatApprovalRequest(approved: approved)
            )
            
            apply(try await client.sendJSON(endpoint), statusLoaded: true)
        } catch {
            errorMessage = error.localizedDescription
            SystemAlert.error(error)
        }
        
        isResolvingApproval = false
    }
    
    private func performLoading(_ action: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await action()
        } catch {
            errorMessage = error.localizedDescription
            SystemAlert.error(error)
        }
        
        isLoading = false
    }
    
    private func apply(_ json: CalagopusJSON, statusLoaded: Bool = false, keepDisconnected: Bool = false) {
        let chat = PanelCodexChat(json)
        
        chatID = chat.id
        title = chat.title
        phase = chat.phase
        configured = keepDisconnected ? false : chat.configured
        codexModel = chat.codexModel
        codexModelOptions = chat.codexModelOptions
        codexReasoningEffort = chat.codexReasoningEffort
        codexReasoningEffortOptions = chat.codexReasoningEffortOptions
        messages = chat.messages
        pendingApproval = chat.pendingApproval
        hasLoadedStatus = hasLoadedStatus || statusLoaded
    }
    
    private func resetCodexIntegration() {
        chatID = nil
        title = "Codex Chat"
        phase = "idle"
        configured = false
        message = ""
        messages = []
        pendingApproval = nil
        oauthStart = nil
        hasLoadedStatus = true
    }
}
