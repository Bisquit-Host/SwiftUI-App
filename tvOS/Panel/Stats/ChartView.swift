import SwiftUI
import Charts

struct Value: Identifiable {
    let id: Int
    var value: Double
}

struct ChartView: View {
    let caption, unit: String
    let max: Double
    var values: [Value]
    
    var body: some View {
        VStack {
            Chart(values) { element in
                //                if store.showRuleMark {
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
