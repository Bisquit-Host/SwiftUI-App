import ScrechKit
import PteroNet

struct CommandLine: View {
    @Environment(ConsoleVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    @State private var text = ""
    @State private var showCommandLine = false
    @State private var showClearButton = false
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    
    @FocusState private var focusState
    @Namespace private var animation
    
    var body: some View {
        HStack {
            if !showCommandLine {
                SFButton("apple.terminal") {
                    offsetX = 0
                    offsetY = 0
                    
                    withAnimation {
                        showCommandLine = true
                    }
                    
                    delay(0.5) {
                        withAnimation {
                            focusState = true
                        }
                    }
                }
                .title2(.semibold)
                .foregroundColor(.primary)
                .frame(width: 35, height: 35)
                .padding(10)
                .background(.ultraThinMaterial, in: .circle)
                .matchedEffect("terminal", in: animation)
            } else {
                VStack {
                    HStack {
                        Group {
                            SFButton("doc.on.doc") {
                                UIPasteboard.general.string = text
                                
                                SystemAlert.copied()
                            }
                            
                            SFButton("doc.on.clipboard") {
                                if let string = UIPasteboard.general.string {
                                    text = string
                                }
                            }
                            
                            //                            SFButton("book") {
                            //
                            //                            }
                        }
                        .subheadline(.semibold)
                        .frame(width: 50, height: 32)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                        
                        Divider().frame(height: 25)
                        
                        Button("Spam") {
                            settings.spamEnabled.toggle()
                        }
                        .subheadline()
                        .foregroundStyle(settings.spamEnabled ? .black : .white)
                        .frame(width: 50, height: 32)
                        .background {
                            if settings.spamEnabled {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white)
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    HStack {
                        TextField("Type a command...", text: $text)
                            .autocorrectionDisabled()
                            .focused($focusState)
                            .textFieldStyle(.roundedBorder)
                        
                        if showClearButton {
                            SFButton("xmark.circle") {
                                text = ""
                            }
                            .semibold()
                            .foregroundStyle(.red)
                        }
                    }
                    
                    HStack {
                        SFButton("apple.terminal.fill") {
                            withAnimation {
                                focusState = false
                                showCommandLine = false
                            }
                        }
                        .title2(.semibold)
                        .foregroundColor(.primary)
                        .frame(width: 35, height: 35)
                        .padding(10)
                        .background(.ultraThinMaterial, in: .circle)
                        .matchedEffect("terminal", in: animation)
                        
                        Spacer()
                        
                        Button {
                            ConsoleVM(id).sendCommand(text)
                            
                            withAnimation {
                                offsetX = 40
                                offsetY = -40
                            }
                            
                            delay(0.5) {
                                withAnimation {
                                    showCommandLine = false
                                }
                            }
                        } label: {
                            ZStack {
                                Group {
                                    Image(systemName: "paperplane")
                                        .offset(x: offsetX, y: offsetY)
                                        .frame(width: 35, height: 35)
                                        .padding(10)
                                        .background(.ultraThinMaterial, in: .circle)
                                    
                                    Image(systemName: "paperplane")
                                        .offset(x: offsetX - 40, y: offsetY + 40)
                                }
                                .clipShape(.circle)
                            }
                            .foregroundColor(.primary)
                            .title2(.semibold)
                        }
                    }
                    .padding(4)
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 32,
                        bottomLeadingRadius: 32,
                        bottomTrailingRadius: 32,
                        topTrailingRadius: 32
                    )
                )
                .padding()
                .offset(y: -32)
            }
        }
        .onChange(of: text) {
            withAnimation {
                if text.isEmpty {
                    showClearButton = false
                } else {
                    showClearButton = true
                }
            }
        }
    }
}

#Preview {
    CommandLine("")
        .environment(ConsoleVM(""))
        .environmentObject(SettingsStorage())
}
