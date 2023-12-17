import SwiftUI
import ScrechKit
//import HighlightedTextEditor

//let betweenUnderscores = try! NSRegularExpression(pattern: "_[^_]+_", options: [])

struct Des_Text: View {
    private var vm: DesTextVM
    
    private let id, path, name: String
    
    init(_ id: String,
         path: String,
         name: String,
         model: DesTextVM = DesTextVM("")
    ) {
        self.id = id
        self.path = path
        self.name = name
        self.vm = DesTextVM(id)
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
        @Bindable var binding = vm
        
        VStack {
#if os(iOS)
            Text("Save changes")
                .foregroundStyle(.yellow)
                .title2(.bold)
                .padding(10)
                .overlay {
                    Capsule()
                        .stroke(.gray.opacity(0.5), lineWidth: 3)
                }
                .onTapGesture {
                    vm.writeFile(vm.text, path: path)
                }
            //                HighlightedTextEditor(text: $text, highlightRules: rules)
            //                    .padding(10)
            //                    .autocorrectionDisabled()
            
            TextEditor(text: $binding.text)
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
        .onAppear {
            vm.getFileContents(path + name)
        }
    }
}

#Preview {
    Des_Text("", path: "", name: "")
}
