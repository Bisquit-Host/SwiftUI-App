import ScrechKit
import Calagopus

@Observable
final class TextFileVM {
    private let id: String
    private let path: String

    @ObservationIgnored private var collaborationSession: CalagopusFileCollaborationSession?
    @ObservationIgnored private var collaborationUpdateTask: Task<Void, Never>?
    @ObservationIgnored private var collaborationSelectionTask: Task<Void, Never>?
    @ObservationIgnored private var saveTimeoutTask: Task<Void, Never>?
    @ObservationIgnored private var pendingCollaborationText: String?
    @ObservationIgnored private var pendingRemoteText: String?
    @ObservationIgnored private var pendingSelection: (anchor: Int, head: Int)?
    @ObservationIgnored private var isApplyingRemoteText = false

    init(_ id: String, path: String = "") {
        self.id = id
        self.path = path
    }

    var text = "" {
        didSet {
            guard text != oldValue, isCollaborating, !isApplyingRemoteText else { return }

            collaborationDirty = true
            queueCollaborationUpdate()
        }
    }

    private(set) var initialText = ""
    private(set) var showPrettyButton = false
    private(set) var isCollaborating = false
    private(set) var isSaving = false
    private(set) var remoteCursors: [CalagopusFileCollaborationCursor] = []
    private(set) var selectedRange = NSRange()
    private var collaborationDirty = false

    var hasUnsavedChanges: Bool {
        collaborationDirty || initialText != text
    }

    func start() async {
        await getFileContents()

        guard !Task.isCancelled else { return }
        await connectCollaboration()
    }

    func disconnect() {
        collaborationUpdateTask?.cancel()
        collaborationUpdateTask = nil
        collaborationSelectionTask?.cancel()
        collaborationSelectionTask = nil
        saveTimeoutTask?.cancel()
        saveTimeoutTask = nil
        pendingCollaborationText = nil
        pendingRemoteText = nil
        pendingSelection = nil
        collaborationSession?.disconnect()
        collaborationSession = nil
        isCollaborating = false
        remoteCursors = []
        isSaving = false
    }

    func selectionChanged(_ range: NSRange) {
        let location = min(range.location, text.utf16.count)
        let length = min(range.length, text.utf16.count - location)
        let normalizedRange = NSRange(location: location, length: length)

        guard selectedRange != normalizedRange else { return }

        selectedRange = normalizedRange

        if isCollaborating {
            queueSelectionUpdate()
        }
    }

    func makePretty() {
        if let pretty = prettyJSON(text) {
            text = pretty
            showPrettyButton = false
        }
    }

    func save() async {
        guard hasUnsavedChanges else { return }

        isSaving = true

        if isCollaborating, let collaborationSession {
            await collaborationUpdateTask?.value

            do {
                if let pendingCollaborationText {
                    self.pendingCollaborationText = nil
                    try await collaborationSession.updateText(pendingCollaborationText)
                }

                try await collaborationSession.save()
                startSaveTimeout()
                return
            } catch {
                collaborationFailed(error)
            }
        }

        await writeFile()
    }

    private func getFileContents() async {
        do {
            let model = try await CalagopusNet.client().fileContents(server: id, path: path)
            text = model
            initialText = model
            checkPrettiness()
        } catch is CancellationError {
            return
        } catch {
            SystemAlert.error(error)
        }
    }

    private func writeFile() async {
        do {
            try await CalagopusNet.client().writeFile(server: id, path: path, contents: text)
            initialText = text
            collaborationDirty = false
            isSaving = false
            SystemAlert.changesSaved()
        } catch {
            isSaving = false
            SystemAlert.error(error)
        }
    }

    private func connectCollaboration() async {
        do {
            let session = CalagopusFileCollaborationSession(
                client: try CalagopusNet.client(),
                serverID: id,
                path: path
            )
            collaborationSession = session

            let events = try await session.connect()
            for try await event in events {
                try Task.checkCancellation()
                handle(event)
            }
        } catch is CancellationError {
            disconnect()
        } catch {
            collaborationFailed(error, showAlert: false)
        }
    }

    private func handle(_ event: CalagopusFileCollaborationEvent) {
        switch event {
        case .synced(let text, let dirty):
            pendingRemoteText = nil
            applyRemoteText(text)
            initialText = text
            collaborationDirty = dirty
            isCollaborating = true
            queueSelectionUpdate()

        case .textChanged(let text):
            pendingRemoteText = text
            collaborationDirty = true

        case .localSelection(let selection):
            selectedRange = NSRange(
                location: min(selection.anchor, selection.head),
                length: abs(selection.head - selection.anchor)
            )
            applyPendingRemoteText()

        case .cursors(let cursors):
            applyPendingRemoteText()
            remoteCursors = cursors

        case .participants:
            break

        case .saved:
            saveTimeoutTask?.cancel()
            saveTimeoutTask = nil
            initialText = text
            collaborationDirty = false

            if isSaving {
                isSaving = false
                SystemAlert.changesSaved()
            }

        case .error(let message):
            if isSaving {
                saveTimeoutTask?.cancel()
                saveTimeoutTask = nil
                isSaving = false
                SystemAlert.error(CalagopusFileCollaborationError.yjs(message))
            } else {
                Logger().error("File collaboration error: \(message)")
            }
        }
    }

    private func applyRemoteText(_ text: String) {
        isApplyingRemoteText = true
        self.text = text
        isApplyingRemoteText = false
        checkPrettiness()
    }

    private func applyPendingRemoteText() {
        guard let pendingRemoteText else { return }
        self.pendingRemoteText = nil
        applyRemoteText(pendingRemoteText)
    }

    private func queueCollaborationUpdate() {
        pendingCollaborationText = text

        guard collaborationUpdateTask == nil else { return }

        collaborationUpdateTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(50))

                while let pendingCollaborationText {
                    self.pendingCollaborationText = nil
                    try await collaborationSession?.updateText(pendingCollaborationText)
                }
            } catch is CancellationError {
                return
            } catch {
                collaborationFailed(error)
            }

            collaborationUpdateTask = nil

            if pendingCollaborationText != nil {
                queueCollaborationUpdate()
            }
        }
    }

    private func queueSelectionUpdate() {
        pendingSelection = (
            anchor: selectedRange.location,
            head: selectedRange.location + selectedRange.length
        )

        guard collaborationSelectionTask == nil else { return }

        collaborationSelectionTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(30))

                while let pendingSelection {
                    self.pendingSelection = nil
                    try await collaborationSession?.updateSelection(
                        anchor: pendingSelection.anchor,
                        head: pendingSelection.head
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                Logger().error("Could not update collaborative cursor: \(error.localizedDescription)")
            }

            collaborationSelectionTask = nil

            if pendingSelection != nil {
                queueSelectionUpdate()
            }
        }
    }

    private func startSaveTimeout() {
        saveTimeoutTask?.cancel()
        saveTimeoutTask = Task {
            do {
                try await Task.sleep(for: .seconds(15))
            } catch {
                return
            }

            guard isSaving else { return }
            isSaving = false
            SystemAlert.error(URLError(.timedOut))
        }
    }

    private func collaborationFailed(_ error: Error, showAlert: Bool = true) {
        collaborationSession?.disconnect()
        collaborationSession = nil
        pendingRemoteText = nil
        isCollaborating = false
        remoteCursors = []

        if showAlert {
            SystemAlert.error(error)
        } else {
            Logger().error("Collaborative editing unavailable: \(error.localizedDescription)")
        }
    }

    private func checkPrettiness() {
        showPrettyButton = prettyJSON(text).map { $0 != text } ?? false
    }
}
