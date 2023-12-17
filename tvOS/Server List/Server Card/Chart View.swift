import SwiftUI
import Charts

struct Value: Identifiable {
    let id: Int
    var value: Double
}

struct ChartView: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    private let caption, unit: String
    private let max: Double
    private var values: [Value]
    
    init(_ caption: String,
         unit: String,
         max: Double,
         values: [Value]
    ) {
        self.caption = caption
        self.unit = unit
        self.max = max
        self.values = values
    }
    
    var body: some View {
        VStack {
            Chart(values, id: \.id) { element in
                //                if settings.showRuleMark {
                //                    RuleMark(y: .value("", max))
                //                        .foregroundStyle(.red)
                //                }
                
                LineMark(
                    x: .value("", element.id),
                    y: .value("", element.value)
                )
                .lineStyle(StrokeStyle(lineWidth: 7))
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis(.hidden)
            .padding(5)
            
            HStack(alignment: .bottom, spacing: 0) {
                Text(caption + " ")
                    .title3()
                
                Text(unit)
                    .footnote()
                    .foregroundStyle(.gray)
            }
        }
        .bold()
    }
}
