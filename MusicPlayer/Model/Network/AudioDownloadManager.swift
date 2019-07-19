//
// Created by Daniyar Yeralin on 2019-06-19.
// Copyright (c) 2019 Daniyar Yeralin. All rights reserved.
//

import Foundation
import MediaPlayer

class AudioDownloadManager: NSObject, URLSessionDataDelegate {

    var tempFile: URL? = URL(fileURLWithPath: NSTemporaryDirectory())
    var totalWritten: Int = 0
    static var shared = AudioDownloadManager()
    var playing: Bool = false
    var player: AVPlayer?

    private var session: URLSession {
        get {
            guard let bundleId = Bundle.main.bundleIdentifier else {
                fatalError("Could not get bundle identifier")
            }
            let config = URLSessionConfiguration.background(withIdentifier: "\(bundleId)")
            return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        }
    }
    
    func createDataTask(url: URL, name: String) {
        tempFile?.appendPathComponent(name + ".mp3")
        let dataTask = self.session.dataTask(with: URL(string: "http://localhost:8000/youtube/stream?videoId=BanzDujUwF4")!)
        dataTask.resume()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse)
            completionHandler(URLSession.ResponseDisposition.allow)
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        do {
            if let tempFile = tempFile {
                try data.write(to: tempFile)
                totalWritten += data.count
                if totalWritten > 100000 && !playing {
                    player = AVPlayer(url: tempFile)
                    player?.play()
                    playing = true
                }
            }
        } catch let error {
            log.error("Could not write to tempFile \(tempFile?.absoluteString ?? ""): \(error)")
        }
        print("Received: \(session)")
    }
}
