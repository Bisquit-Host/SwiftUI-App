import Testing

@testable import Bisquit_Host

@MainActor
struct FilePermissionsVMTests {
    @Test func `all ordinary modes round trip through toggles`() {
        for value in UInt16(0)...UInt16(0o777) {
            let mode = FilePermissionMode(value: value).octal
            let vm = FilePermissionsVM(mode: mode, modeBits: "")
            #expect(vm.validatedMode == mode)
            #expect(!vm.isDifferent)
            vm.otherExecute.toggle()
            #expect(vm.validatedMode == FilePermissionMode(value: value ^ 1).octal)
            vm.otherExecute.toggle()
            #expect(!vm.isDifferent)
        }
    }

    @Test
    func `octal input updates every permission group`() {
        let vm = FilePermissionsVM(mode: "0644", modeBits: "rw-r--r--")
        vm.modeInput = "751"
        #expect(vm.systemRead && vm.systemWrite && vm.systemExecute)
        #expect(vm.adminRead && !vm.adminWrite && vm.adminExecute)
        #expect(!vm.otherRead && !vm.otherWrite && vm.otherExecute)
        #expect(vm.isDifferent)
    }

    @Test
    func `invalid or partial input preserves toggles and cannot be submitted`() {
        let vm = FilePermissionsVM(mode: "0644", modeBits: "rw-r--r--")
        for input in ["", "7", "75", "789", "a64", "-64", " 644", "10000"] {
            vm.modeInput = input
            #expect(!vm.isValid)
            #expect(vm.validatedMode == nil)
            #expect(vm.systemRead && vm.systemWrite && !vm.systemExecute)
            #expect(vm.adminRead && !vm.adminWrite && !vm.adminExecute)
            #expect(vm.otherRead && !vm.otherWrite && !vm.otherExecute)
        }
        vm.otherExecute = true
        #expect(vm.validatedMode == "645")
    }

    @Test
    func `symbolic input handles file type and special execute bits`() {
        #expect(FilePermissionMode(symbolic: "rw-r--r--")?.octal == "644")
        #expect(FilePermissionMode(symbolic: "-rwxr-xr-x")?.octal == "755")
        #expect(FilePermissionMode(symbolic: "-rwSr-Sr-T")?.octal == "7644")
        #expect(FilePermissionMode(symbolic: "-rwsr-sr-t")?.octal == "7755")
        #expect(FilePermissionMode(symbolic: "bad") == nil)
        #expect(FilePermissionMode(symbolic: "xxxxxxxxx") == nil)
    }

    @Test
    func `toggle edits preserve special bits`() {
        let vm = FilePermissionsVM(mode: "4755", modeBits: "-rwsr-xr-x")
        vm.otherWrite = true
        #expect(vm.validatedMode == "4757")
        vm.modeInput = "0644"
        vm.otherExecute = true
        #expect(vm.validatedMode == "645")
    }

    @Test
    func `malformed initial metadata stays invalid until edited`() {
        let vm = FilePermissionsVM(mode: "bad", modeBits: "bad")
        #expect(!vm.isValid)
        vm.modeInput = "600"
        #expect(vm.isValid)
        #expect(vm.isDifferent)
    }
}
