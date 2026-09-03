import SwiftUI
import Calagopus
import PhotosUI

@Observable
final class AgentChatVM {
    private static let codexIntegrationLoggedOutKey = "codexIntegrationLoggedOut"
    
    @ObservationIgnored private let store = ValueStore()
    @ObservationIgnored private var typingTask: Task<Void, Never>?
    @ObservationIgnored private var preferencesUpdatePending = false
    
    private let serverId: String?
    private var chatID: String?
    private var isCodexIntegrationLoggedOut: Bool {
        get {
            UserDefaults.standard.bool(forKey: Self.codexIntegrationLoggedOutKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.codexIntegrationLoggedOutKey)
        }
    }
    
    var title = "Agent Chat"
    var phase = "idle"
    var configured = true
    var message = ""
    var provider = AgentChatProvider.codex
    var codexModel = "gpt-5.6-sol"
    var codexModelOptions = ["gpt-5.6-sol", "gpt-5.6-terra", "gpt-5.6-luna"]
    var codexReasoningEffort = "medium"
    var codexReasoningEffortOptions = ["light", "medium", "high", "xhigh"]
    var fastMode = "standard"
    var fastModeOptions = ["standard", "fast"]
    var builtInModel = ""
    var builtInReasoningEffort = ""
    var builtInModelOptions: [AgentChatBuiltInModel] = []
    var webSearchEnabled = true
    var fullAccess = false
    var approvalPolicies: [AgentChatApprovalPolicy] = []
    var messages: [AgentChatMessage] = []
    var pendingImages: [AgentChatImageInput] = []
    var chatHistory: [AgentChatSummary] = []
    var pendingApproval: AgentPendingApproval?
    var oauthStart: CodexOAuthStart?
    var errorMessage: String?
    var hasLoadedStatus = false
    var isLoading = false
    var isSending = false
    var isCreatingChat = false
    var settingsPresented = false
    var chatHistoryLoading = false
    var isUpdatingPreferences = false
    var isResolvingApproval = false
    var isImportingImages = false
    var showsNewChatButton = false
    var deletingChatIDs: Set<String> = []
    
    var shouldPoll: Bool {
        phase == "running" || phase == "waiting_approval"
    }
    
    var isWaitingForMessage: Bool {
        isSending || (phase == "running" && pendingApproval == nil)
    }
    
    var preferencesLocked: Bool {
        isUpdatingPreferences || isSending || shouldPoll
    }

    var builtInReasoningEffortOptions: [String] {
        builtInModelOptions.first { $0.id == builtInModel }?.reasoningEfforts ?? []
    }

    var builtInModelTitle: String {
        builtInModelOptions.first { $0.id == builtInModel }?.title ?? builtInModel
    }

    var providerOptions: [AgentChatProvider] {
        if provider == .openAICompatible {
            [.openAICompatible, .builtIn, .codex]
        } else {
            [.builtIn, .codex]
        }
    }

    init(serverId: String? = nil) {
        self.serverId = serverId
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
    
    func createChat(keepDisconnected: Bool = false, resetConversation: Bool = true) async {
        if resetConversation {
            showsNewChatButton = false
        }
        
        isCreatingChat = true
        defer {
            isCreatingChat = false
        }
        
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
    
    func syncAnimationState() {
        if shouldUseSiriAnimation {
            startTypingTaskIfNeeded()
        } else {
            typingTask?.cancel()
            typingTask = nil
            revealPendingMessages()
        }
    }

    func fetchChatHistory() async {
        guard !chatHistoryLoading else { return }
        
        chatHistoryLoading = true
        defer {
            chatHistoryLoading = false
        }
        errorMessage = nil
        
        do {
            let client = try CalagopusClientFactory.client()
            let endpoint = try CalagopusGeneratedOperations.getApiClientExtensionsDevYolkiServeragentChats.endpoint()
            let json = try await client.sendJSON(endpoint)
            let chats = json.objectValue?["chats"]?.arrayValue?.compactMap(AgentChatSummary.init) ?? []
            
            chatHistory = chats.sorted {
                ($0.updatedAt ?? $0.createdAt ?? .distantPast) > ($1.updatedAt ?? $1.createdAt ?? .distantPast)
            }
        } catch {
            errorMessage = error.localizedDescription
            SystemAlert.error(error)
        }
    }
    
    func openHistoryChat(_ chat: AgentChatSummary) async {
        settingsPresented = false
        await activateHistoryChat(chat)
    }
    
    func deleteHistoryChat(_ chat: AgentChatSummary) async {
        guard !deletingChatIDs.contains(chat.id) else { return }
        
        deletingChatIDs.insert(chat.id)
        defer {
            deletingChatIDs.remove(chat.id)
        }
        
        do {
            let client = try CalagopusClientFactory.client()
            let endpoint = try CalagopusGeneratedOperations.deleteApiClientExtensionsDevYolkiServeragentChatsChatUuid.endpoint(pathValues: ["chat_uuid": chat.id])
            _ = try await client.send(endpoint, as: EmptyCalagopusResponse.self)
            
            let remainingChats = chatHistory.filter { $0.id != chat.id }
            chatHistory = remainingChats
            
            guard chat.id == chatID else { return }
            
            if let nextChat = remainingChats.first {
                await activateHistoryChat(nextChat)
            } else {
                await createChat()
            }
        } catch {
            errorMessage = error.localizedDescription
            SystemAlert.error(error)
        }
    }
    
    func isDeletingChat(_ chat: AgentChatSummary) -> Bool {
        deletingChatIDs.contains(chat.id)
    }
    
    private func activateHistoryChat(_ chat: AgentChatSummary) async {
        typingTask?.cancel()
        typingTask = nil
        chatID = chat.id
        title = chat.title
        phase = "idle"
        messages = []
        pendingApproval = nil
        oauthStart = nil
        hasLoadedStatus = false
        showsNewChatButton = true
        await refresh()
    }
    
    func sendMessage() async {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty || !pendingImages.isEmpty else { return }

        let submittedImages = pendingImages
        
        message = ""
        pendingImages = []
        showsNewChatButton = true
        
        if chatID == nil {
            await createChat(resetConversation: false)
        }
        
        guard let chatID else {
            message = trimmedMessage
            pendingImages = submittedImages
            showsNewChatButton = !messages.isEmpty
            return
        }
        
        isSending = true
        errorMessage = nil
        
        do {
            let client = try CalagopusClientFactory.client()
            
            let endpoint = try CalagopusGeneratedOperations.postApiClientExtensionsDevYolkiServeragentChatsChatUuidMessage.endpoint(
                pathValues: ["chat_uuid": chatID],
                body: AgentChatMessageRequest(message: trimmedMessage, images: submittedImages, server: serverId)
            )
            
            apply(try await client.sendJSON(endpoint), statusLoaded: true)
        } catch {
            if message.isEmpty {
                message = trimmedMessage
            }
            if pendingImages.isEmpty {
                pendingImages = submittedImages
            }
            showsNewChatButton = !messages.isEmpty
            errorMessage = error.localizedDescription
            SystemAlert.error(error)
        }
        
        isSending = false
    }

    func importImages(from urls: [URL]) async {
        guard canImportImages(urls.count) else { return }

        isImportingImages = true
        defer {
            isImportingImages = false
        }

        do {
            let images = try await Task.detached {
                try urls.map(AgentChatImageInput.from)
            }.value
            pendingImages.append(contentsOf: images)
        } catch {
            SystemAlert.error(error.localizedDescription)
        }
    }

    func importImages(from items: [PhotosPickerItem]) async {
        guard canImportImages(items.count) else { return }

        isImportingImages = true
        defer {
            isImportingImages = false
        }

        do {
            var images: [AgentChatImageInput] = []
            for item in items {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    throw AgentChatImageInputError.unreadable
                }

                let suggestedName = item.itemIdentifier?.suggestedFilename ?? "image-\(UUID().uuidString)"
                images.append(try AgentChatImageInput(name: suggestedName, data: data))
            }
            pendingImages.append(contentsOf: images)
        } catch {
            SystemAlert.error(error.localizedDescription)
        }
    }

    func removeImage(_ image: AgentChatImageInput) {
        pendingImages.removeAll {
            $0.id == image.id
        }
    }

    private func canImportImages(_ count: Int) -> Bool {
        guard !isImportingImages else { return false }
        guard pendingImages.count + count <= AgentChatImageInput.maxCount else {
            SystemAlert.error(AgentChatImageInputError.tooMany.localizedDescription)
            return false
        }

        return true
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
        preferencesUpdatePending = true
        guard !isUpdatingPreferences else { return }

        isUpdatingPreferences = true
        defer {
            isUpdatingPreferences = false
        }

        while preferencesUpdatePending {
            preferencesUpdatePending = false
            errorMessage = nil

            let requestedProvider = provider
            let requestedModel = codexModel
            let requestedReasoningEffort = codexReasoningEffort
            let requestedFastMode = fastMode
            let requestedBuiltInModel = builtInModel
            let requestedBuiltInReasoningEffort = builtInReasoningEffort
            let requestedWebSearchEnabled = webSearchEnabled
            let requestedFullAccess = fullAccess
            let requestedApprovalPolicies = approvalPolicies

            if chatID == nil {
                await createChat(resetConversation: false)
                provider = requestedProvider
                codexModel = requestedModel
                codexReasoningEffort = requestedReasoningEffort
                fastMode = requestedFastMode
                if !requestedBuiltInModel.isEmpty {
                    builtInModel = requestedBuiltInModel
                    builtInReasoningEffort = requestedBuiltInReasoningEffort
                }
                webSearchEnabled = requestedWebSearchEnabled
                fullAccess = requestedFullAccess
                approvalPolicies = requestedApprovalPolicies
            }

            guard let requestedChatID = chatID else { return }

            do {
                let client = try CalagopusClientFactory.client()
                let request = AgentChatPreferencesRequest(
                    provider: requestedProvider,
                    codexModel: requestedModel,
                    codexReasoningEffort: requestedReasoningEffort,
                    fastMode: requestedFastMode,
                    builtInModel: requestedBuiltInModel,
                    builtInReasoningEffort: requestedBuiltInReasoningEffort.isEmpty ? nil : requestedBuiltInReasoningEffort,
                    webSearchEnabled: requestedWebSearchEnabled,
                    fullAccess: requestedFullAccess,
                    approvalPolicies: requestedApprovalPolicies
                )

                let endpoint = try CalagopusGeneratedOperations.putApiClientExtensionsDevYolkiServeragentChatsChatUuidPreferences.endpoint(
                    pathValues: ["chat_uuid": requestedChatID]
                )
                let preferencesEndpoint = CalagopusEndpoint(
                    operationID: endpoint.operationID,
                    method: endpoint.method,
                    path: endpoint.path,
                    queryItems: endpoint.queryItems,
                    body: .data(try request.jsonData(), contentType: "application/json")
                )

                let response = try await client.sendJSON(preferencesEndpoint)

                guard chatID == requestedChatID else {
                    preferencesUpdatePending = false
                    return
                }

                apply(
                    response,
                    statusLoaded: true,
                    preservesPreferences: true
                )

                if requestedProvider == .builtIn {
                    isCodexIntegrationLoggedOut = false
                }

                if preferencesUpdatePending {
                    preferencesUpdatePending = provider != requestedProvider
                        || codexModel != requestedModel
                        || codexReasoningEffort != requestedReasoningEffort
                        || fastMode != requestedFastMode
                        || builtInModel != requestedBuiltInModel
                        || builtInReasoningEffort != requestedBuiltInReasoningEffort
                        || webSearchEnabled != requestedWebSearchEnabled
                        || fullAccess != requestedFullAccess
                        || approvalPolicies != requestedApprovalPolicies
                }
            } catch {
                preferencesUpdatePending = false
                errorMessage = error.localizedDescription
                SystemAlert.error(error)
            }
        }
    }
    
    func selectBuiltInModel(_ model: AgentChatBuiltInModel) async {
        guard builtInModel != model.id else { return }

        builtInModel = model.id
        if !model.reasoningEfforts.contains(builtInReasoningEffort) {
            builtInReasoningEffort = model.reasoningEfforts.first ?? ""
        }
        await updatePreferences()
    }

    func selectBuiltInReasoningEffort(_ effort: String) async {
        guard builtInReasoningEffortOptions.contains(effort),
              builtInReasoningEffort != effort else {
            return
        }

        builtInReasoningEffort = effort
        await updatePreferences()
    }

    func startCodexOAuth() async -> URL? {
        if chatID == nil {
            await createChat(keepDisconnected: true)
        }
        
        guard let chatID else { return nil }
        
        do {
            let client = try CalagopusClientFactory.client()
            let endpoint = try CalagopusGeneratedOperations.postApiClientExtensionsDevYolkiServeragentChatsChatUuidCodexOauthStart.endpoint(pathValues: ["chat_uuid": chatID])
            
            if let oauthStart = CodexOAuthStart(try await client.sendJSON(endpoint)) {
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
                body: CodexOAuthFinishRequest()
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
                body: AgentChatApprovalRequest(approved: approved)
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
    
    private func apply(
        _ json: CalagopusJSON,
        statusLoaded: Bool = false,
        keepDisconnected: Bool = false,
        preservesPreferences: Bool = false
    ) {
        let chat = AgentChat(json)
        let shouldAnimateMessages = hasLoadedStatus && chatID == chat.id && shouldUseSiriAnimation
        let shouldPreservePreferences = preservesPreferences || isUpdatingPreferences
        
        chatID = chat.id
        title = chat.title
        showsNewChatButton = showsNewChatButton || !chat.messages.isEmpty
        phase = chat.phase
        configured = keepDisconnected ? false : chat.configured
        codexModelOptions = chat.codexModelOptions
        codexReasoningEffortOptions = chat.codexReasoningEffortOptions
        fastModeOptions = chat.fastModeOptions
        builtInModelOptions = chat.builtInModelOptions

        if !shouldPreservePreferences {
            provider = chat.provider
            codexModel = chat.codexModel
            codexReasoningEffort = chat.codexReasoningEffort
            fastMode = chat.fastMode
            builtInModel = chat.builtInModel
            builtInReasoningEffort = chat.builtInReasoningEffort
            webSearchEnabled = chat.webSearchEnabled
            fullAccess = chat.fullAccess
            approvalPolicies = chat.approvalPolicies
        }

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
        showsNewChatButton = false
        title = "Agent Chat"
        phase = "idle"
        configured = false
        provider = .codex
        message = ""
        fastMode = "standard"
        fastModeOptions = ["standard", "fast"]
        builtInModel = ""
        builtInReasoningEffort = ""
        builtInModelOptions = []
        webSearchEnabled = true
        fullAccess = false
        approvalPolicies = []
        messages = []
        pendingApproval = nil
        oauthStart = nil
        hasLoadedStatus = true
    }
    
    private func mergedMessages(
        from incomingMessages: [AgentChatMessage],
        animateAssistantMessages: Bool
    ) -> [AgentChatMessage] {
        let existingMessagesByID = messages.reduce(into: [String: AgentChatMessage]()) {
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
        
        guard shouldUseSiriAnimation else {
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
            
            guard shouldUseSiriAnimation else {
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
    
    private var shouldUseSiriAnimation: Bool {
        store.bigAssAnimations
    }
    
    private func commonPrefixCount(between lhs: String, and rhs: String) -> Int {
        zip(lhs, rhs)
            .prefix { $0 == $1 }
            .count
    }
}
