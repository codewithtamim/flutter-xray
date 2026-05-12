import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_xray/flutter_xray.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Xray Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const XrayDemoPage(),
    );
  }
}

class XrayDemoPage extends StatefulWidget {
  const XrayDemoPage({super.key});

  @override
  State<XrayDemoPage> createState() => _XrayDemoPageState();
}

class _XrayDemoPageState extends State<XrayDemoPage> {
  final _flutterXray = FlutterXray();
  final _configController = TextEditingController(
    text: _defaultConfig,
  );

  String _version = 'Unknown';
  bool _isRunning = false;
  String _log = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _refreshState();
  }

  Future<void> _loadVersion() async {
    try {
      final v = await _flutterXray.xrayVersion();
      setState(() => _version = v);
    } on PlatformException catch (e) {
      setState(() => _version = 'Error: ${e.message}');
    }
  }

  Future<void> _refreshState() async {
    try {
      final running = await _flutterXray.getXrayState();
      setState(() => _isRunning = running);
    } on PlatformException catch (e) {
      _appendLog('State error: ${e.message}');
    }
  }

  void _appendLog(String message) {
    setState(() {
      _log = '$message\n$_log';
    });
  }

  Future<String> _getDatDir() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<void> _startXray() async {
    await _refreshState();
    if (_isRunning) {
      _appendLog('Xray is already running. Stop it first.');
      return;
    }

    final configJson = _configController.text.trim();
    if (configJson.isEmpty) {
      _appendLog('Config JSON is empty.');
      return;
    }

    setState(() => _busy = true);
    try {
      final datDir = await _getDatDir();
      final request = RunXrayFromJSONRequest(
        datDir: datDir,
        configJSON: configJson,
      );
      final response = await _flutterXray.runXrayFromJSON(request);
      if (response.success) {
        _appendLog('Xray started successfully.');
      } else {
        _appendLog('Start failed: ${response.error}');
      }
    } on PlatformException catch (e) {
      _appendLog('Platform error: ${e.message}');
    } catch (e) {
      _appendLog('Error: $e');
    } finally {
      setState(() => _busy = false);
      await _refreshState();
    }
  }

  Future<void> _stopXray() async {
    setState(() => _busy = true);
    try {
      final response = await _flutterXray.stopXray();
      if (response.success) {
        _appendLog('Xray stopped successfully.');
      } else {
        _appendLog('Stop failed: ${response.error}');
      }
    } on PlatformException catch (e) {
      _appendLog('Platform error: ${e.message}');
    } catch (e) {
      _appendLog('Error: $e');
    } finally {
      setState(() => _busy = false);
      await _refreshState();
    }
  }

  Future<void> _testConfig() async {
    final configJson = _configController.text.trim();
    if (configJson.isEmpty) {
      _appendLog('Config JSON is empty.');
      return;
    }

    setState(() => _busy = true);
    try {
      final datDir = await _getDatDir();
      // Write JSON to a temp file because testXray expects a file path.
      final tempDir = await getTemporaryDirectory();
      final configFile = File('${tempDir.path}/xray_test_config.json');
      await configFile.writeAsString(configJson);

      final request = RunXrayRequest(
        datDir: datDir,
        configPath: configFile.path,
      );
      final response = await _flutterXray.testXray(request);
      if (response.success) {
        _appendLog('Config is valid.');
      } else {
        _appendLog('Config test failed: ${response.error}');
      }
    } on PlatformException catch (e) {
      _appendLog('Platform error: ${e.message}');
    } catch (e) {
      _appendLog('Error: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _pingConfig() async {
    final configJson = _configController.text.trim();
    if (configJson.isEmpty) {
      _appendLog('Config JSON is empty.');
      return;
    }

    setState(() => _busy = true);
    try {
      final datDir = await _getDatDir();
      final tempDir = await getTemporaryDirectory();
      final configFile = File('${tempDir.path}/xray_ping_config.json');
      await configFile.writeAsString(configJson);

      final request = PingRequest(
        datDir: datDir,
        configPath: configFile.path,
        timeout: 5000,
        url: 'https://www.google.com',
      );
      final response = await _flutterXray.ping(request);
      if (response.success) {
        _appendLog('Ping delay: ${response.data}ms');
      } else {
        _appendLog('Ping failed: ${response.error}');
      }
    } on PlatformException catch (e) {
      _appendLog('Platform error: ${e.message}');
    } catch (e) {
      _appendLog('Error: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Xray Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshState,
            tooltip: 'Refresh state',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Version: $_version',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Status: ${_isRunning ? "Running" : "Stopped"}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _isRunning ? Colors.green : Colors.red,
                    )),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _configController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Xray Config JSON',
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _busy ? null : _startXray,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
                ElevatedButton.icon(
                  onPressed: _busy ? null : _stopXray,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _busy ? null : _testConfig,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Test'),
                ),
                ElevatedButton.icon(
                  onPressed: _busy ? null : _pingConfig,
                  icon: const Icon(Icons.network_ping),
                  label: const Text('Ping'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_busy) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: SelectableText(
                    _log.isEmpty ? 'Logs will appear here...' : _log,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _defaultConfig = r'''
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 10808,
      "protocol": "socks",
      "settings": {
        "auth": "noauth"
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
''';
