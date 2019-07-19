import Foundation
import AVFoundation

fileprivate extension URL {

    func withScheme(_ scheme: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        return components?.url
    }

}

@objc protocol CachingPlayerItemDelegate {

    @objc optional func playerItem(_ playerItem: CachingPlayerItem, didReceiveResponse response: HTTPURLResponse)

    /// Is called when the media file is fully downloaded.
    @objc optional func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data)

    /// Is called every time a new portion of data is received.
    @objc optional func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int)

    /// Is called after initial prebuffering is finished, means
    /// we are ready to play.
    @objc optional func playerItemReadyToPlay(_ playerItem: CachingPlayerItem)

    /// Is called when the data being downloaded did not arrive in time to
    /// continue playback.
    @objc optional func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem)

    /// Is called on downloading error.
    @objc optional func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error)

}

open class CachingPlayerItem: AVPlayerItem {

    internal let audioDownloadDelegate = AudioDownloadDelegate()
    internal let url: URL
    internal let initialScheme: String?
    internal var customFileExtension: String?
    internal var mutableDuration: CMTime = CMTimeMakeWithSeconds(0, preferredTimescale: 600)
    override open var duration: CMTime {
        get {
            return mutableDuration
        }
        set {
            self.mutableDuration = newValue
        }
    }

    weak var delegate: CachingPlayerItemDelegate?

    // Key-value observing context
    private var playerItemContext = 0

    open func downloadWithoutPlay() {
        if audioDownloadDelegate.session == nil {
            audioDownloadDelegate.startDataRequest(with: url)
        }
    }

    private let cachingPlayerItemScheme = "cachingPlayerItemScheme"

    /// Is used for playing remote files.
    convenience init(url: URL) {
        self.init(url: url, customFileExtension: nil)
    }

    /// Override/append custom file extension to URL path.
    /// This is required for the player to work correctly with the intended file type.
    init(url: URL, customFileExtension: String?) {

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme,
              var urlWithCustomScheme = url.withScheme(cachingPlayerItemScheme) else {
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
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        audioDownloadDelegate.owner = self

        addObserver(self,
                forKeyPath: "status",
                options: NSKeyValueObservingOptions.new,
                context: &playerItemContext)

        NotificationCenter.default.addObserver(self,
                selector: #selector(playbackStalledHandler),
                name:NSNotification.Name.AVPlayerItemPlaybackStalled,
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
                delegate?.playerItemReadyToPlay?(self)
            case .failed:
                delegate?.playerItem?(self, downloadingFailedWith: self.error?.localizedDescription ?? "unknown")
            case .unknown: break
            @unknown default: break
            }
        }
    }

    // MARK: Notification handlers

    @objc func playbackStalledHandler() {
        delegate?.playerItemPlaybackStalled?(self)
    }

    // MARK: -

    override init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
        fatalError("not implemented")
    }

    deinit {
        log.info("Deinit PlayerItem")
        NotificationCenter.default.removeObserver(self)
        removeObserver(self, forKeyPath: "status")
        audioDownloadDelegate.session?.invalidateAndCancel()
    }

}
