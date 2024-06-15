import ScrechKit

struct LanguageButton: View {
    var body: some View {
        Button {
            openSettings()
        } label: {
            Image(systemName: "translate")
                .fontSize(26)
                .foregroundStyle(.white)
                .frame(width: 55, height: 55)
                .background(.cookie.gradient, in: .circle)
        }
    }
}

#Preview {
    LanguageButton()
}
