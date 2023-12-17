import ScrechKit

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(NavState.self) private var navState
    
    private let id, path: String
    
    init(_ id: String,
         path: String = ""
    ) {
        self.id = id
        self.path = path
    }
    
    var body: some View {
        List {
            ButtonNewFolder(path)
            
            Divider()
            
            ForEach(vm.filteredFiles, id: \.attributes.name) { attributes in
                let file = attributes.attributes
                let name = file.name
                let mimetype = file.mimetype
                
                NavigationLink {
                    if mimetype.contains("directory") {
                        FileTab(id,
                                path: path + "/\(name)"
                        )
                        .environmentObject(vm)
                        
                    } else if mimetype.contains("text") || mimetype.contains("json") {
                        Des_Text(id,
                                 path: path,
                                 name: name
                        )
                        
                    } else if mimetype.contains("image") {
                        Des_Image(id,
                                  path: path,
                                  name: name
                        )
                        
                    } else if mimetype.contains("video") {
                        DesVideo(id,
                                  path: path,
                                  name: name
                        )
                        
                    } else {
                        ContentUnavailableView("Warning",
                                               systemImage: "exclamationmark.triangle",
                                               description: Text("Unable to view the contents of \(name)")
                        )
                    }
                    
                    //                    navState.navigate(
                    //                        vm.navigateBasedOnMimeType(id,
                    //                                                   path: path,
                    //                                                   file: file)
                    //                    )
                } label: {
                    FileNameAndIcon(file)
                        .contextMenu {
                            if !mimetype.contains("directory") {
                                Section {
                                    Text("Modified: \(file.modifiedAt)")
                                    
                                    Text("Created: \(file.createdAt)")
                                }
                            }
                            
                            //                            MenuButton("Rename", icon: "pencil") {
                            //                                vm.newFileName = ""
                            //                                vm.alertRename = true
                            //                            }
                            
                            if !mimetype.contains("directory") {
                                MenuButton("Download with QR", icon: "qrcode") {
                                    // Context menu needs some time to close and allow the sheet to display
                                    delay(0.75) {
                                        vm.downloadFile(path + name)
                                    }
                                }
                                
                                MenuButton("Duplicate", icon: "doc.on.doc") {
                                    vm.duplicateFile(file.name, path: path)
                                }
                            }
                            
                            if mimetype.contains("gzip") {
                                MenuButton("Decompress", icon: "arrow.up.bin") {
                                    vm.fileCompressor(name,
                                                      path: path,
                                                      action: .decompress
                                    )
                                }
                            } else {
                                MenuButton("Compress", icon: "archivebox") {
                                    vm.fileCompressor(name,
                                                      path: path,
                                                      action: .compress
                                    )
                                }
                            }
                            
                            Section {
                                MenuButton("Delete", role: .destructive, icon: "trash") {
                                    vm.fileDelete(name, path: path)
                                }
                            }
                        }
                    //                        .alert("Rename", isPresented: $vm.alertRename) {
                    //                            TextField("", text: $vm.newFileName)
                    //
                    //                            Button("Rename", role: .destructive) {
                    //                                vm.renameFile(path,
                    //                                              oldName: name,
                    //                                              newName: vm.newFileName
                    //                                )
                    //
                    //                                vm.newFileName = ""
                    //                            }
                    //                        }
                }
            }
        }
        .environmentObject(vm)
        .navigationTitle(path)
        .sheet($vm.showSafari) {
            QRCodeView(vm.downloadUrl)
        }
        .task {
            vm.fetchFiles(path)
        }
    }
}

#Preview {
    FileTab("")
        .environment(NavState())
        .environmentObject(FileTabVM(""))
}
