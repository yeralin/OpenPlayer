import Foundation
import AVFoundation

fileprivate extension URL {

    func withScheme(_ scheme: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        return components?.url
    }

}

extension Notification.Name {
    static var receivedHttpResponse: Notification.Name {
        return .init("AudioPlayer.receivedHttpResponse")
    }
    static var readyToPlay: Notification.Name {
        return .init("AudioPlayer.readyToPlay")
    }
    static var errored: Notification.Name {
        return .init("AudioPlayer.errored")
    }
    static var stalled: Notification.Name {
        return .init("AudioPlayer.stalled")
    }
    static var downloadProgress: Notification.Name {
        return .init("AudioPlayer.downloadProgress")
    }
    static var downloadFinished: Notification.Name {
        return .init("AudioPlayer.finishedDownload")
    }
}

open class RemotePlayerItem: PlayerItem {

    private let notificationCenter: NotificationCenter = .default
    internal let audioDownloadDelegate = AudioDownloadDelegate()
    
    internal let url: URL
    internal let initialScheme: String?
    internal var customFileExtension: String? = "mp3"
    
    internal var payload: Data?
    internal var bytesTotal: Int?
    internal var bytesDownloaded: Int?
    internal var httpResponse: HTTPURLResponse?
    
    internal var mutableDuration: CMTime = CMTimeMakeWithSeconds(0, preferredTimescale: 600)
    override open var duration: CMTime {
        get {
            return mutableDuration
        }
        set {
            self.mutableDuration = newValue
        }
    }
    
    internal var mutableError: Error?
    override open var error: Error? {
        get {
            return mutableError
        }
        set {
            self.mutableError = newValue
        }
    }

    // Key-value observing context
    private var playerItemContext = 0
    
    open func downloadWithoutPlay() {
        if audioDownloadDelegate.session == nil {
            audioDownloadDelegate.owner = self
            audioDownloadDelegate.startDataTaskWithoutPlayback()
        }
    }

    // Dirty hack to satisfy AVURLAsset
    private let fakeScheme = "fakeScheme"
    
    // Override/append custom file extension to URL path.
    // This is required for the player to work correctly with the intended file type.
    override init(song: SongEntity) {
        guard let url = song.songUrl,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let scheme = components.scheme,
            var urlWithCustomScheme = url.withScheme(fakeScheme) else {
                fatalError("Urls without a scheme are not supported")
        }
        
        self.url = url
        self.initialScheme = scheme
        
        if let ext = customFileExtension {
            urlWithCustomScheme.deletePathExtension()
            urlWithCustomScheme.appendPathExtension(ext)
            self.customFileExtension = ext
        }
        
        let asset = AVURLAsset(url: urlWithCustomScheme)
        asset.resourceLoader.setDelegate(audioDownloadDelegate, queue: DispatchQueue.global(qos: .userInitiated))
        super.init(song: song, asset: asset, automaticallyLoadedAssetKeys: nil )
        bufferValue = 0
        audioDownloadDelegate.owner = self
        
        addObserver(self,
                    forKeyPath: "status",
                    options: .new,
                    context: &playerItemContext)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playbackStalledHandler),
                                               name: .AVPlayerItemPlaybackStalled,
                                               object: self)
    }
    
    // MARK: KVO

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                    of: object,
                    change: change,
                    context: context)
            return
        }
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            switch status {
            case .readyToPlay:
                notificationCenter.post(name: .readyToPlay, object: self)
            case .failed:
                notificationCenter.post(name: .errored, object: self)
            case .unknown: fallthrough
            @unknown default:
                log.warning("Received unknown status")
            }
        }
    }

    // MARK: Notification handlers

    @objc func playbackStalledHandler() {
        notificationCenter.post(name: .stalled, object: self)
    }

    // MARK: -

    deinit {
        log.info("Deinit PlayerItem")
        NotificationCenter.default.removeObserver(self)
        removeObserver(self, forKeyPath: "status")
        audioDownloadDelegate.session?.invalidateAndCancel()
    }

}
