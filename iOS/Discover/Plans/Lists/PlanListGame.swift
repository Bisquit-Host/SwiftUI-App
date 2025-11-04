import SwiftUI

struct PlanListGame: View {
    @Environment(PlanListVM.self) private var vm
    
    @State private var selectedLocation = 1
    
    private var selectedPlans: [UniversalPlan] {
        vm.gamePlans.filter {
            $0.locationId == selectedLocation
        }
    }
    
    var body: some View {
        VStack {
            Picker("Location", selection: $selectedLocation) {
                ForEach(vm.gameLocations) {
                    Text($0.name)
                        .tag($0.id)
                }
            }
            .pickerStyle(.segmented)
            
            ForEach(selectedPlans) {
                PlanCard($0)
            }
        }
    }
}

#Preview {
    PlanListGame()
        .darkSchemePreferred()
        .environment(PlanListVM())
}
