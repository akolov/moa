import Foundation

final class MoaHttpImageDownloader: MoaImageDownloader {
  var task: URLSessionDataTask?
  var cancelled = false
  
  // When false - the cancel request will not be logged. It is used in order to avoid
  // loggin cancel requests after success or error has been received.
  var canLogCancel = true
  
  var logger: MoaLoggerCallback?
  
  
  init(logger: MoaLoggerCallback?) {
    self.logger = logger
  }
  
  deinit {
    cancel()
  }
  
  func startDownload(_ url: URL, onSuccess: @escaping (MoaImageResult) -> Void,
    onError: @escaping (Error?, HTTPURLResponse?) -> Void) {
      
    logger?(.requestSent, url, nil, nil, nil)
    
    cancelled = false
    canLogCancel = true
  
    task = MoaHttpImage.createDataTask(url,
      onSuccess: { [weak self] image in
        self?.canLogCancel = false
        self?.logger?(.responseSuccess, url, 200, nil, nil)
        onSuccess(image)
      },
      onError: { [weak self] error, response in
        self?.canLogCancel = false
        
        if let currentSelf = self , !currentSelf.cancelled {
          // Do not report error if task was manually cancelled
          self?.logger?(.responseError, url, response?.statusCode, error, nil)
          onError(error, response)
        }
      }
    )
      
    task?.resume()
  }
  
  func cancel() {
    if cancelled { return }
    cancelled = true
    
    task?.cancel()
    
    if canLogCancel {
      let url = task?.originalRequest?.url
      logger?(.requestCancelled, url, nil, nil, nil)
    }
  }
}
