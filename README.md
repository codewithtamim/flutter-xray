# flutter_xray

A Flutter plugin that wraps [libXray](https://github.com/XTLS/libXray) so you can start, stop, and control Xray-core from your Flutter app. It works on Android, iOS, and macOS.

This plugin does not include any VPN or TUN device logic. It only exposes the Xray engine APIs. If you want to route traffic through a TUN interface, you need to set up the TUN fd yourself and pass it to the plugin.

## What is inside

- Android: uses the libXray AAR built with gomobile
- iOS / macOS: uses the LibXray.xcframework built with gomobile
- Dart API: hides all the base64 encoding and gives you plain typed methods

## Requirements

- Flutter 3.3.0 or newer
- Dart 3.11.1 or newer
- Android minSdk 24
- iOS 15.0 or newer
- macOS 11.0 or newer

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_xray: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### Android

No extra setup is needed. The AAR is bundled automatically.

### iOS / macOS

No extra setup is needed. The xcframework is bundled automatically. CocoaPods will handle linking.

## Building the native libraries

If you want to build libXray from source (for example to update to a newer upstream commit), run the build script:

```bash
python3 scripts/build_and_wire.py
```

This script will:

1. Build `libXray.aar` for Android
2. Build `LibXray.xcframework` for iOS and macOS
3. Copy both artifacts into the plugin directories
4. Patch the native build files if needed

You need Go, gomobile, Python 3, and Xcode (for Apple builds) installed.

## API overview

All methods that talk to the Xray engine return a `CallResponse<T>` object. If `success` is true, the call worked. If `success` is false, check `error` for the message.

### Starting and stopping Xray

```dart
final xray = FlutterXray();

// Run from a JSON config string
final response = await xray.runXrayFromJSON(
  RunXrayFromJSONRequest(
    datDir: appDocumentsPath,
    configJSON: jsonString,
  ),
);

if (response.success) {
  print('Xray is running');
}

// Stop it
await xray.stopXray();

// Check if it is running
final running = await xray.getXrayState();
```

### TUN fd

If you have a TUN file descriptor from your own VPN service, pass it before starting Xray:

```dart
await xray.setTunFd(fd);
```

### Testing and ping

```dart
// Validate a config file
final testResult = await xray.testXray(
  RunXrayRequest(datDir: path, configPath: configFilePath),
);

// Measure delay
final pingResult = await xray.ping(
  PingRequest(datDir: path, configPath: configFilePath),
);
print('Delay: ${pingResult.data} ms');
```

### Stats

```dart
final stats = await xray.queryStats('tag');
```

### Share links

```dart
// Convert v2rayN / Clash share links to Xray JSON
final json = await xray.convertShareLinksToXrayJson(linksText);

// Convert Xray JSON back to share links
final links = await xray.convertXrayJsonToShareLinks(xrayJsonMap);
```

### Geo data

```dart
await xray.countGeoData(
  CountGeoDataRequest(datDir: path, name: 'geoip', geoType: 'ip'),
);

final geo = await xray.readGeoFiles(base64EncodedConfig);
```

### DNS (non Android)

On iOS and macOS you can init and reset DNS:

```dart
await xray.initDns(InitDnsRequest(dns: '1.1.1.1', deviceName: 'eth0'));
await xray.resetDns();
```

### Android controllers

On Android you can register dialer and listener controllers. The plugin will ask your Flutter app to protect sockets via a secondary method channel `flutter_xray/protect`.

```dart
await xray.registerDialerController();
await xray.registerListenerController();
await xray.initAndroidDns('1.1.1.1');
await xray.resetAndroidDns();
```

## Example app

The `example/` folder has a small demo. You can paste an Xray JSON config, then tap Start, Stop, Test, or Ping. It also shows the Xray version and running state.

To run it:

```bash
cd example
flutter run
```

## Contributing

We welcome contributions. If you want to help, here is how:

1. Fork the repo and create a branch for your changes.
2. Make your changes and add tests if possible.
3. Run `flutter analyze` and `flutter test` to make sure everything is clean.
4. Open a pull request with a clear description of what you changed and why.

Please keep the code style consistent with the rest of the project. If you are adding a new feature, open an issue first so we can discuss it.

## Security

If you find a security issue, please do not open a public issue. Send an email to the maintainers instead. See [SECURITY.md](.github/SECURITY.md) for details.

## License

This project is licensed under the LGPLv3. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

This plugin is a wrapper around [libXray](https://github.com/XTLS/libXray) by the XTLS team, which itself wraps [Xray-core](https://github.com/XTLS/Xray-core). All credit for the underlying engine goes to the XTLS project.
