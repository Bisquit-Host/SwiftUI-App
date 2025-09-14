import SwiftUI
import PteroNet

struct LogSection: View {
    private let logs = [
        LogAttributes(
            id: "1",
            event: "UserLogin",
            timestamp: "2025-09-14T10:15:00Z",
            properties: ["device": .string("iPhone"), "os": .string("iOS 18")],
            description: "User logged in successfully",
            ip: "192.168.0.1",
            isApi: false,
            relationships: .init(actor: .init(attributes: .init(
                username: "jdoe",
                email: "jdoe@example.com",
                image: "https://hips.hearstapps.com/hmg-prod/images/chief-executive-of-apple-tim-cook-gives-a-thumbs-up-during-news-photo-1736776641.pjpeg?crop=1.00xw:1.00xh;0,0&resize=640:*"
            )))
        ),
        LogAttributes(
            id: "2",
            event: "UserLogout",
            timestamp: "2025-09-14T11:00:00Z",
            properties: [:],
            description: "User logged out",
            ip: "192.168.0.1",
            isApi: false,
            relationships: .init(actor: .init(attributes: .init(
                username: "jdoe",
                email: "jdoe@example.com",
                image: "https://hips.hearstapps.com/hmg-prod/images/chief-executive-of-apple-tim-cook-gives-a-thumbs-up-during-news-photo-1736776641.pjpeg?crop=1.00xw:1.00xh;0,0&resize=640:*"
            )))
        ),
        LogAttributes(
            id: "3",
            event: "ApiRequest",
            timestamp: "2025-09-14T11:30:00Z",
            properties: ["endpoint": .string("/v1/items"), "statusCode": .int(200)],
            description: "Fetched items list",
            ip: "203.0.113.42",
            isApi: true,
            relationships: .init(actor: .init(attributes: .init(
                username: "service-bot",
                email: "bot@example.com",
                image: "https://hips.hearstapps.com/hmg-prod/images/chief-executive-of-apple-tim-cook-gives-a-thumbs-up-during-news-photo-1736776641.pjpeg?crop=1.00xw:1.00xh;0,0&resize=640:*"
            )))
        ),
        LogAttributes(
            id: "4",
            event: "FileUpload",
            timestamp: "2025-09-14T12:00:00Z",
            properties: ["filename": .string("report.pdf"), "size": .int(1048576)],
            description: "User uploaded a report",
            ip: "198.51.100.23",
            isApi: false,
            relationships: .init(actor: .init(attributes: .init(
                username: "asmith",
                email: "asmith@example.com",
                image: "https://hips.hearstapps.com/hmg-prod/images/chief-executive-of-apple-tim-cook-gives-a-thumbs-up-during-news-photo-1736776641.pjpeg?crop=1.00xw:1.00xh;0,0&resize=640:*"
            )))
        ),
        LogAttributes(
            id: "5",
            event: "PasswordChange",
            timestamp: "2025-09-14T12:30:00Z",
            properties: [:],
            description: "User changed password",
            ip: "192.0.2.15",
            isApi: false,
            relationships: .init(actor: .init(attributes: .init(
                username: "mcarter",
                email: "mcarter@example.com",
                image: "https://hips.hearstapps.com/hmg-prod/images/chief-executive-of-apple-tim-cook-gives-a-thumbs-up-during-news-photo-1736776641.pjpeg?crop=1.00xw:1.00xh;0,0&resize=640:*"
            )))
        )
    ]
    
    var body: some View {
        Card("Logs") {
            VStack(alignment: .leading) {
                HStack {
                    HeaderCell("Actor")
                        .frame(width: 32, alignment: .leading)
                    
                    HeaderCell("Description")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HeaderCell("Date")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 6)
                
                ForEach(logs) { log in
                    VStack(spacing: 6) {
                        HStack {
                            LogActorAvatar(log.relationships.actor.attributes)
                                .frame(width: 32, alignment: .leading)
                                .clipped()
                            
                            Text(log.event)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(log.timestamp)
                                .secondary()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        if log.id != logs.last?.id {
                            Divider()
                        }
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }
}

#Preview {
    LogSection()
}
