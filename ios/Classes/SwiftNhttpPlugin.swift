import Flutter
import UIKit

public class SwiftNhttpPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "nhttp", binaryMessenger: registrar.messenger())
    let instance = SwiftNhttpPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "sendRequest":
        let arguments = (call.arguments as? [String : AnyObject])
        let url = arguments!["url"] as! String
        let method = arguments!["method"] as! String
        let headers = arguments!["headers"] as? Dictionary<String, String>
        let timeOut = arguments!["timeOut"] as? Int
        let body = arguments!["body"] as? String
        handleCall(url: url, method: method, headers: headers, timeOut: timeOut, body: body, result: result)
    default:
        result(FlutterError(code: "400", message: "call.method Not implemented", details: nil));
    }
  }

  func handleCall(url: String, method: String, headers: Dictionary<String, String>?, timeOut: Int?, body: String?, result: @escaping FlutterResult){
    let url = URL(string: url)!
    var request = URLRequest(url: url)
    request.httpMethod = method

    if(headers != nil){
        headers!.forEach {(key: String, value: String) in
            request.setValue(value, forHTTPHeaderField: key)
        }
    }

    if(body != nil){
        request.httpBody = body!.data(using: .utf8)
    }

    let sessionConfig = URLSessionConfiguration.default
    if(timeOut != nil){
        sessionConfig.timeoutIntervalForResource = Double(timeOut!) / 1000.0
    } else {
        sessionConfig.timeoutIntervalForResource = 60.0
    }

    let session = URLSession(configuration: sessionConfig)

    let task = session.dataTask(with: request) {(data, response, error) in
        if(error != nil){
            result(FlutterError (code:"400", message: error?.localizedDescription, details:nil))
            return
        }
        let responseBody = [UInt8](data!)
        let httpResponse = response as? HTTPURLResponse
        let responseCode = httpResponse?.statusCode

        var r : Dictionary = Dictionary<String, Any>()
        r["statusCode"] = responseCode;
        r["body"] = responseBody;
        result(r);
    }
    task.resume()
  }

}
