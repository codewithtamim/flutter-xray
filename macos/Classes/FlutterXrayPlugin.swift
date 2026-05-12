import Cocoa
import FlutterMacOS
import LibXray

public class FlutterXrayPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_xray", binaryMessenger: registrar.messenger)
    let instance = FlutterXrayPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setTunFd":
      if let args = call.arguments as? [String: Any], let fd = args["fd"] as? Int32 {
        LibXraySetTunFd(fd)
      }
      result(nil)

    case "runXray":
      let base64Request = (call.arguments as? [String: Any])?["base64Request"] as? String ?? ""
      result(LibXrayRunXray(base64Request))

    case "runXrayFromJSON":
      let base64Request = (call.arguments as? [String: Any])?["base64Request"] as? String ?? ""
      result(LibXrayRunXrayFromJSON(base64Request))

    case "stopXray":
      result(LibXrayStopXray())

    case "getXrayState":
      result(LibXrayGetXrayState())

    case "xrayVersion":
      result(LibXrayXrayVersion())

    case "testXray":
      let base64Request = (call.arguments as? [String: Any])?["base64Request"] as? String ?? ""
      result(LibXrayTestXray(base64Request))

    case "ping":
      let base64Request = (call.arguments as? [String: Any])?["base64Request"] as? String ?? ""
      result(LibXrayPing(base64Request))

    case "queryStats":
      let server = (call.arguments as? [String: Any])?["server"] as? String ?? ""
      result(LibXrayQueryStats(server))

    case "countGeoData":
      let base64Request = (call.arguments as? [String: Any])?["base64Request"] as? String ?? ""
      result(LibXrayCountGeoData(base64Request))

    case "readGeoFiles":
      let base64XrayConfig = (call.arguments as? [String: Any])?["base64XrayConfig"] as? String ?? ""
      result(LibXrayReadGeoFiles(base64XrayConfig))

    case "buildMphCache":
      let base64Request = (call.arguments as? [String: Any])?["base64Request"] as? String ?? ""
      result(LibXrayBuildMphCache(base64Request))

    case "getFreePorts":
      let count = (call.arguments as? [String: Any])?["count"] as? Int ?? 0
      result(LibXrayGetFreePorts(count))

    case "convertShareLinksToXrayJson":
      let base64Links = (call.arguments as? [String: Any])?["base64Links"] as? String ?? ""
      result(LibXrayConvertShareLinksToXrayJson(base64Links))

    case "convertXrayJsonToShareLinks":
      let base64XrayJson = (call.arguments as? [String: Any])?["base64XrayJson"] as? String ?? ""
      result(LibXrayConvertXrayJsonToShareLinks(base64XrayJson))

    case "initDns":
      let base64Request = (call.arguments as? [String: Any])?["base64Request"] as? String ?? ""
      result(LibXrayInitDns(base64Request))

    case "resetDns":
      result(LibXrayResetDns())

    case "registerDialerController",
         "registerListenerController",
         "initAndroidDns",
         "resetAndroidDns":
      result(FlutterMethodNotImplemented)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
