import Testing

struct VersionChangerBuildVersionFormatterTests {
    @Test func `keeps different build name`() {
        let build = VersionChangerBuild(
            id: "paper-34",
            type: "PAPER",
            projectVersionId: "26.2",
            versionId: "26.2",
            name: "#34",
            experimental: false,
            created: nil
        )
        
        #expect(VersionChangerBuildVersionFormatter.displayVersion(for: build) == "Version 26.2 #34")
        #expect(VersionChangerBuildVersionFormatter.installedVersion(for: build) == "26.2")
        #expect(VersionChangerBuildVersionFormatter.installedBuild(for: build) == "#34")
    }
    
    @Test func `keeps minecraft version when build name duplicates project version`() {
        let build = VersionChangerBuild(
            id: "fabric-0.19.3",
            type: "FABRIC",
            projectVersionId: "0.19.3",
            versionId: "26.2",
            name: "0.19.3",
            experimental: false,
            created: nil
        )
        
        #expect(VersionChangerBuildVersionFormatter.displayVersion(for: build) == "Version 26.2 0.19.3")
        #expect(VersionChangerBuildVersionFormatter.installedVersion(for: build) == "26.2")
        #expect(VersionChangerBuildVersionFormatter.installedBuild(for: build) == "0.19.3")
    }
    
    @Test func `keeps minecraft version when build name duplicates beta project version`() {
        let build = VersionChangerBuild(
            id: "neoforge-26.2.0.0-beta",
            type: "NEOFORGE",
            projectVersionId: "26.2.0.0-beta",
            versionId: "26.2",
            name: "26.2.0.0-beta",
            experimental: false,
            created: nil
        )
        
        #expect(VersionChangerBuildVersionFormatter.displayVersion(for: build) == "Version 26.2 26.2.0.0-beta")
        #expect(VersionChangerBuildVersionFormatter.installedVersion(for: build) == "26.2")
        #expect(VersionChangerBuildVersionFormatter.installedBuild(for: build) == "26.2.0.0-beta")
    }
    
    @Test func `uses version id fallback`() {
        let build = VersionChangerBuild(
            id: "vanilla-1",
            type: "VANILLA",
            projectVersionId: nil,
            versionId: "26.2",
            name: "#1",
            experimental: false,
            created: nil
        )
        
        #expect(VersionChangerBuildVersionFormatter.displayVersion(for: build) == "Version 26.2 #1")
    }
}
