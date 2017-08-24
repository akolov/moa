import Foundation

/**

A helper function that creates a human readable text from log arguments.

Usage:

    Moa.logger = { type, url, statusCode, error in

      let text = MoaLoggerText(type: type, url: url, statusCode: statusCode, error: error)
      // Log log text to your destination
    }

For logging into Xcode console you can use MoaConsoleLogger function.

    Moa.logger = MoaConsoleLogger

*/
public func MoaLoggerText(_ type: MoaLogType, url: URL?, statusCode: Int?, error: Error? = nil, comment: String?) -> String {
  
  let time = MoaTime.nowLogTime
  var text = "[moa] \(time) "
  var suffix = [String]()
  
  switch type {
  case .requestSent:
    text += "GET "
  case .requestCancelled:
    text += "Cancelled "
  case .responseSuccess:
    text += "Received "
  case .responseCached:
    text += "Cached "
  case .responseError:
    text += "Error "
    
    if let statusCode = statusCode {
      text += "\(statusCode) "
    }

    if let error = error {
      if let moaError = error as? MoaError {
        suffix.append(moaError.localizedDescription)
      } else {
        suffix.append(error.localizedDescription)
      }
    }
  }

  if let comment = comment {
    suffix.append(comment)
  }

  text += url.map { String(describing: $0) } ?? "-"
  
  if !suffix.isEmpty {
    text += " \(suffix.joined(separator: " "))"
  }
  
  return text
}
