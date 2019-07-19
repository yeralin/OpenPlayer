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

    var session: URLSession?
    var mediaData: Data?
    var response: URLResponse?
    var loadingRequest: AVAssetResourceLoadingRequest?
    weak var owner: CachingPlayerItem?

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
        configuration.timeoutIntervalForRequest = 60.0
        configuration.timeoutIntervalForResource = 60.0
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

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        mediaData?.append(data)
        processLoadingRequest()
        owner?.delegate?.playerItem?(owner!, didDownloadBytesSoFar: mediaData!.count, outOf: Int(dataTask.countOfBytesExpectedToReceive))
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(Foundation.URLSession.ResponseDisposition.allow)
        mediaData = Data()
        self.response = response
        if let response = response as? HTTPURLResponse {
            owner?.delegate?.playerItem?(owner!, didReceiveResponse: response)
        }
        processLoadingRequest()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            owner?.delegate?.playerItem?(owner!, downloadingFailedWith: error)
            return
        }
        processLoadingRequest()
        owner?.delegate?.playerItem?(owner!, didFinishDownloadingData: mediaData!)
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
