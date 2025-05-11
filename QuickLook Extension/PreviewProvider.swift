//import SwiftUI
//import Quartz
//
////@MainActor
////class PreviewProvider: QLPreviewProvider, QLPreviewingController {
////    func providePreview(
////        for request: QLFilePreviewRequest
////    ) async throws -> QLPreviewReply {
////        // Load the file data
////        let data = try Data(contentsOf: request.fileURL)
////        guard let text = String(data: data, encoding: .utf8) else {
////            throw NSError(domain: "YMLQuickLook", code: 1, userInfo: nil)
////        }
////
////        // Return a view-based reply
////        return QLPreviewReply(
////            view: PreviewView(text)
////        )
////    }
////}
////
//////struct PreviewView: View {
//////    private let text: String
//////
//////    init(_ text: String) {
//////        self.text = text
//////    }
//////
//////    var body: some View {
//////        ScrollView {
//////            Text(text)
//////                .font(.system(.body, design: .monospaced))
//////                .padding()
//////        }
//////    }
//////}
////
////struct PreviewView: View {
////    private let text: String
////
////    init(_ text: String) {
////        self.text = text
////    }
////
////    var body: some View {
////        ScrollView {
////            Text(text)
////                .font(.system(.body, design: .monospaced))
////                .padding()
////        }
////    }
////}
//
//class PreviewProvider: QLPreviewProvider, QLPreviewingController {
//    /*
//     Use a QLPreviewProvider to provide data-based previews
//     
//     To set up your extension as a data-based preview extension:
//     
//     - Modify the extension's Info.plist by setting
//     <key>QLIsDataBasedPreview</key>
//     <true/>
//     
//     - Add the supported content types to QLSupportedContentTypes array in the extension's Info.plist
//     
//     - Change the NSExtensionPrincipalClass to this class
//     e.g.
//     <key>NSExtensionPrincipalClass</key>
//     <string>$(PRODUCT_MODULE_NAME).PreviewProvider</string>
//     
//     - Implement providePreview(for:)
//     */
//    
//    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
//        //You can create a QLPreviewReply in several ways, depending on the format of the data you want to return
//        //To return Data of a supported content type:
//        
//        let contentType = UTType.plainText // replace with your data type
//        
//        let reply = QLPreviewReply.init(
//            dataOfContentType: contentType,
//            contentSize: CGSize.init(width: 800, height: 800)
//        ) { (replyToUpdate: QLPreviewReply) in
//            let data = Data("Hello world".utf8)
//            
//            //setting the stringEncoding for text and html data is optional and defaults to String.Encoding.utf8
//            replyToUpdate.stringEncoding = .utf8
//            
//            //initialize your data here
//            
//            return data
//        }
//        
//        return reply
//    }
//}
