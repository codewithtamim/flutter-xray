import 'dart:convert';

import 'flutter_xray_platform_interface.dart';
import 'src/models.dart';

export 'src/models.dart';

/// A Flutter plugin for interacting with Xray-core via libXray.
///
/// This plugin exposes methods to start/stop Xray, test configs,
/// measure latency, convert share links, and manage TUN/DNS settings.
class FlutterXray {
  /// Set the TUN file descriptor. Must be called BEFORE [runXray]
  /// or [runXrayFromJSON].
  Future<void> setTunFd(int fd) => FlutterXrayPlatform.instance.setTunFd(fd);

  /// Run Xray using a config file path.
  Future<CallResponse<void>> runXray(RunXrayRequest request) async {
    final base64Request = encodeRunXrayRequest(request);
    final response = await FlutterXrayPlatform.instance.runXray(base64Request);
    return _parseVoidResponse(response);
  }

  /// Run Xray using an in-memory JSON config string.
  Future<CallResponse<void>> runXrayFromJSON(RunXrayFromJSONRequest request) async {
    final base64Request = encodeRunXrayFromJSONRequest(request);
    final response =
        await FlutterXrayPlatform.instance.runXrayFromJSON(base64Request);
    return _parseVoidResponse(response);
  }

  /// Stop the running Xray instance.
  Future<CallResponse<void>> stopXray() async {
    final response = await FlutterXrayPlatform.instance.stopXray();
    return _parseVoidResponse(response);
  }

  /// Get whether Xray is currently running.
  Future<bool> getXrayState() => FlutterXrayPlatform.instance.getXrayState();

  /// Get the Xray-core version string.
  Future<String> xrayVersion() => FlutterXrayPlatform.instance.xrayVersion();

  /// Test/validate an Xray config file.
  Future<CallResponse<void>> testXray(RunXrayRequest request) async {
    final base64Request = encodeRunXrayRequest(request);
    final response = await FlutterXrayPlatform.instance.testXray(base64Request);
    return _parseVoidResponse(response);
  }

  /// Ping an Xray config and return the delay in milliseconds.
  Future<CallResponse<int>> ping(PingRequest request) async {
    final base64Request = encodePingRequest(request);
    final response = await FlutterXrayPlatform.instance.ping(base64Request);
    return _parseResponse(
      response,
      (data) => data is int ? data : int.tryParse(data.toString()) ?? -1,
    );
  }

  /// Query inbound/outbound stats for the given server tag.
  Future<CallResponse<String>> queryStats(String server) async {
    final response =
        await FlutterXrayPlatform.instance.queryStats(server);
    return _parseResponse(response, (data) => data as String);
  }

  /// Count geo data categories and rules.
  Future<CallResponse<void>> countGeoData(CountGeoDataRequest request) async {
    final base64Request = encodeCountGeoDataRequest(request);
    final response =
        await FlutterXrayPlatform.instance.countGeoData(base64Request);
    return _parseVoidResponse(response);
  }

  /// Read geo files used by an Xray config.
  Future<CallResponse<ReadGeoFilesResponse>> readGeoFiles(
    String base64XrayConfig,
  ) async {
    final response =
        await FlutterXrayPlatform.instance.readGeoFiles(base64XrayConfig);
    return _parseResponse(
      response,
      (data) => ReadGeoFilesResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Build MPH cache.
  Future<CallResponse<void>> buildMphCache(RunXrayRequest request) async {
    final base64Request = encodeRunXrayRequest(request);
    final response =
        await FlutterXrayPlatform.instance.buildMphCache(base64Request);
    return _parseVoidResponse(response);
  }

  /// Get [count] free ports.
  Future<CallResponse<GetFreePortsResponse>> getFreePorts(int count) async {
    final response =
        await FlutterXrayPlatform.instance.getFreePorts(count);
    return _parseResponse(
      response,
      (data) => GetFreePortsResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Convert share links (v2rayN, Clash.Meta, etc.) to Xray JSON.
  Future<CallResponse<Map<String, dynamic>>> convertShareLinksToXrayJson(
    String links,
  ) async {
    final base64Links = base64Encode(utf8.encode(links));
    final response = await FlutterXrayPlatform.instance
        .convertShareLinksToXrayJson(base64Links);
    return _parseResponse(
      response,
      (data) => data as Map<String, dynamic>,
    );
  }

  /// Convert Xray JSON config to share links.
  Future<CallResponse<String>> convertXrayJsonToShareLinks(
    Map<String, dynamic> xrayJson,
  ) async {
    final base64XrayJson = base64Encode(utf8.encode(jsonEncode(xrayJson)));
    final response = await FlutterXrayPlatform.instance
        .convertXrayJsonToShareLinks(base64XrayJson);
    return _parseResponse(response, (data) => data as String);
  }

  /// Initialize DNS (non-Android platforms).
  Future<CallResponse<void>> initDns(InitDnsRequest request) async {
    final base64Request = encodeInitDnsRequest(request);
    final response = await FlutterXrayPlatform.instance.initDns(base64Request);
    return _parseVoidResponse(response);
  }

  /// Reset DNS (non-Android platforms).
  Future<CallResponse<void>> resetDns() async {
    final response = await FlutterXrayPlatform.instance.resetDns();
    return _parseVoidResponse(response);
  }

  /// Register dialer controller (Android only).
  Future<void> registerDialerController() =>
      FlutterXrayPlatform.instance.registerDialerController();

  /// Register listener controller (Android only).
  Future<void> registerListenerController() =>
      FlutterXrayPlatform.instance.registerListenerController();

  /// Initialize Android DNS with a server (Android only).
  Future<void> initAndroidDns(String server) =>
      FlutterXrayPlatform.instance.initAndroidDns(server);

  /// Reset Android DNS (Android only).
  Future<void> resetAndroidDns() =>
      FlutterXrayPlatform.instance.resetAndroidDns();

  // ----------------------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------------------

  CallResponse<void> _parseVoidResponse(String base64Response) {
    final decoded = utf8.decode(base64Decode(base64Response));
    final json = jsonDecode(decoded) as Map<String, dynamic>;
    return CallResponse<void>.fromJson(json, (_) {});
  }

  CallResponse<T> _parseResponse<T>(
    String base64Response,
    T Function(dynamic) parseData,
  ) {
    final decoded = utf8.decode(base64Decode(base64Response));
    final json = jsonDecode(decoded) as Map<String, dynamic>;
    return CallResponse<T>.fromJson(json, parseData);
  }
}
