import SwiftUI
import SwiftTerm

struct SSHTerminalView: UIViewRepresentable {
    let viewModel: SSHTerminalVM
    
    func makeUIView(context: Context) -> TerminalView {
        let view = TerminalView(frame: .zero)
        
        view.backgroundColor = .black
        view.nativeBackgroundColor = .black
        view.nativeForegroundColor = .white
        
        viewModel.attach(terminalView: view)
        return view
    }
    
    func updateUIView(_ uiView: TerminalView, context: Context) {}
    
    static func dismantleUIView(_ uiView: TerminalView, coordinator: ()) {
        uiView.terminalDelegate = nil
    }
}
