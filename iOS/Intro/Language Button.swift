import ScrechKit

struct LanguageButton: View {
    var body: some View {
        Button {
            openSettings()
        } label: {
            Image(.language)
                .resizable()
                .padding(8)
                .foregroundStyle(.white)
                .frame(width: 55, height: 55)
                .background(Color(0xffa938).gradient, 
                            in: .circle
                )
        }
    }
}

#Preview {
    LanguageButton()
}
