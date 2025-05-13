import SwiftUI

struct GaugeTV: View {
    private let name, parameter: String
    
    init(_ name: String, param: String) {
        self.name = name
        self.parameter = param
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(name.capitalized)
            
            Spacer()
            
            Text(parameter)
                .bold()
        }
        .title3()
        .padding(.horizontal, 30)
        .padding(.trailing, 60)
    }
}
