import SwiftUI

struct TwoFACodeInputView: View {
    @Binding var code: String
    
    var codeLength = 6
    var boxSpacing = 10.0
    var boxCornerRadius = 12.0
    var inputHeight = 64.0
    
    @FocusState private var isCodeFocused: Bool
    
    var body: some View {
        ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isCodeFocused)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .accessibilityHidden(true)
            
            GeometryReader { proxy in
                let width = max(40, (proxy.size.width - boxSpacing * CGFloat(codeLength - 1)) / CGFloat(codeLength))
                let height = min(inputHeight, max(52, width * 1.1))
                
                HStack(spacing: boxSpacing) {
                    ForEach(0..<codeLength, id: \.self) { index in
                        codeBox(at: index, width: width, height: height)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: inputHeight)
        }
        .frame(height: inputHeight)
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
    
    private func codeBox(at index: Int, width: CGFloat, height: CGFloat) -> some View {
        let digit = digit(at: index)
        let isActive = isActiveIndex(index)
        
        return Text(digit)
            .title2()
            .monospacedDigit()
            .frame(width: width, height: height)
            .background(.primary.opacity(0.04), in: .rect(cornerRadius: boxCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: boxCornerRadius)
                    .stroke(isActive ? Color.primary.opacity(0.35) : .primary.opacity(0.08), lineWidth: isActive ? 1.5 : 1)
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
