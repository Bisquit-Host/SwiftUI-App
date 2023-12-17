import SwiftUI

struct DesignSettings: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    @State private var animate = true
    
    var body: some View {
        Section("Design") {
            Toggle("Transparent sheets", isOn: $settings.transparentSheet)
            
            Toggle("Transparent lists", isOn: $settings.transparentList)
            
            Toggle("Bisquit waterfall", isOn: $settings.enableBisquitFall)
            
            Toggle("Animate tabbar", isOn: $settings.animatedTabbar)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Tab icons bounce")
                    
                    Spacer()
                    
                    Image(systemName: "terminal")
                        .title3(.semibold)
                        .symbolEffect(settings.tabViewBouncesDown ? .bounce.down.byLayer : .bounce.up.byLayer, value: settings.tabViewBouncesDown)
                }
                .foregroundStyle(settings.animatedTabbar ? .primary : .secondary)
                
                Picker("", selection: $settings.tabViewBouncesDown) {
                    Text("Bounces Down")
                        .tag(true)
                    
                    Text("Bounces Up")
                        .tag(false)
                }
                .pickerStyle(.segmented)
            }
            .disabled(!settings.animatedTabbar)
            .padding(.vertical, 5)
        }
        .listRowBackground(settings.transparentList ? .clear : Color.list)
    }
}

#Preview {
    List {
        DesignSettings()
    }
    .environmentObject(SettingsStorage())
}
