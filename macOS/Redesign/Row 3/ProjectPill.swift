import SwiftUI

struct ProjectPill: View {
    var project: ProjectTag
    
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(project.color)
                .frame(width: 16, height: 12)
            
            Text(project.name)
                .subheadline()
        }
    }
}
