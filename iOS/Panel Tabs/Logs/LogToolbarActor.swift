import SwiftUI
import PteroNet

struct LogToolbarActor: View {
    @Environment(LogVM.self) private var vm
    
    private let actor: LogRelationships?
    
    init(_ actor: LogRelationships?) {
        self.actor = actor
    }
    
    var body: some View {
        if let actor {
            Button {
                if vm.selectedActor == actor {
                    vm.selectedActor = nil
                } else {
                    vm.selectedActor = actor
                }
            } label: {
                if let username = actor.actor.attributes?.username {
                    Text(username)
                    
                    if let email = actor.actor.attributes?.email {
                        Text(email)
                    }
                } else {
                    Text("System")
                }
                
                if vm.selectedActor == actor {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

#Preview {
    LogToolbarActor(PreviewProp.logAttributes.relationships)
        .darkSchemePreferred()
        .environment(LogVM(""))
}
