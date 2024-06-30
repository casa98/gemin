import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PlatformChannelExample());
}

class AppInfo {
  AppInfo({required this.packageName, required this.appName});

  factory AppInfo.fromMap(Map<String, dynamic> map) {
    return AppInfo(
      packageName: map['packageName'] as String,
      appName: map['appName'] as String,
    );
  }

  final String packageName;
  final String appName;
}

class PlatformChannelExample extends StatefulWidget {
  const PlatformChannelExample({super.key});

  @override
  State<PlatformChannelExample> createState() => _PlatformChannelExampleState();
}

class _PlatformChannelExampleState extends State<PlatformChannelExample> {
  static const platform = MethodChannel('com.casa98/platform_channel');

  List<AppInfo> _installedApps = [];
  String _launchResult = 'No app launched yet.';

  @override
  void initState() {
    super.initState();
    _getInstalledApps();
  }

  Future<void> _getInstalledApps() async {
    try {
      final List<dynamic> result =
          await platform.invokeMethod('getInstalledApps');
      setState(() {
        _installedApps = result.map((app) {
          final Map<String, dynamic> appMap =
              Map<String, dynamic>.from(app as Map);
          return AppInfo.fromMap(appMap);
        }).toList();
      });
    } on PlatformException catch (e) {
      setState(() {
        _installedApps = [
          AppInfo(
            packageName: 'error',
            appName: 'Failed to get installed apps: ${e.message}',
          ),
        ];
      });
    }
  }

  Future<void> _launchApp(String packageName) async {
    try {
      final String result =
          await platform.invokeMethod('launchApp', {'package': packageName});
      setState(() {
        _launchResult = result;
      });
    } on PlatformException catch (e) {
      setState(() {
        _launchResult = 'Failed to launch app: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Platform Channel Example'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _installedApps.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_installedApps[index].appName),
                    subtitle: Text(_installedApps[index].packageName),
                    onTap: () => _launchApp(_installedApps[index].packageName),
                  );
                },
              ),
            ),
            Text(_launchResult),
          ],
        ),
      ),
    );
  }
}
