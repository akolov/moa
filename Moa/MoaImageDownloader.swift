import Foundation

enum MoaImageResult {

  case downloaded(MoaImage)
  case cached(MoaImage)

}

/// Downloads an image.
protocol MoaImageDownloader {

  func startDownload(_ url: URL, onSuccess: @escaping (MoaImageResult) -> Void,
    onError: @escaping (Error?, HTTPURLResponse?) -> Void)
  
  func cancel()

}
