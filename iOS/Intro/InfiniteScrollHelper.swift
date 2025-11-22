import ScrechKit

struct InfiniteScrollHelper: UIViewRepresentable {
    @Binding private var contentSize: CGSize
    @Binding private var declarationRate: UIScrollView.DecelerationRate
    
    init(
        _ contentSize: Binding<CGSize>,
        declarationRate: Binding<UIScrollView.DecelerationRate>
    ) {
        _contentSize = contentSize
        _declarationRate = declarationRate
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(declarationRate: declarationRate, contentSize: contentSize)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        if let scrollView = view.scrollView {
            context.coordinator.defaultDelegate = scrollView.delegate
            scrollView.decelerationRate = declarationRate
            scrollView.delegate = context.coordinator
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.declarationRate = declarationRate
        context.coordinator.contentSize = contentSize
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var declarationRate: UIScrollView.DecelerationRate
        var contentSize: CGSize
        
        init(declarationRate: UIScrollView.DecelerationRate, contentSize: CGSize) {
            self.declarationRate = declarationRate
            self.contentSize = contentSize
        }
        
        /// Storing Default SwiftUI Delegate
        weak var defaultDelegate: UIScrollViewDelegate?
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            /// Updating Declaration Rate
            scrollView.decelerationRate = declarationRate
            
            let minX = scrollView.contentOffset.x
            
            if minX > contentSize.width {
                scrollView.contentOffset.x -= contentSize.width
            }
            
            if minX < 0 {
                scrollView.contentOffset.x += contentSize.width
            }
            
            /// Calling Default Delegate once our customization finished
            defaultDelegate?.scrollViewDidScroll?(scrollView)
        }
        
        /// Calling Other default Callbacks
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            defaultDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            defaultDelegate?.scrollViewDidEndDecelerating?(scrollView)
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            defaultDelegate?.scrollViewWillBeginDragging?(scrollView)
        }
        
        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            defaultDelegate?.scrollViewWillEndDragging?(
                scrollView,
                withVelocity: velocity,
                targetContentOffset: targetContentOffset
            )
        }
    }
}

fileprivate extension UIView {
    var scrollView: UIScrollView? {
        if let superview, superview is UIScrollView {
            superview as? UIScrollView
        } else {
            superview?.scrollView
        }
    }
}
