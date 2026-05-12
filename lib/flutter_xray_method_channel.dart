import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_xray_platform_interface.dart';

/// An implementation of [FlutterXrayPlatform] that uses method channels.
class MethodChannelFlutterXray extends FlutterXrayPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_xray');

  @override
  Future<void> setTunFd(int fd) async {
    await methodChannel.invokeMethod<void>('setTunFd', {'fd': fd});
  }

  @override
  Future<String> runXray(String base64Request) async {
    final result = await methodChannel.invokeMethod<String>(
      'runXray',
      {'base64Request': base64Request},
    );
    return result ?? '';
  }

  @override
  Future<String> runXrayFromJSON(String base64Request) async {
    final result = await methodChannel.invokeMethod<String>(
      'runXrayFromJSON',
      {'base64Request': base64Request},
    );
    return result ?? '';
  }

  @override
  Future<String> stopXray() async {
    final result = await methodChannel.invokeMethod<String>('stopXray');
    return result ?? '';
  }

  @override
  Future<bool> getXrayState() async {
    final result = await methodChannel.invokeMethod<bool>('getXrayState');
    return result ?? false;
  }

  @override
  Future<String> xrayVersion() async {
    final result = await methodChannel.invokeMethod<String>('xrayVersion');
    return result ?? '';
  }

  @override
  Future<String> testXray(String base64Request) async {
    final result = await methodChannel.invokeMethod<String>(
      'testXray',
      {'base64Request': base64Request},
    );
    return result ?? '';
  }

  @override
  Future<String> ping(String base64Request) async {
    final result = await methodChannel.invokeMethod<String>(
      'ping',
      {'base64Request': base64Request},
    );
    return result ?? '';
  }

  @override
  Future<String> queryStats(String server) async {
    final result = await methodChannel.invokeMethod<String>(
      'queryStats',
      {'server': server},
    );
    return result ?? '';
  }

  @override
  Future<String> countGeoData(String base64Request) async {
    final result = await methodChannel.invokeMethod<String>(
      'countGeoData',
      {'base64Request': base64Request},
    );
    return result ?? '';
  }

  @override
  Future<String> readGeoFiles(String base64XrayConfig) async {
    final result = await methodChannel.invokeMethod<String>(
      'readGeoFiles',
      {'base64XrayConfig': base64XrayConfig},
    );
    return result ?? '';
  }

  @override
  Future<String> buildMphCache(String base64Request) async {
    final result = await methodChannel.invokeMethod<String>(
      'buildMphCache',
      {'base64Request': base64Request},
    );
    return result ?? '';
  }

  @override
  Future<String> getFreePorts(int count) async {
    final result = await methodChannel.invokeMethod<String>(
      'getFreePorts',
      {'count': count},
    );
    return result ?? '';
  }

  @override
  Future<String> convertShareLinksToXrayJson(String base64Links) async {
    final result = await methodChannel.invokeMethod<String>(
      'convertShareLinksToXrayJson',
      {'base64Links': base64Links},
    );
    return result ?? '';
  }

  @override
  Future<String> convertXrayJsonToShareLinks(String base64XrayJson) async {
    final result = await methodChannel.invokeMethod<String>(
      'convertXrayJsonToShareLinks',
      {'base64XrayJson': base64XrayJson},
    );
    return result ?? '';
  }

  @override
  Future<String> initDns(String base64Request) async {
    final result = await methodChannel.invokeMethod<String>(
      'initDns',
      {'base64Request': base64Request},
    );
    return result ?? '';
  }

  @override
  Future<String> resetDns() async {
    final result = await methodChannel.invokeMethod<String>('resetDns');
    return result ?? '';
  }

  @override
  Future<void> registerDialerController() async {
    await methodChannel.invokeMethod<void>('registerDialerController');
  }

  @override
  Future<void> registerListenerController() async {
    await methodChannel.invokeMethod<void>('registerListenerController');
  }

  @override
  Future<void> initAndroidDns(String server) async {
    await methodChannel.invokeMethod<void>(
      'initAndroidDns',
      {'server': server},
    );
  }

  @override
  Future<void> resetAndroidDns() async {
    await methodChannel.invokeMethod<void>('resetAndroidDns');
  }
}
