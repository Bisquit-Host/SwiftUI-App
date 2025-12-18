import SwiftUI

extension View {
    func sshTextFielgStyle() -> some View {
        self
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .textFieldStyle(.roundedBorder)
    }
}
