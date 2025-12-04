import ScrechKit

struct BillingHostingPlanCard: View {
    let plan: BillingHostingPlan
    let priceText: String
    let category: BillingHostingCategory
    var onPurchase: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .fontSize(18)
                    .padding(10)
                    .glassEffect(.regular.tint(tint.opacity(0.25)), in: .circle)
                    .foregroundStyle(tint)
                
                Text(plan.name)
                    .headline()
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text(priceText)
                        .monospacedDigit()
                        .subheadline(.semibold)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(tint.opacity(0.1), in: .capsule)
                        .overlay {
                            Capsule()
                                .stroke(tint.opacity(0.25), lineWidth: 1)
                        }
                    
                    Text("per month")
                        .caption()
                        .secondary()
                }
            }
            
            Divider()
                .overlay(tint.opacity(0.15))
            
            FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(Array(specs.enumerated()), id: \.offset) { _, item in
                    spec(item.icon, item.text)
                        .monospacedDigit()
                }
            }
            
            SFButton("cart.badge.plus") {
                onPurchase?()
            }
            .buttonStyle(.glassProminent)
            .tint(tint)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.primary.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: tint.opacity(0.05), radius: 12, y: 6)
    }
    
    private func spec(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .footnote()
                .secondary()
            
            Text(text)
                .footnote()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(tint.opacity(0.14), in: .capsule)
        .overlay {
            Capsule()
                .stroke(tint.opacity(0.35), lineWidth: 1)
        }
    }
    
    private func tag(_ text: String) -> some View {
        Text(text)
            .footnote()
            .secondary()
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(.background.opacity(0.6), in: .rect(cornerRadius: 10))
    }
    
    /// Simple flow layout that wraps items to the next line when there is no horizontal space left.
    private struct FlowLayout: Layout {
        var horizontalSpacing: CGFloat = 8
        var verticalSpacing: CGFloat = 8
        
        struct Cache {
            var sizes: [CGSize] = []
            var positions: [CGPoint] = []
            var size: CGSize = .zero
            var proposalWidth: CGFloat?
        }
        
        func makeCache(subviews: Subviews) -> Cache { Cache() }
        
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
    
    private var specs: [(icon: String, text: String)] {
        var items: [(String, String)] = [
            ("cpu", "\(plan.cpu.clean) vCPU"),
            ("memorychip", "\(plan.memoryGB.clean) GB RAM"),
            ("internaldrive", "\(plan.diskGB.clean) GB \(plan.diskType ?? "")".trimmingCharacters(in: .whitespaces))
        ]
        
        if let network = plan.networkDescription {
            items.append(("network", network))
        }
        
        if let databases = plan.databases {
            items.append(("externaldrive.fill", "\(databases) DBs"))
        }
        
        if let backups = plan.backups {
            items.append(("clock.arrow.circlepath", "\(backups) backups"))
        }
        
        if let allocations = plan.allocations {
            items.append(("number", "\(allocations) ports"))
        }
        
        return items
    }
    
    private var tint: Color {
        switch category {
        case .cloud: .orange
        case .game: .indigo
        case .bot: .green
        }
    }
}

#Preview {
    BillingHostingPlanCard(plan: .preview, priceText: "₽399", category: .game)
        .padding()
        .darkSchemePreferred()
}
