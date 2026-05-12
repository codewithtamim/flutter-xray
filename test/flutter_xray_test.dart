import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_xray/flutter_xray.dart';
import 'package:flutter_xray/flutter_xray_platform_interface.dart';
import 'package:flutter_xray/flutter_xray_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterXrayPlatform
    with MockPlatformInterfaceMixin
    implements FlutterXrayPlatform {
  @override
  Future<void> setTunFd(int fd) async {}

  @override
  Future<String> runXray(String base64Request) async => '';

  @override
  Future<String> runXrayFromJSON(String base64Request) async => '';

  @override
  Future<String> stopXray() async => '';

  @override
  Future<bool> getXrayState() async => false;

  @override
  Future<String> xrayVersion() async => 'v1.0.0';

  @override
  Future<String> testXray(String base64Request) async => '';

  @override
  Future<String> ping(String base64Request) async => '';

  @override
  Future<String> queryStats(String server) async => '';

  @override
  Future<String> countGeoData(String base64Request) async => '';

  @override
  Future<String> readGeoFiles(String base64XrayConfig) async => '';

  @override
  Future<String> buildMphCache(String base64Request) async => '';

  @override
  Future<String> getFreePorts(int count) async => '';

  @override
  Future<String> convertShareLinksToXrayJson(String base64Links) async => '';

  @override
  Future<String> convertXrayJsonToShareLinks(String base64XrayJson) async => '';

  @override
  Future<String> initDns(String base64Request) async => '';

  @override
  Future<String> resetDns() async => '';

  @override
  Future<void> registerDialerController() async {}

  @override
  Future<void> registerListenerController() async {}

  @override
  Future<void> initAndroidDns(String server) async {}

  @override
  Future<void> resetAndroidDns() async {}
}

void main() {
  final FlutterXrayPlatform initialPlatform = FlutterXrayPlatform.instance;

  test('$MethodChannelFlutterXray is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterXray>());
  });

  test('xrayVersion', () async {
    FlutterXray flutterXrayPlugin = FlutterXray();
    MockFlutterXrayPlatform fakePlatform = MockFlutterXrayPlatform();
    FlutterXrayPlatform.instance = fakePlatform;

    expect(await flutterXrayPlugin.xrayVersion(), 'v1.0.0');
  });
}
