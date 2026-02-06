import SwiftUI
import Pow

struct TOTPInputField: View {
    @Binding var code: String
    
    var codeLength = 6
    var boxSpacing = 10.0
    var inputHeight = 64.0
    var loginAttempts = 0
    
    @FocusState private var isCodeFocused: Bool
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        field
        .contentShape(.rect)
        .onTapGesture {
            isCodeFocused = true
        }
        .onAppear {
            isCodeFocused = true
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("2FA code")
        .accessibilityValue(accessibilityValue)
    }

    @ViewBuilder
    private var field: some View {
        let base = ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isCodeFocused)
                .frame(1)
                .opacity(0.01)
                .accessibilityHidden(true)
            
            GeometryReader { proxy in
                let width = max(40, (proxy.size.width - boxSpacing * CGFloat(codeLength - 1)) / CGFloat(codeLength))
                let height = min(inputHeight, max(52, width * 1.1))
                
                HStack(spacing: boxSpacing) {
                    ForEach(0..<codeLength, id: \.self) { index in
                        TOTPInputFieldCell(
                            digit: digit(at: index),
                            isActive: isActiveIndex(index),
                            width: width,
                            height: height
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: inputHeight)
        }
        .frame(height: inputHeight)
        
        if reduceMotion || !store.bigAssAnimations {
            base
        } else {
            base.changeEffect(.shake(rate: .fast), value: loginAttempts)
        }
    }
    
    private func digit(at index: Int) -> String {
        guard index < code.count else { return "" }
        let stringIndex = code.index(code.startIndex, offsetBy: index)
        
        return String(code[stringIndex])
    }
    
    private func isActiveIndex(_ index: Int) -> Bool {
        guard isCodeFocused else { return false }
        
        if code.count >= codeLength {
            return index == codeLength - 1
        }
        
        return index == code.count
    }
    
    private var accessibilityValue: String {
        guard !code.isEmpty else { return "Empty" }
        return code.map { String($0) }.joined(separator: " ")
    }
}
