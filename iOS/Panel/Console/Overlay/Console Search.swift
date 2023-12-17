import ScrechKit

struct ConsoleSearch: View {
    @Environment(PanelVM.self) private var panelVM
    
    @State private var showSearch = false
    @State private var startTyping = false
    
    @FocusState private var focus
    
    var body: some View {
        @Bindable var binding = panelVM
        
        HStack {
            SFButton("magnifyingglass") {
                withAnimation {
                    showSearch.toggle()
                    
                    delay(0.5) {
                        withAnimation {
                            startTyping.toggle()
                            focus = true
                            panelVM.searchRule = ""
                            panelVM.fieldSearch = ""
                        }
                    }
                }
            }
            .font(startTyping ? .largeTitle : .title2)
            .semibold()
            .symbolVariant(startTyping ? .circle.fill : .none)
            .foregroundStyle(.primary)
            .frame(width: 35, height: 35)
            .padding(10)
            .background(.ultraThinMaterial, in: .circle)
            
            if showSearch {
                TextField("Search", text: $binding.searchRule)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .focused($focus)
                    .padding(.trailing)
            }
        }
        .background(.ultraThinMaterial, in: .capsule)
        .onChange(of: panelVM.fieldSearch) { _, search in
            withAnimation {
                panelVM.searchRule = search
            }
        }
    }
}

#Preview {
    ConsoleSearch()
        .environment(PanelVM(""))
}
