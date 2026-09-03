import UIKit

final class RemoteTextCursorView: UIView {
    private let caretView = UIView()
    private let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        nameLabel.font = .preferredFont(forTextStyle: .caption2)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.clipsToBounds = true
        nameLabel.layer.cornerRadius = 2
        
        addSubview(caretView)
        addSubview(nameLabel)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    func configure(name: String, color: UIColor, caretRect: CGRect, visibleBounds: CGRect) {
        nameLabel.text = name.isEmpty ? "unknown" : name
        nameLabel.backgroundColor = color
        caretView.backgroundColor = color
        
        let preferredLabelSize = nameLabel.sizeThatFits(
            CGSize(width: visibleBounds.width, height: .greatestFiniteMagnitude)
        )
        let labelWidth = min(preferredLabelSize.width + 6, visibleBounds.width)
        let labelHeight = preferredLabelSize.height + 2
        let labelX = min(
            max(caretRect.minX - 1, visibleBounds.minX),
            max(visibleBounds.minX, visibleBounds.maxX - labelWidth)
        )
        let labelY = caretRect.minY - labelHeight >= visibleBounds.minY
            ? caretRect.minY - labelHeight
            : caretRect.maxY
        let caretFrame = CGRect(x: caretRect.minX - 1, y: caretRect.minY, width: 2, height: caretRect.height)
        let labelFrame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        let combinedFrame = caretFrame.union(labelFrame)
        
        frame = combinedFrame
        caretView.frame = caretFrame.offsetBy(dx: -combinedFrame.minX, dy: -combinedFrame.minY)
        nameLabel.frame = labelFrame.offsetBy(dx: -combinedFrame.minX, dy: -combinedFrame.minY)
    }
    
    static func color(from hex: String) -> UIColor {
        guard hex.count == 7, let value = Int(hex.dropFirst(), radix: 16) else {
            return .systemBlue
        }
        
        return UIColor(
            red: CGFloat((value >> 16) & 0xff) / 255,
            green: CGFloat((value >> 8) & 0xff) / 255,
            blue: CGFloat(value & 0xff) / 255,
            alpha: 1
        )
    }
}
