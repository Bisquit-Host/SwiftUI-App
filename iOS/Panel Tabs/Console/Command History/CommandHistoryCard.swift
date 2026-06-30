import SwiftUI

struct CommandHistoryCard: View {
    @Environment(ConsoleVM.self) private var vm
    
    private let command: ConsoleCommandSnippet
    
    init(_ command: ConsoleCommandSnippet) {
        self.command = command
    }
    
    var body: some View {
        Button {
            vm.useHistoryCommand(command.command)
        } label: {
            VStack(alignment: .leading) {
                Text(command.command)
                    .monospaced()
                
                Text(command.name)
                    .secondary()
            }
            .foregroundStyle(.foreground)
        }
    }
}

//#Preview {
//    CommandHistoryCard()
//        .environment(ConsoleVM())
//}
