import SwiftUI

struct InfoTabLogs: View {
    @Environment(LogVM.self) private var vm
    
    @State private var sheetLogs = false
    
    var body: some View {
        Button {
            sheetLogs = true
        } label: {
            VStack(spacing: 5) {
                if vm.logs.isEmpty {
                    Image(systemName: "list.bullet.rectangle.fill")
                        .tertiary()
                    
                    Text("Logs")
                        .semibold()
                } else {
                    Text("Logs")
                        .semibold()
                        .rounded()
                    
                    if let log = vm.logs.first {
                        LogCard(log, showInfoButton: false)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    let count = vm.logs.count
                    
                    if count > 0 {
                        let chevron = Image(systemName: "arrow.right")
                        
                        Text("\(count - 1) more entries \(chevron)")
                            .caption2()
                            .tertiary()
                    }
                }
            }
            .footnote()
            .padding()
            .frame(minHeight: 55)
            .frame(maxWidth: .infinity, alignment: .center)
            .foregroundStyle(.foreground)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.gray.opacity(0.25), lineWidth: 1)
            }
        }
        .sheet($sheetLogs) {
            LogListParent()
                .environment(vm)
        }
    }
}
