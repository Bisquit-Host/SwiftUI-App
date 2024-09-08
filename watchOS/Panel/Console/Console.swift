import ScrechKit

struct Console: View {
    @Environment(PanelVM.self) private var panelVM
    
    var body: some View {
        @Bindable var panelVM = panelVM
        
        ScrollView {
            ForEach(panelVM.messages, id: \.self) { message in
                Text(message)
                    .footnote()
                //.fontDesign(fontDesign)
                //.fontSize(fontSize)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical)
        }
        .navigationTitle("Console")
        .sheet($panelVM.showFormatting) {
            Text("Formatting")
        }
        .overlay(alignment: .bottomTrailing) {
            SFButton("bold.italic.underline") {
                panelVM.showFormatting = true
            }
            .headline()
            .padding(5)
            .background(.blue, in: .capsule)
            .padding(20)
            .buttonStyle(.plain)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    Console()
        .environment(PanelVM(""))
}
