//
//  AudioDownloadDelegate.swift
//  MusicPlayer
//
//  Created by Daniyar Yeralin on 6/19/19.
//  Copyright © 2019 Daniyar Yeralin. All rights reserved.
//

import Foundation
import AVFoundation

class AudioDownloadDelegate: NSObject, AVAssetResourceLoaderDelegate, URLSessionDataDelegate {
    
    private let notificationCenter: NotificationCenter = .default

    internal var session: URLSession?
    internal var response: URLResponse?
    private var mediaData: Data?
    private var loadingRequests = [AVAssetResourceLoadingRequest]()
    
    weak var owner: RemotePlayerItem?
    
    func startDataTaskWithoutPlayback() {
        guard let url = owner?.url else {
            fatalError("Could not locate remote item URL")
        }
        session = createBackgroundDataURLSession(url)
        session?.dataTask(with: url).resume()
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        log.info(loadingRequest)
        if session == nil {
            // If we're playing from a url, we need to download the file.
            // We start loading the file on first request only.
            guard let url = owner?.url else {
                fatalError("Could not locate remote item URL")
            }
            session = createBackgroundDataURLSession(url)
            session?.dataTask(with: url).resume()
        }
        loadingRequests.append(loadingRequest)
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        if let index = loadingRequests.firstIndex(of: loadingRequest) {
            loadingRequests.remove(at: index)
            log.debug("Closed loading request: \(loadingRequest)")
        } else {
            log.warning("Could not locate loading request: \(loadingRequest)")
        }
    }

    
    private func createBackgroundDataURLSession(_ url: URL) -> URLSession? {
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
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        return session
    }

    // MARK: URLSession delegate

    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        mediaData = Data()
        if let response = response as? HTTPURLResponse {
            self.response = response
            owner?.httpResponse = response
            notificationCenter.post(name: .receivedHttpResponse, object: owner)
        }
        processLoadingRequest()
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        mediaData?.append(data)
        owner?.bytesTotal = Int(dataTask.countOfBytesExpectedToReceive)
        owner?.bytesDownloaded = mediaData?.count
        notificationCenter.post(name: .downloadProgress, object: owner)
        processLoadingRequest()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            owner?.error = error
            notificationCenter.post(name: .errored, object: owner)
            return
        }
        owner?.payload = mediaData
        notificationCenter.post(name: .downloadFinished, object: owner)
        invalidateURLSession()
    }

    // MARK: Utils
    
    func processLoadingRequest() {
        var completedRequests = Set<AVAssetResourceLoadingRequest>()
        for var request in loadingRequests {
            if request.contentInformationRequest != nil {
                fillContentInfoRequest(request: &request)
            }
            if let dataRequest = request.dataRequest, haveEnoughToFulfillRequest(dataRequest) {
                request.finishLoading()
                completedRequests.insert(request)
            }
        }
        loadingRequests = loadingRequests.filter { !completedRequests.contains($0) }
    }

    func fillContentInfoRequest(request: inout AVAssetResourceLoadingRequest) {
        
        guard let response = response else {
            log.error("Could not locate response for filling")
            return
        }
        
        request.contentInformationRequest?.contentType = response.mimeType
        request.contentInformationRequest?.contentLength = response.expectedContentLength
        request.contentInformationRequest?.isByteRangeAccessSupported = false
    }
    
    func haveEnoughToFulfillRequest(_ dataRequest: AVAssetResourceLoadingDataRequest) -> Bool {
        
        let requestedOffset = Int(dataRequest.requestedOffset)
        let requestedLength = dataRequest.requestedLength
        let currentOffset = Int(dataRequest.currentOffset)
        
        guard let mediaData = self.mediaData,
            mediaData.count > currentOffset else {
                // Don't have any data at all for this request.
                return false
        }
        
        let bytesToRespond = min(mediaData.count - currentOffset, requestedLength)
        let dataToRespond = mediaData.subdata(in: Range(uncheckedBounds: (currentOffset, currentOffset + bytesToRespond)))
        dataRequest.respond(with: dataToRespond)
        
        return mediaData.count >= requestedLength + requestedOffset
    }
    
    private func invalidateURLSession() {
        session?.invalidateAndCancel()
        session = nil
    }

    deinit {
        log.info("Deinit Session")
        invalidateURLSession()
    }

}
