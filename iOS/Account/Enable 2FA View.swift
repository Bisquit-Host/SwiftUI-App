import SwiftUI

struct Enable2FAView: View {
    @Environment(AccountVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var code = ""
    @State private var sheetQrCode = false
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("Code", text: $code)
                .padding()
                .textFieldStyle(.roundedBorder)
                .textContentType(.oneTimeCode)
                .keyboardType(.numberPad)
            
            Button {
                vm.enable2Fa(code) {
                    dismiss()
                }
            } label: {
                Text("Verify")
                    .semibold()
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.blue.gradient, in: .rect(cornerRadius: 16))
            }
            
            Spacer()
            
            HStack {
                VStack {
                    Button {
                        UIPasteboard.general.string = vm.qrCodeUrl
                        SystemAlert.copied()
                    } label: {
                        Text("Copy the setup url")
                            .semibold()
                            .foregroundStyle(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(.blue.gradient, in: .rect(cornerRadius: 16))
                    }
                    
                    if let url = URL(string: vm.qrCodeUrl) {
                        Link(destination: url) {
                            Text("Setup with an authenticator app")
                                .semibold()
                                .foregroundStyle(.white)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                                .background(.blue.gradient, in: .rect(cornerRadius: 16))
                        }
                    }
                }
                
                VStack {
                    if let url = URL(string: vm.qrCodeUrl) {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                                .title(.semibold)
                                .foregroundStyle(.white)
                                .frame(width: 55, height: 55)
                                .background(.blue.gradient, in: .rect(cornerRadius: 16))
                        }
                    }
                    
                    Button {
                        sheetQrCode = true
                    } label: {
                        Image(systemName: "qrcode")
                            .title(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 55, height: 55)
                            .background(.blue.gradient, in: .rect(cornerRadius: 16))
                    }
                }
            }
            .padding(.horizontal)
        }
        .sheet($sheetQrCode) {
            QRCodeView(vm.qrCodeUrl)
        }
    }
}

#Preview {
    Enable2FAView()
        .environment(AccountVM())
}
