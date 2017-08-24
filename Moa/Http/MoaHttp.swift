import Foundation

/**

Shortcut function for creating URLSessionDataTask.

*/
struct MoaHttp {

  static func createDataTask(url: URL,
    onSuccess: @escaping (Data?, HTTPURLResponse)->(),
    onError: @escaping (Error?, HTTPURLResponse?)->()) -> URLSessionDataTask? {
      
    return MoaHttpSession.session?.dataTask(with: url) { (data, response, error) in
      if let httpResponse = response as? HTTPURLResponse {
        if error == nil {
          onSuccess(data, httpResponse)
        } else {
          onError(error, httpResponse)
        }
      } else {
        onError(error, nil)
      }
    }
  }

}
