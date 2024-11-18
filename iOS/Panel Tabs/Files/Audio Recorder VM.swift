import AVFoundation

@Observable
final class AudioRecorderVM {
    var audioRecorder: AVAudioRecorder!
    
    func startRecording() {
        let fm = FileManager.default
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.record, mode: .spokenAudio)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        
        let documentPath = fm.temporaryDirectory
        
        let filename = Date().toString(format: "yyyy-MM-dd HH:mm:ss") + ".m4a"
        let audioFilename = documentPath.appendingPathComponent(filename)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(
                url: audioFilename,
                settings: settings
            )
            
            audioRecorder.record()
        } catch {
            print("Could not start recording")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        audioRecorder = nil
    }
    
    func isRecording() -> Bool {
        audioRecorder != nil && audioRecorder.isRecording
    }
}

fileprivate extension Date {
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
}
