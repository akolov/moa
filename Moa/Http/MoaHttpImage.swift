
import Foundation

/**

Helper functions for downloading an image and processing the response.

*/
struct MoaHttpImage {

  static func createDataTask(_ url: URL,
    onSuccess: @escaping (MoaImage)->(),
    onError: @escaping (Error?, HTTPURLResponse?)->()) -> URLSessionDataTask? {

    let cachedRequest = URLRequest(url: url)
    let cachedResponse = MoaHttpSession.cache?.cachedResponse(for: cachedRequest)?.response as? HTTPURLResponse
    let cachedEtag = cachedResponse?.allHeaderFields["Etag"] as? String
    let cachedLastModified = cachedResponse?.allHeaderFields["Last-Modified"] as? String

    return MoaHttp.createDataTask(
      url: url,
      onSuccess: { data, response in
        let etag = response.allHeaderFields["Etag"] as? String
        let lastModified = response.allHeaderFields["Last-Modified"] as? String
        let isCached = etag == cachedEtag && lastModified == cachedLastModified
        self.handleSuccess(data, cached: isCached, response: response, onSuccess: onSuccess, onError: onError)
      },
      onError: onError
    )
  }
  
  static func handleSuccess(
    _ data: Data?,
    cached: Bool,
    response: HTTPURLResponse,
    onSuccess: (MoaImage) -> Void,
    onError: (Error, HTTPURLResponse?) -> Void
  ) {
    guard response.statusCode == 200 else {
      onError(MoaError.httpStatusCodeIsNot200, response)
      return
    }

    if cached, let url = response.url, let image = inflatedImagesCache.object(forKey: url as NSURL) {
      Moa.logger?(.responseCached, url, nil, nil, image.moa_inflated ? "inflated" : "non-inflated")
      onSuccess(image)
      return
    }
    
    // Ensure response has the valid MIME type
    if let mimeType = response.mimeType {
      if !validMimeType(mimeType) {
        // Not an image Content-Type http header
        let error = MoaError.notAnImageContentTypeInResponseHttpHeader
        onError(error, response)
        return
      }
    } else {
      // Missing Content-Type http header
      let error = MoaError.missingResponseContentTypeHttpHeader
      onError(error, response)
      return
    }
      
    if let data = data, let image = MoaImage(data: data) {
      if let url = response.url {
        image.moa_inflate()
        let totalBytes = byteSize(of: image)
        inflatedImagesCache.setObject(image, forKey: url as NSURL, cost: Int(totalBytes))
      }

      onSuccess(image)
    }
    else {
      // Failed to convert response data to UIImage
      let error = MoaError.failedToReadImageData
      onError(error, response)
    }
  }

  static func cachedImage(url: URL) -> UIImage? {
    guard let image = inflatedImagesCache.object(forKey: url as NSURL) else {
      return nil
    }

    Moa.logger?(.responseCached, url, nil, nil, image.moa_inflated ? "inflated" : "non-inflated")
    return image
  }

  private static func byteSize(of image: MoaImage) -> UInt64 {
    #if os(iOS) || os(tvOS) || os(watchOS)
      let size = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
    #elseif os(macOS)
      let size = CGSize(width: image.size.width, height: image.size.height)
    #endif

    let bytesPerPixel: CGFloat = 4.0
    let bytesPerRow = size.width * bytesPerPixel
    let totalBytes = UInt64(bytesPerRow) * UInt64(size.height)

    return totalBytes
  }

  private static func validMimeType(_ mimeType: String) -> Bool {
    let validMimeTypes = ["image/jpeg", "image/jpg", "image/pjpeg", "image/png", "image/gif"]
    return validMimeTypes.contains(mimeType)
  }

  static var inflatedImagesCache: NSCache<NSURL, UIImage> = {
    let cache = NSCache<NSURL, MoaImage>()
    cache.totalCostLimit = Moa.settings.cache.memoryCapacityBytes
    return cache
  }()

  static let inflationQueue = DispatchQueue(
    label: "com.moa.image-inflation-queue",
    qos: .background,
    attributes: .concurrent,
    autoreleaseFrequency: .workItem,
    target: nil
  )

}
