import SwiftUI

struct ServerCardSuspended: View {
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    //    @State private var sheetSupport = false
    
    var body: some View {
        VStack {
            HStack(spacing: 32) {
                VStack {
                    Text(name)
                    
                    Text("Is Suspended")
                        .bold()
                }
                .title3()
                
                Image(systemName: "snowflake")
                    .largeTitle()
            }
            
            Capsule()
                .frame(width: 500, height: 5)
                .padding(.bottom)
            
            //            Button {
            //                sheetSupport = true
            //            } label: {
            Text("Contact support")
            //            }
        }
        //        .sheet($sheetSupport) {
        //            Support()
        //        }
    }
}

#Preview {
    ServerCardSuspended("Test Server")
}
