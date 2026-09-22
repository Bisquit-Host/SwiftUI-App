import SwiftUI

@Observable
final class FilePermissionsVM {
    let originalMode: String
    var modeInput = "" {
        didSet { updateToggles() }
    }
    var systemRead = false { didSet { updateInput() } }
    var systemWrite = false { didSet { updateInput() } }
    var systemExecute = false { didSet { updateInput() } }
    var adminRead = false { didSet { updateInput() } }
    var adminWrite = false { didSet { updateInput() } }
    var adminExecute = false { didSet { updateInput() } }
    var otherRead = false { didSet { updateInput() } }
    var otherWrite = false { didSet { updateInput() } }
    var otherExecute = false { didSet { updateInput() } }

    private var isSynchronizing = false
    private var specialBits: UInt16 = 0

    init(mode: String, modeBits: String) {
        let permissions = FilePermissionMode(octal: modeBits)
            ?? FilePermissionMode(octal: mode)
            ?? FilePermissionMode(symbolic: modeBits)
            ?? FilePermissionMode(symbolic: mode)
        originalMode = permissions?.octal ?? modeBits
        modeInput = originalMode
        updateToggles()
    }

    var validatedMode: String? {
        FilePermissionMode(octal: modeInput)?.octal
    }

    var isValid: Bool {
        validatedMode != nil
    }

    var isDifferent: Bool {
        guard let validatedMode else { return false }
        return validatedMode != originalMode
    }

    private func updateToggles() {
        guard !isSynchronizing, let mode = FilePermissionMode(octal: modeInput) else { return }
        isSynchronizing = true
        defer { isSynchronizing = false }

        specialBits = mode.value & 0o7000
        systemRead = mode.contains(0o400)
        systemWrite = mode.contains(0o200)
        systemExecute = mode.contains(0o100)
        adminRead = mode.contains(0o040)
        adminWrite = mode.contains(0o020)
        adminExecute = mode.contains(0o010)
        otherRead = mode.contains(0o004)
        otherWrite = mode.contains(0o002)
        otherExecute = mode.contains(0o001)
    }

    private func updateInput() {
        guard !isSynchronizing else { return }
        isSynchronizing = true
        defer { isSynchronizing = false }

        var value = specialBits
        if systemRead { value |= 0o400 }
        if systemWrite { value |= 0o200 }
        if systemExecute { value |= 0o100 }
        if adminRead { value |= 0o040 }
        if adminWrite { value |= 0o020 }
        if adminExecute { value |= 0o010 }
        if otherRead { value |= 0o004 }
        if otherWrite { value |= 0o002 }
        if otherExecute { value |= 0o001 }
        modeInput = FilePermissionMode(value: value).octal
    }
}
