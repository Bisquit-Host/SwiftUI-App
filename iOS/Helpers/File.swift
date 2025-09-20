private func customRound(_ value: Double) -> String {
        let roundedValue = round(value)
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = (roundedValue == value) ? 0 : 1
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }