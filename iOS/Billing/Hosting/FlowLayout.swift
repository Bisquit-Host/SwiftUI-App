import SwiftUI

/// Simple flow layout that wraps items to the next line when there is no horizontal space left
struct FlowLayout: Layout {
    var horizontalSpacing = 8.0
    var verticalSpacing = 8.0
    
    struct Cache {
        var sizes: [CGSize] = []
        var positions: [CGPoint] = []
        var size: CGSize = .zero
        var proposalWidth: CGFloat?
    }
    
    func makeCache(subviews: Subviews) -> Cache {
        Cache()
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let result = compute(proposal: proposal, subviews: subviews)
        cache = result
        
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        let proposalWidth = proposal.width ?? bounds.width
        let needsRecompute = cache.positions.isEmpty || cache.proposalWidth != proposalWidth
        let result = needsRecompute ? compute(proposal: proposal, subviews: subviews) : cache
        
        for (index, subview) in subviews.enumerated() {
            let position = result.positions[index]
            let size = result.sizes[index]
            
            subview.place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
        }
    }
    
    private func compute(proposal: ProposedViewSize, subviews: Subviews) -> Cache {
        guard !subviews.isEmpty else { return Cache() }
        
        var cache = Cache()
        cache.sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxLineWidth: CGFloat = 0
        
        for size in cache.sizes {
            if currentX > 0 && currentX + size.width > maxWidth {
                maxLineWidth = max(maxLineWidth, currentX - horizontalSpacing)
                currentX = 0
                currentY += rowHeight + verticalSpacing
                rowHeight = 0
            }
            
            cache.positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + horizontalSpacing
            rowHeight = max(rowHeight, size.height)
        }
        
        maxLineWidth = max(maxLineWidth, currentX > 0 ? currentX - horizontalSpacing : 0)
        
        let height = currentY + rowHeight
        cache.size = CGSize(width: maxWidth.isFinite ? maxWidth : maxLineWidth, height: height)
        cache.proposalWidth = proposal.width ?? cache.size.width
        
        return cache
    }
}
