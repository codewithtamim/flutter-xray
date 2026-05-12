import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_xray_method_channel.dart';

/// The interface that implementations of flutter_xray must implement.
abstract class FlutterXrayPlatform extends PlatformInterface {
  FlutterXrayPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterXrayPlatform _instance = MethodChannelFlutterXray();

  static FlutterXrayPlatform get instance => _instance;

  static set instance(FlutterXrayPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Set the TUN file descriptor. Call this BEFORE runXray/runXrayFromJSON.
  Future<void> setTunFd(int fd);

  /// Run Xray from a config file path.
  Future<String> runXray(String base64Request);

  /// Run Xray from a JSON config string.
  Future<String> runXrayFromJSON(String base64Request);

  /// Stop the running Xray instance.
  Future<String> stopXray();

  /// Get whether Xray is currently running.
  Future<bool> getXrayState();

  /// Get Xray-core version.
  Future<String> xrayVersion();

  /// Test/validate an Xray config file.
  Future<String> testXray(String base64Request);

  /// Ping an Xray config and get delay.
  Future<String> ping(String base64Request);

  /// Query inbound/outbound stats.
  Future<String> queryStats(String server);

  /// Count geo data.
  Future<String> countGeoData(String base64Request);

  /// Read geo files used by an Xray config.
  Future<String> readGeoFiles(String base64XrayConfig);

  /// Build MPH cache.
  Future<String> buildMphCache(String base64Request);

  /// Get free ports.
  Future<String> getFreePorts(int count);

  /// Convert share links to Xray JSON.
  Future<String> convertShareLinksToXrayJson(String base64Links);

  /// Convert Xray JSON to share links.
  Future<String> convertXrayJsonToShareLinks(String base64XrayJson);

  /// Init DNS (non-Android).
  Future<String> initDns(String base64Request);

  /// Reset DNS (non-Android).
  Future<String> resetDns();

  /// Register dialer controller (Android only).
  Future<void> registerDialerController();

  /// Register listener controller (Android only).
  Future<void> registerListenerController();

  /// Init Android DNS with server (Android only).
  Future<void> initAndroidDns(String server);

  /// Reset Android DNS (Android only).
  Future<void> resetAndroidDns();
}
