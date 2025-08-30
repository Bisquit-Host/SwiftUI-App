import SwiftUI

struct NewServerList: View {
    @Environment(ServerListVM.self) private var vm
    
    @State private var isCompactMode = true
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if isCompactMode {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(vm.servers) {
                            CompactServerCard($0)
                        }
                    }
                    .padding()
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(vm.servers) {
                            NewServerCard($0)
                        }
                    }
                    .padding()
                }
            }
            .scrollIndicators(.never)
            .background {
                LinearGradient(
                    gradient: Gradient(colors: [
                        .blue.opacity(0.1),
                        .purple.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isCompactMode.toggle()
                    } label: {
                        Image(systemName: isCompactMode ? "rectangle.grid.1x2" : "square.grid.2x2")
                    }
                }
            }
        }
    }
}

#Preview {
    NewServerList()
}
