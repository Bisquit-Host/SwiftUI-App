import ScrechKit
//import HighlightedTextEditor

//let betweenUnderscores = try! NSRegularExpression(pattern: "_[^_]+_", options: [])

struct TextFile: View {
    private var vm: TextFileVM
    
    private let id, path, name: String
    
    init(
        _ id: String,
        path: String,
        name: String,
        model: TextFileVM = TextFileVM("")
    ) {
        self.id = id
        self.path = path
        self.name = name
        self.vm = TextFileVM(id)
    }
    
    //    private let rules: [HighlightRule] = [
    //        HighlightRule(pattern: betweenUnderscores, formattingRules: [
    //            TextFormattingRule(fontTraits: [.traitItalic, .traitBold]),
    //            TextFormattingRule(key: .foregroundStyle, value: UIColor.red),
    //            TextFormattingRule(key: .underlineStyle) { content, range in
    //                if content.count > 10 {
    //                    return NSUnderlineStyle.double.rawValue
    //                } else {
    //                    return NSUnderlineStyle.single.rawValue
    //                }
    //            }
    //        ])
    //    ]
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack {
#if os(iOS)
            Button {
                vm.writeFile(vm.text, path: path + name)
            } label: {
                Text("Save changes")
                    .foregroundStyle(.yellow)
                    .title2(.bold)
                    .padding(10)
                    .overlay {
                        Capsule()
                            .stroke(.gray.opacity(0.5), lineWidth: 3)
                    }
            }
            
            //                HighlightedTextEditor(text: $text, highlightRules: rules)
            //                    .padding(10)
            //                    .autocorrectionDisabled()
            
            TextEditor(text: $vm.text)
                .padding(10)
                .disableAutocorrection(true)
                .onSubmit {
                    print("Submit")
                }
#elseif os(watchOS)
            ScrollView {
                Text(vm.text)
            }
#elseif os(tvOS)
            Text(vm.text)
                .navigationTitle(name)
#endif
        }
        .navigationTitle(name)
        .task {
            vm.getFileContents(path + name)
        }
        .toolbar {
            ShareLink(item: vm.text)
            
            if vm.showPrettyButton {
                
                SFButton("ellipsis.curlybraces") {
                    vm.makePretty()
                }
            }
        }
    }
}

#Preview {
    TextFile("", path: "", name: "")
}
