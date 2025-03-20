import ScrechKit

//// setup connectioin to the ViewModel (Checklist.swift)
//@ObservedObject var checklist = Checklist()
//@State var newCheckListItemViewIsVisible    = false
//@State var addButtonDisabled                = false
//@State var isEditing = false
//
//// User interface content and layout
//var body: some View {
//    NavigationView {
//        List {
//            ForEach (checklist.items) { index in
//                RowView(checklistItem: self.$checklist.items[index])
//            }
//            .onDelete(perform: checklist.deleteListItem)
//            .onMove(perform: checklist.moveListItem)
//        }
//        .navigationBarItems(leading:
//            HStack {
//                //EditButton()
//                Button {
//                    self.isEditing.toggle()
//                    self.addButtonDisabled.toggle()
//                } label: {
//                    if self.isEditing {
//                        Text("Done")
//                    } else {
//                        Image(systemName: "pencil.circle.fill").imageScale(.large)
//                    }
//                }
//                Button(action: {
//                    self.newCheckListItemViewIsVisible.toggle()
//                    print(self.newCheckListItemViewIsVisible)
//                }) {
//                    //Text("Add")
//                    Image(systemName: "plus.circle.fill").imageScale(.large)
//                }.disabled(addButtonDisabled)
//            }, trailing:
//            HStack {
//                Button {
//                    print("We are in CheckListView.swift - the VIEW file of the MVVM pattern")
//                    print("Before pressing the About button the showAbout bool was \(self.checklist.showsAbout)")
//                    self.checklist.showsAbout.toggle()
//                    print("After pressing the About button the showAbout bool was \(self.checklist.showsAbout)")
//                } label: {
//                    Text("About")
//                }
//                .alert(isPresented: self.$checklist.showsAbout) {
//                    Alert(title: Text(checklist.aboutButton()))
//                }
//
//                Button(action: {
//                    print("We are in CheckListView.swift - the VIEW file of the MVVM pattern")
//                    print("Before pressing the Help button the showHelp bool was \(self.checklist.showsHelp)")
//                    self.checklist.showsHelp.toggle()
//                    print("After pressing the Help button the showHelp bool was \(self.checklist.showsHelp)")
//                }) {
//                    Text("Help")
//                }
//                .alert(isPresented: self.$checklist.showsHelp) {
//                    Alert(title: Text(checklist.helpButton()))
//                }
//            }
//        )
//            .navigationBarTitle("Checklist", displayMode: .inline)
//            .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive)).animation(Animation.spring())
//        .onAppear {
//            self.checklist.printCheckListItemsContents()
//            self.checklist.saveListItems()
//        }
//    }
//    .sheet($newCheckListItemViewIsVisible) {
//        NewChecklistItemView(checklist: self.checklist)
//    }
//}

struct ApikeyList: View {
    @Environment(ApikeyVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var sheetCreate = false
    
    var body: some View {
        List {
#warning("Remove")
            EditButton()
                .transparentSection()
            
            Section {
                ForEach(vm.keys, id: \.attributes.id) { key in
                    ApikeyCard(key)
                }
                .onDelete(perform: deleteItems)
            }
            .transparentSection()
        }
        .navigationTitle("My API-keys")
        .transparentList()
        .toolbarBackground(.visible, for: .tabBar)
        .animation(.default, value: vm.keys.count)
        .refreshableTask {
            vm.fetchKeys()
        }
        .sheet($sheetCreate) {
            CreateApikey()
        }
        .background {
            BackgroundImage()
        }
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissButton {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    sheetCreate = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.foreground)
                        .footnote(.bold)
                        .frame(width: 35, height: 35)
                        .background(.ultraThinMaterial, in: .circle)
                }
            }
        }
    }
    
    private func deleteItems(_ offsets: IndexSet) {
        for key in offsets {
            vm.delete(vm.keys[key].attributes.id)
        }
    }
}

#Preview {
    ApikeyList()
        .sheet {
            ApikeyList()
        }
        .environment(ApikeyVM())
        .environmentObject(ValueStore())
}
