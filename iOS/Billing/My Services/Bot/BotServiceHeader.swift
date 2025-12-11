import SwiftUI

struct BotServiceHeader: View {
    @Environment(BotServiceDetailsVM.self) private var vm
    
    var body: some View {
        if let service = vm.service {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 8) {
                    Text(service.name)
                        .title3(.bold)
                    
                    Spacer()
                    
                    Capsule()
                        .fill(service.state.color.opacity(0.15))
                        .overlay {
                            Text(service.state.title)
                                .footnote(.semibold)
                                .foregroundStyle(service.state.color)
                                .padding(.horizontal, 10)
                        }
                        .frame(height: 30)
                }
                
                HStack(spacing: 10) {
                    Text(service.packageInfo.name)
                        .footnote()
                        .secondary()
                    
                    if let flag = service.location.flagUrl, let url = URL(string: flag) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .frame(width: 24, height: 16)
                                .clipShape(.rect(cornerRadius: 3))
                        } placeholder: {
                            Color.gray.opacity(0.15)
                                .frame(width: 24, height: 16)
                                .clipShape(.rect(cornerRadius: 3))
                        }
                    }
                    
                    Text(service.location.name)
                        .footnote()
                        .secondary()
                }
            }
        }
    }
}
