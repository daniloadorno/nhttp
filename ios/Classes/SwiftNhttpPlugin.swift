import Flutter
import UIKit

public class SwiftNhttpPlugin: NSObject, FlutterPlugin {

  var session = URLSession(configuration: URLSessionConfiguration.default)

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "nhttp", binaryMessenger: registrar.messenger())
    let instance = SwiftNhttpPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "nhttp/sendRequest":
        let arguments = (call.arguments as? [String : AnyObject])

        let url = arguments!["url"] as! String
        let method = arguments!["method"] as! String
        let headers = arguments!["headers"] as! Dictionary<String, String>
        let body = arguments!["body"] as! Dictionary<String, Any>
        handleCall(url:url, method:method,headers:headers, body:body, result:result)
    default:
        result("Not implemented");
    }
  }

  func handleCall(url: String, method: String, headers:Dictionary<String, String>, body:Dictionary<String, Any>, result:@escaping FlutterResult){
      switch method {
      case "GET":
          return getCall(url:url, headers:headers, body:body, result: result);
      default:
          return dataCall(url:url, method: method, headers: headers, body: body, result: result);
      }
  }

  func getCall(url: String, headers:Dictionary<String, String>, body:Dictionary<String, Any>, result: @escaping FlutterResult) {
      let url = URL(string: url)!
      var request = URLRequest(url: url)
      request.httpMethod = "GET"
      request.setValue("application/json", forHTTPHeaderField: "content-type")

      headers.forEach {(key: String, value: String) in
          request.setValue(value, forHTTPHeaderField: key)
      }

      let task = session.dataTask(with: request) {( data, response, error) in
          if(error != nil){
             result(FlutterError (code:"400", message:error?.localizedDescription, details:nil))
             return
          }
          let responseBodyStr = String(data: data!, encoding: .utf8)
          let responseBody = [UInt8](responseBodyStr!.utf8)
          let httpResponse = response as? HTTPURLResponse
          let responseCode = httpResponse?.statusCode

          var r :Dictionary = Dictionary<String, Any>()
          r["statusCode"]  = responseCode;
          r["body"]  = responseBody;
          result(r);
      }
      task.resume()
  }

  func dataCall(url: String, method: String, headers:Dictionary<String, String>, body:Dictionary<String, Any>, result: @escaping FlutterResult) {
      let url = URL(string: url)!
      var request = URLRequest(url: url)
      request.httpMethod = method
      request.setValue("application/json", forHTTPHeaderField: "content-type")

      headers.forEach {(key: String, value: String) in
          request.setValue(value, forHTTPHeaderField: key)
      }

      do {
       let jsonData = try JSONSerialization.data(withJSONObject:body, options: [])
       if  let jsonString = String(data: jsonData, encoding: .utf8) {
           guard let jsonData = jsonString.data(using: .utf8) else { return print("error.localizedDescription") }
           request.httpBody = jsonData
        }
      } catch {
           print(error.localizedDescription)
      }

      let sessionConfig = URLSessionConfiguration.default
          sessionConfig.timeoutIntervalForResource = 50.0
      let session = URLSession(configuration: sessionConfig)
      let task = session.dataTask(with: request) {( data, response, error) in
          if(error != nil){
              result(FlutterError (code:"400", message:error?.localizedDescription, details:nil))
              return
          }
          let responseBodyStr = String(data: data!, encoding: .utf8)
          let responseBody = [UInt8](responseBodyStr!.utf8)
          let responseCode = httpResponse?.statusCode

          var r :Dictionary = Dictionary<String, Any>()
          r["statusCode"]  = responseCode;
          r["body"]  = responseBody;
          result(r);
      }
      task.resume()
  }

}
