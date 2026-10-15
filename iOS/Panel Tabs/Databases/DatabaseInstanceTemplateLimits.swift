import ScrechKit
import Calagopus

struct DatabaseInstanceTemplateLimits: View {
    private let template: CalagopusDatabaseInstanceTemplate
    
    init(_ template: CalagopusDatabaseInstanceTemplate) {
        self.template = template
    }
    
    var body: some View {
        Text("CPU \(DatabaseInstanceLimit.cpu(template.cpu)) · Memory \(DatabaseInstanceLimit.megabytes(template.memory, countStyle: .memory)) · Disk \(DatabaseInstanceLimit.megabytes(template.disk))")
    }
}
