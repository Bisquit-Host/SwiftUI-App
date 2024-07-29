import SwiftUI
import PteroNet

struct LogDetailView: View {
    private let properties: [String: CodableValue]
    
    init(_ properties: [String: CodableValue]) {
        self.properties = properties
    }
    
    @State private var simpleProperties: [String: String] = [:]
    @State private var arrayProperties: [String: [String]] = [:]
    
    var body: some View {
        List {
            ForEach(simpleProperties.sorted { $0.key < $1.key }, id: \.key) { key, value in
#if os(tvOS)
                Button {
                    
                } label: {
                    HStack {
                        Text(key)
                        
                        Spacer()
                        
                        Text(value)
                            .foregroundStyle(.secondary)
                    }
                }
#else
                Section(key) {
                    Text(value)
                }
#endif
            }
            
            ForEach(arrayProperties.sorted { $0.key < $1.key }, id: \.key) { key, values in
                Section(key) {
                    ForEach(values, id: \.self) { value in
                        Text(value)
                    }
                }
            }
        }
#if !os(tvOS) && !os(watchOS)
        .textSelection(.enabled)
#endif
        .navigationTitle("Properties")
        .foregroundStyle(.primary)
        .toolbarTitleDisplayMode(.inline)
        .presentationDragIndicator(.hidden)
        .presentationDetents([.medium, .large])
        .task {
            prepareProperties(properties)
        }
    }
    
    func prepareProperties(_ properties: [String: CodableValue]) {
        properties.forEach { key, value in
            switch value {
            case .int(let x):
                simpleProperties[key] = String(x)
                
            case .string(let x):
                simpleProperties[key] = x
                
            case .bool(let x):
                simpleProperties[key] = String(x)
                
            case .array(let x):
                arrayProperties[key] = x
                
            case .none:
                simpleProperties[key] = "None"
            }
        }
    }
}

#Preview {
    NavigationView {
        Text("Preview")
            .sheet {
                LogDetailView(sampleJSON(.logAttributes))
            }
    }
}
