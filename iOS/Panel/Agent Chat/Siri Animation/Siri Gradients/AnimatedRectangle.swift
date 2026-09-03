import SwiftUI

struct AnimatedRectangle: Shape {
    var padding = 8.0
    var cornerRadius: CGFloat
    var t: CGFloat
    
    var animatableData: CGFloat {
        get {
            t
        } set {
            t = newValue
        }
    }
    
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let bounds = rect.insetBy(dx: padding, dy: padding)
        let radius = min(cornerRadius, min(bounds.width, bounds.height) / 2)
        
        // Define the initial points
        let initialPoints = [
            CGPoint(x: bounds.minX + radius,              y: bounds.minY),
            CGPoint(x: bounds.minX + bounds.width * 0.25, y: bounds.minY),
            CGPoint(x: bounds.minX + bounds.width * 0.75, y: bounds.minY),
            CGPoint(x: bounds.maxX - radius,              y: bounds.minY),
            CGPoint(x: bounds.maxX,                       y: bounds.minY + radius),
            CGPoint(x: bounds.maxX,                       y: bounds.minY + bounds.height * 0.25),
            CGPoint(x: bounds.maxX,                       y: bounds.minY + bounds.height * 0.75),
            CGPoint(x: bounds.maxX,                       y: bounds.maxY - radius),
            CGPoint(x: bounds.maxX - radius,              y: bounds.maxY),
            CGPoint(x: bounds.minX + bounds.width * 0.75, y: bounds.maxY),
            CGPoint(x: bounds.minX + bounds.width * 0.25, y: bounds.maxY),
            CGPoint(x: bounds.minX + radius,              y: bounds.maxY),
            CGPoint(x: bounds.minX,                       y: bounds.maxY - radius),
            CGPoint(x: bounds.minX,                       y: bounds.minY + bounds.height * 0.75),
            CGPoint(x: bounds.minX,                       y: bounds.minY + bounds.height * 0.25),
            CGPoint(x: bounds.minX,                       y: bounds.minY + radius)
        ]
        
        //        // Define the arc centers
        //        let initialArcCenters = [
        //            CGPoint(x: padding + radius, y: padding + radius),                    // Top-left
        //            CGPoint(x: width - padding - radius, y: padding + radius),           // Top-right
        //            CGPoint(x: width - padding - radius, y: height - padding - radius), // Bottom-right
        //            CGPoint(x: padding + radius, y: height - padding - radius)         // Bottom-left
        //        ]
        
        // Animate points
        let points = initialPoints.map { point in
            CGPoint(
                x: point.x + 10 * sin(t + point.y * 0.1),
                y: point.y + 10 * sin(t + point.x * 0.1)
            )
        }
        
        // Animate arc centers
        // let arcCenters = initialArcCenters.map { center in
        //     CGPoint(
        //         x: center.x + 10 * sin(t + center.y * 0.3),
        //         y: center.y + 10 * sin(t + center.x * 0.3)
        //     )
        // }
        
        // Draw path
        path.move(to: CGPoint(x: bounds.minX, y: bounds.minY + radius))
        
        // Top-left corner
        // path.addArc(center: arcCenters[0], radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        
        // Top edge
        for point in points[0...2] {
            path.addLine(to: point)
        }
        
        // Top-right corner
        // path.addArc(center: arcCenters[1], radius: radius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
        
        // Right edge
        for point in points[4...7] {
            path.addLine(to: point)
        }
        
        // Bottom-right corner
        // path.addArc(center: arcCenters[2], radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        
        // Bottom edge
        for point in points[8...10] {
            path.addLine(to: point)
        }
        
        // Bottom-left corner
        // path.addArc(center: arcCenters[3], radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        
        // Left edge
        for point in points[11...14] {
            path.addLine(to: point)
        }
        
        path.closeSubpath()
        
        return path
    }
}
