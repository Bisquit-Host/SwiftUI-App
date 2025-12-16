#if canImport(SwiftUI) && canImport(SwiftTerm) && canImport(NIOSSH)
import SwiftTerm
import SwiftUI

#if canImport(UIKit)
import UIKit

struct SSHTerminalView: UIViewRepresentable {
    @ObservedObject var viewModel: SSHTerminalVM

    func makeUIView(context: Context) -> TerminalView {
        let view = TerminalView(frame: .zero)
        view.backgroundColor = .black
        view.nativeBackgroundColor = .black
        view.nativeForegroundColor = .white
        viewModel.attach(terminalView: view)
        return view
    }

    func updateUIView(_ uiView: TerminalView, context: Context) {
    }

    static func dismantleUIView(_ uiView: TerminalView, coordinator: ()) {
        uiView.terminalDelegate = nil
    }
}
#elseif canImport(AppKit)
import AppKit

struct SSHTerminalView: NSViewRepresentable {
    @ObservedObject var viewModel: SSHTerminalViewModel

    func makeNSView(context: Context) -> TerminalView {
        let view = TerminalView(frame: .zero)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        view.nativeBackgroundColor = .black
        view.nativeForegroundColor = .white
        viewModel.attach(terminalView: view)
        return view
    }

    func updateNSView(_ nsView: TerminalView, context: Context) {
    }

    static func dismantleNSView(_ nsView: TerminalView, coordinator: ()) {
        nsView.terminalDelegate = nil
    }
}
#endif
#endif
