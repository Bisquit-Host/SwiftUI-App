import Foundation
import Calagopus

@Observable
final class PanelCodexChatVM {
    private static let codexIntegrationLoggedOutKey = "codexIntegrationLoggedOut"
    
    @ObservationIgnored private let store = ValueStore()
    @ObservationIgnored private var typingTask: Task<Void, Never>?
    
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
    var codexReasoningEffortOptions = ["low", "medium", "high", "xhigh"]
    var webSearchEnabled = true
    var fullAccess = false
    var messages: [PanelCodexChatMessage] = []
    var pendingApproval: PanelCodexPendingApproval?
    var oauthStart: PanelCodexOAuthStart?
    var errorMessage: String?
    var hasLoadedStatus = false
    var isLoading = false
    var isSending = false
    var isUpdatingPreferences = false
    var isResolvingApproval = false
    
    var shouldPoll: Bool {
        phase == "running" || phase == "waiting_approval" || phase == "waiting_for_approval"
    }
    
    var isWaitingForMessage: Bool {
        isSending || (phase == "running" && pendingApproval == nil)
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
        guard !isUpdatingPreferences else { return }
        
        if chatID == nil {
            await createChat()
        }
        
        guard let chatID else { return }
        
        isUpdatingPreferences = true
        defer {
            isUpdatingPreferences = false
        }
        errorMessage = nil
        
        do {
            let client = try CalagopusClientFactory.client()
            let request = PanelCodexChatPreferencesRequest(
                codexModel: codexModel,
                codexReasoningEffort: codexReasoningEffort,
                webSearchEnabled: webSearchEnabled,
                fullAccess: fullAccess
            )
            
            let endpoint = try CalagopusGeneratedOperations.putApiClientExtensionsDevYolkiServeragentChatsChatUuidPreferences.endpoint(
                pathValues: ["chat_uuid": chatID]
            )
            let camelCaseEndpoint = CalagopusEndpoint(
                operationID: endpoint.operationID,
                method: endpoint.method,
                path: endpoint.path,
                queryItems: endpoint.queryItems,
                body: .data(try request.jsonData(), contentType: "application/json")
            )
            
            apply(try await client.sendJSON(camelCaseEndpoint), statusLoaded: true)
        } catch {
            errorMessage = error.localizedDescription
            SystemAlert.error(error)
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
        let shouldAnimateMessages = hasLoadedStatus && chatID == chat.id && store.bigAssAnimations
        
        chatID = chat.id
        title = chat.title
        phase = chat.phase
        configured = keepDisconnected ? false : chat.configured
        codexModel = chat.codexModel
        codexModelOptions = chat.codexModelOptions
        codexReasoningEffort = chat.codexReasoningEffort
        codexReasoningEffortOptions = chat.codexReasoningEffortOptions
        webSearchEnabled = chat.webSearchEnabled
        fullAccess = chat.fullAccess
        messages = mergedMessages(
            from: chat.messages,
            animateAssistantMessages: shouldAnimateMessages
        )
        pendingApproval = chat.pendingApproval
        hasLoadedStatus = hasLoadedStatus || statusLoaded
        startTypingTaskIfNeeded()
    }
    
    private func resetCodexIntegration() {
        typingTask?.cancel()
        typingTask = nil
        chatID = nil
        title = "Codex Chat"
        phase = "idle"
        configured = false
        message = ""
        webSearchEnabled = true
        fullAccess = false
        messages = []
        pendingApproval = nil
        oauthStart = nil
        hasLoadedStatus = true
    }
    
    private func mergedMessages(
        from incomingMessages: [PanelCodexChatMessage],
        animateAssistantMessages: Bool
    ) -> [PanelCodexChatMessage] {
        let existingMessagesByID = messages.reduce(into: [String: PanelCodexChatMessage]()) {
            $0[$1.id] = $1
        }
        
        return incomingMessages.map {
            var message = $0
            
            guard animateAssistantMessages, !message.isUser else {
                message.content = message.targetContent
                return message
            }
            
            message.content = existingMessagesByID[message.id]?.content ?? ""
            
            return message
        }
    }
    
    private func startTypingTaskIfNeeded() {
        guard messages.contains(where: { !$0.isUser && !$0.isFullyRevealed }) else {
            return
        }
        
        guard store.bigAssAnimations else {
            revealPendingMessages()
            return
        }
        
        guard typingTask == nil else {
            return
        }
        
        typingTask = Task { [weak self] in
            await self?.runTypingLoop()
        }
    }
    
    private func runTypingLoop() async {
        while !Task.isCancelled {
            guard let messageIndex = messages.firstIndex(where: { !$0.isUser && !$0.isFullyRevealed }) else {
                break
            }
            
            guard store.bigAssAnimations else {
                revealPendingMessages()
                break
            }
            
            let message = messages[messageIndex]
            let displayedCount = message.content.count
            let targetText = message.targetContent
            let targetCount = targetText.count
            
            if !targetText.hasPrefix(message.content) {
                let commonPrefixCount = commonPrefixCount(
                    between: message.content,
                    and: targetText
                )
                
                messages[messageIndex].content = String(targetText.prefix(commonPrefixCount))
                continue
            }
            
            let remainingCount = targetCount - displayedCount
            
            let step = switch remainingCount {
            case 25...: 4
            case 10...24: 2
            default: 1
            }
            
            messages[messageIndex].content = String(targetText.prefix(min(displayedCount + step, targetCount)))
            
            do {
                try await Task.sleep(for: .milliseconds(18))
            } catch {
                break
            }
        }
        
        typingTask = nil
    }
    
    private func revealPendingMessages() {
        for index in messages.indices where !messages[index].isUser {
            messages[index].content = messages[index].targetContent
        }
    }
    
    private func commonPrefixCount(between lhs: String, and rhs: String) -> Int {
        zip(lhs, rhs)
            .prefix { $0 == $1 }
            .count
    }
}
