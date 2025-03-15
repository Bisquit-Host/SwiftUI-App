import SwiftUI

extension View {
    func alert<Content: View, Background: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder background: @escaping () -> Background = {
            EmptyView()
        }
    ) -> some View {
        self
            .modifier(CustomAlertModifier(isPresented: isPresented, alertContent: content, background: background))
    }
}

/// Helper Modifier
fileprivate struct CustomAlertModifier<AlertContent: View, Background: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder var alertContent: AlertContent
    @ViewBuilder var background: Background
    
    @State private var showFullScreenCover = false
    @State private var animatedValue = false
    @State private var allowsInteraction = false
    
    func body(content: Content) -> some View {
        content
        /// Using Full Screen Cover to show alert content on top of the current context
            .fullScreenCover(isPresented: $showFullScreenCover) {
                ZStack {
                    if animatedValue {
                        alertContent
                            .allowsHitTesting(allowsInteraction)
                    }
                }
                .presentationBackground {
                    background
                        .allowsHitTesting(allowsInteraction)
                        .opacity(animatedValue ? 1 : 0)
                }
                .task {
                    try? await Task.sleep(for: .seconds(0.05))
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        animatedValue = true
                    }
                    
                    try? await Task.sleep(for: .seconds(0.3))
                    allowsInteraction = true
                }
            }
            .onChange(of: isPresented) { oldValue, newValue in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                
                if newValue {
                    withTransaction(transaction) {
                        showFullScreenCover = true
                    }
                } else {
                    allowsInteraction = false
                    
                    withAnimation(.easeInOut(duration: 0.3), completionCriteria: .removed) {
                        animatedValue = false
                    } completion: {
                        /// Removing full-screen-cover without animation
                        withTransaction(transaction) {
                            showFullScreenCover = false
                        }
                    }
                }
            }
    }
}
