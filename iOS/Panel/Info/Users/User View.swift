import ScrechKit
import Kingfisher
import PteroNet

struct UserView: View {
    @Environment(UsersVM.self) private var vm
    
    private let user: UserListAttributes
    
    init(_ user: UserListAttributes) {
        self.user = user
    }
    
    @State private var showDescription = false
    
    private var permissionCount: Int {
        var count = 0
        
        if let permissions = vm.permissions {
            for (_, permission) in permissions.attributes.permissions {
                count += permission.keys.count
            }
        }
        
        return count
    }
    
    private var permissionCountColor: Color {
        let userPermissions = user.permissions.count
        
        if userPermissions == 0 {
            return .red
            
        } else if userPermissions < permissionCount {
            return .yellow
        }
        
        return .green
    }
    
    private var userPermissionsDict: [String: Bool] {
        var dict: [String: Bool] = [:]
        
        if let permissions = vm.permissions {
            permissions.attributes.permissions.forEach { (key, permission) in
                permission.keys.keys.forEach { subKey in
                    let fullKey = "\(key).\(subKey)"
                    dict[fullKey] = user.permissions.contains(fullKey)
                }
            }
        }
        
        return dict
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Spacer()
                        
                        KFImage(stringToUrl(user.image))
                            .resizable()
                            .frame(width: 160, height: 160)
                            .clipShape(.circle)
                        
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
#if os(watchOS)
                Text(user.email)
#else
                UserEmail(user.email)
#endif
                HStack {
                    Text("2FA")
                    
                    Spacer()
                    
                    if user.twoFaEnabled {
                        Text("Enabled \(Image(systemName: "lock.fill"))")
                            .foregroundStyle(.green)
                    } else {
                        Text("Disabled")
                            .foregroundStyle(.red)
                    }
                }
                
                HStack {
                    Text("Member since")
                    
                    Spacer()
                    
                    VStack {
                        Text(formatISO(user.createdAt))
                        
                        Text(timeSinceISO(user.createdAt))
                            .footnote()
                            .foregroundStyle(.secondary)
                    }
                }
#if os(watchOS)
                HStack {
                    KFImage(stringToUrl(user.image))
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(.rect(cornerRadius: 12))
                    
                    Text(user.username)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(user.twoFaEnabled ? .green : .red)
                }
                
                Text(user.email)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
#endif
                if let permissions = vm.permissions {
                    Section {
                        HStack {
                            Text("Permissions")
                            
                            Spacer()
                            
                            Text("\(user.permissions.count) of \(permissionCount)")
                                .foregroundStyle(permissionCountColor)
                        }
                        Toggle("Show description (ru)", isOn: $showDescription)
                    }
                    
                    ForEach(permissions.attributes.permissions.keys.sorted(), id: \.self) { key in
                        if let permission = permissions.attributes.permissions[key] {
                            Section {
                                ForEach(permission.keys.keys.sorted(), id: \.self) { subKey in
                                    if let subValue = permission.keys[subKey] {
                                        
                                        let perm = userPermissionsDict["\(key).\(subKey)"]
                                        
                                        VStack(alignment: .leading) {
                                            Toggle(isOn: .constant(perm ?? false)) {
                                                Text(subKey)
                                            }
                                            .disabled(true)
                                            
                                            if showDescription {
                                                Text(subValue)
                                                    .caption2()
                                            }
                                        }
                                    }
                                }
                            } header: {
                                Text(key)
                            } footer: {
                                if showDescription {
                                    Text(permission.description)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(user.username)
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.never)
        }
    }
    
    func removePrefix(_ string: String) -> String {
        let components = string.split(separator: ".")
        
        guard components.count > 1 else {
            return string
        }
        
        return components[1...].joined(separator: ".")
    }
}

#Preview {
    Text("Preview")
        .sheet(.constant(true)) {
            UserView(
                sampleJSON(.userAttributes)
            )
        }
        .environment(UsersVM(""))
}
