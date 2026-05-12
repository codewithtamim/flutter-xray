import 'dart:convert';

/// Response wrapper used by libXray Go functions.
class CallResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  CallResponse({required this.success, this.data, this.error});

  factory CallResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) parseData,
  ) {
    return CallResponse(
      success: json['success'] as bool? ?? false,
      data: json.containsKey('data') ? parseData(json['data']) : null,
      error: json['error'] as String?,
    );
  }

  @override
  String toString() =>
      'CallResponse(success: $success, data: $data, error: $error)';
}

/// Request to run Xray from a config file.
class RunXrayRequest {
  final String datDir;
  final String? mphCachePath;
  final String configPath;

  RunXrayRequest({
    required this.datDir,
    this.mphCachePath,
    required this.configPath,
  });

  Map<String, dynamic> toJson() => {
        'datDir': datDir,
        if (mphCachePath != null) 'mphCachePath': mphCachePath,
        'configPath': configPath,
      };
}

/// Request to run Xray from a JSON string.
class RunXrayFromJSONRequest {
  final String datDir;
  final String? mphCachePath;
  final String configJSON;

  RunXrayFromJSONRequest({
    required this.datDir,
    this.mphCachePath,
    required this.configJSON,
  });

  Map<String, dynamic> toJson() => {
        'datDir': datDir,
        if (mphCachePath != null) 'mphCachePath': mphCachePath,
        'configJSON': configJSON,
      };
}

/// Request to ping an Xray config.
class PingRequest {
  final String datDir;
  final String configPath;
  final int timeout;
  final String url;
  final String? proxy;

  PingRequest({
    required this.datDir,
    required this.configPath,
    this.timeout = 3000,
    this.url = 'https://www.google.com',
    this.proxy,
  });

  Map<String, dynamic> toJson() => {
        'datDir': datDir,
        'configPath': configPath,
        'timeout': timeout,
        'url': url,
        if (proxy != null) 'proxy': proxy,
      };
}

/// Request to initialize DNS (non-Android).
class InitDnsRequest {
  final String dns;
  final String deviceName;

  InitDnsRequest({required this.dns, required this.deviceName});

  Map<String, dynamic> toJson() => {
        'dns': dns,
        'deviceName': deviceName,
      };
}

/// Request to count geo data.
class CountGeoDataRequest {
  final String datDir;
  final String name;
  final String geoType;

  CountGeoDataRequest({
    required this.datDir,
    required this.name,
    required this.geoType,
  });

  Map<String, dynamic> toJson() => {
        'datDir': datDir,
        'name': name,
        'geoType': geoType,
      };
}

/// Response from readGeoFiles.
class ReadGeoFilesResponse {
  final List<String> domain;
  final List<String> ip;

  ReadGeoFilesResponse({required this.domain, required this.ip});

  factory ReadGeoFilesResponse.fromJson(Map<String, dynamic> json) {
    return ReadGeoFilesResponse(
      domain: (json['domain'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      ip: (json['ip'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
    );
  }
}

/// Response from getFreePorts.
class GetFreePortsResponse {
  final List<int> ports;

  GetFreePortsResponse({required this.ports});

  factory GetFreePortsResponse.fromJson(Map<String, dynamic> json) {
    return GetFreePortsResponse(
      ports:
          (json['ports'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              [],
    );
  }
}

String _encodeRequest(Map<String, dynamic> request) {
  final jsonBytes = utf8.encode(jsonEncode(request));
  return base64Encode(jsonBytes);
}

String encodeRunXrayRequest(RunXrayRequest request) =>
    _encodeRequest(request.toJson());

String encodeRunXrayFromJSONRequest(RunXrayFromJSONRequest request) =>
    _encodeRequest(request.toJson());

String encodePingRequest(PingRequest request) =>
    _encodeRequest(request.toJson());

String encodeInitDnsRequest(InitDnsRequest request) =>
    _encodeRequest(request.toJson());

String encodeCountGeoDataRequest(CountGeoDataRequest request) =>
    _encodeRequest(request.toJson());
