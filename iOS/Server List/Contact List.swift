//import SwiftUI
//
//struct ContactList: View {
//    private var vm = ContactProvider()
//    
//    var body: some View {
//        List {
//            Button("Enable") {
//                Task {
//                    await vm.enableExtensionExample()
//                }
//            }
//            
//            Button("Add") {
//                Task {
//                    await vm.saveNewContact()
//                }
//            }
//            
//            Button("Disable") {
//                Task {
//                    await vm.disable()
//                }
//            }
//        }
//        .navigationTitle("Contacts")
//    }
//}
//
//#Preview {
//    ContactList()
//}
