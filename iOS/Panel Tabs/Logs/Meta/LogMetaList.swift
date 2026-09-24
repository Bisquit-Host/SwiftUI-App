import SwiftUI
import Calagopus

struct LogMetaList: View {
    @State private var vm = LogMetaListVM()
    
    private let props: [String: CalagopusLogValue]
    
    init(_ props: [String: CalagopusLogValue]) {
        self.props = props
    }
    
    var body: some View {
        List {
            ForEach(vm.simpleProperties, id: \.key) { key, value in
                LogMetaCard(key: key, value: value)
            }
            
            ForEach(vm.arrayProperties, id: \.key) { key, values in
                Section(key) {
                    ForEach(values, id: \.self) {
                        Text($0)
                    }
                }
            }
        }
#if !os(watchOS)
        .textSelection(.enabled)
#endif
        .navigationTitle("Properties")
        .toolbarTitleDisplayMode(.inline)
        .foregroundStyle(.primary)
        .presentationDragIndicator(.hidden)
        .presentationDetents([.medium, .large], selection: .constant(.medium))
        .task {
            vm.prepareProperties(props)
        }
    }
}

#Preview {
    NavigationStack {
        Text("Preview")
            .sheet {
                LogMetaList([:])
            }
    }
    .darkSchemePreferred()
}
