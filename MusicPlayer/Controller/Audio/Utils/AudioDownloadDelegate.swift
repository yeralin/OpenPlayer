//
//  AudioDownloadDelegate.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/19/19.
//  Copyright © 2019 Daniyar Yeralin. All rights reserved.
//

import Foundation
import AVFoundation

class AudioDownloadDelegate: NSObject, AVAssetResourceLoaderDelegate, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    private let notificationCenter: NotificationCenter = .default

    internal var session: URLSession?
    private var mediaData: Data?
    private var response: URLResponse?
    private var loadingRequest: AVAssetResourceLoadingRequest?
    
    weak var owner: RemotePlayerItem?

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if session == nil {
            // If we're playing from a url, we need to download the file.
            // We start loading the file on first request only.
            guard let initialUrl = owner?.url else {
                fatalError("internal inconsistency")
            }
            startDataRequest(with: initialUrl)
        }
        self.loadingRequest = loadingRequest
        processLoadingRequest()
        return true
    }
    
    func startDataRequest(with url: URL) {
        let configuration = URLSessionConfiguration.background(withIdentifier: url.absoluteString)
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.allowsCellularAccess = true
        configuration.shouldUseExtendedBackgroundIdleMode = true
        configuration.waitsForConnectivity = true
        /* The timeout interval to use when waiting for additional data.
           The timer associated with this value is reset whenever new data arrives.
           When the request timer reaches the specified interval
            without receiving any new data, it triggers a timeout.
         */
        configuration.timeoutIntervalForRequest = 30.0
        /* The maximum amount of time that a resource request should be allowed to take.
           This value controls how long to wait for an entire resource to transfer before giving up.
           The resource timer starts when the request is initiated and counts until
             either the request completes or this timeout interval is reached, whichever comes first.
        */
        configuration.timeoutIntervalForResource = Double.greatestFiniteMagnitude
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        session?.dataTask(with: url).resume()
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        log.warning("Closed loading request: \(loadingRequest)")
        if self.loadingRequest == loadingRequest {
            self.loadingRequest = nil
        }
    }

    // MARK: URLSession delegate

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(Foundation.URLSession.ResponseDisposition.allow)
        mediaData = Data()
        self.response = response
        if let response = response as? HTTPURLResponse {
            owner?.httpResponse = response
            notificationCenter.post(name: .receivedHttpResponse, object: owner)
        }
        processLoadingRequest()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        mediaData?.append(data)
        processLoadingRequest()
        owner?.bytesTotal = Int(dataTask.countOfBytesExpectedToReceive)
        owner?.bytesDownloaded = mediaData?.count
        notificationCenter.post(name: .downloadProgress, object: owner)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            owner?.error = error
            notificationCenter.post(name: .errored, object: owner)
            return
        }
        processLoadingRequest()
        owner?.payload = mediaData
        notificationCenter.post(name: .finishedDownload, object: owner)
    }

    // MARK: -
    func processLoadingRequest() {
        if let loadingRequest = loadingRequest,
           let dataRequest = loadingRequest.dataRequest {
            fillInContentInformationRequest(loadingRequest.contentInformationRequest)
            if haveEnoughDataToFulfillRequest(dataRequest) {
                loadingRequest.finishLoading()
                self.loadingRequest = nil
            }
        }
    }

    func fillInContentInformationRequest(_ contentInformationRequest: AVAssetResourceLoadingContentInformationRequest?) {
        
        guard let response = response else {
            // have no response from the server yet
            return
        }
        
        contentInformationRequest?.contentType = response.mimeType
        contentInformationRequest?.contentLength = response.expectedContentLength
        contentInformationRequest?.isByteRangeAccessSupported = false
        
    }
    
    func haveEnoughDataToFulfillRequest(_ dataRequest: AVAssetResourceLoadingDataRequest) -> Bool {
        
        let requestedOffset = Int(dataRequest.requestedOffset)
        let requestedLength = dataRequest.requestedLength
        let currentOffset = Int(dataRequest.currentOffset)
        
        guard let songDataUnwrapped = mediaData,
            songDataUnwrapped.count > currentOffset else {
                // Don't have any data at all for this request.
                return false
        }
        
        let bytesToRespond = min(songDataUnwrapped.count - currentOffset, requestedLength)
        let dataToRespond = songDataUnwrapped.subdata(in: Range(uncheckedBounds: (currentOffset, currentOffset + bytesToRespond)))
        dataRequest.respond(with: dataToRespond)
        
        return songDataUnwrapped.count >= requestedLength + requestedOffset
        
    }

    deinit {
        log.info("Deinit Session")
        session?.invalidateAndCancel()
    }

}
