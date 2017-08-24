import Foundation

/**

Logs image download requests, responses and errors to Xcode console for debugging.

Usage:

    Moa.logger = MoaConsoleLogger

*/
public func MoaConsoleLogger(_ type: MoaLogType, url: URL?, statusCode: Int?, error: Error?, comment: String?) {
  let text = MoaLoggerText(type, url: url, statusCode: statusCode, error: error, comment: comment)
  print(text)
}
