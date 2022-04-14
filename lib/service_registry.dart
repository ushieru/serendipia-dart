import 'dart:math';
import 'package:serendipia/models/service.dart';
import 'package:version/version.dart';

class ServiceRegistry {
  final Map<String, Service> _services = <String, Service>{};
  final int timeout = 300;

  Service? get(String name, {version = '1.0.0'}) {
    Version _version = Version.parse(version);
    var candidates = _services.values
        .where((service) => service.name == name && service.version >= _version)
        .toList();
    if (candidates.isEmpty) return null;
    return candidates[Random().nextInt(candidates.length)];
  }

  String register(String name, String ip, String port,
      {String version = '1.0.0'}) {
    cleanup();
    final key = '$name$version$ip$port';
    final now = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    if (_services.containsKey(key)) {
      _services[key]!.timestamp = now;
      print('Updated service: $name, $version at $ip:$port');
    } else {
      _services[key] = Service(name, Version.parse(version), ip, port, now);
      print('Registered service: $name, $version at $ip:$port');
    }
    return key;
  }

  String unregister(String name, String ip, String port,
      {String version = '1.0.0'}) {
    final key = '$name$version$ip$port';
    final service = _services.remove(key);
    if (service != null) print('Eliminating service: $key');
    return key;
  }

  void cleanup() {
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    _services.removeWhere((key, service) {
      var willBeEliminated = now - service.timestamp > timeout;
      if (willBeEliminated) print('Eliminating service: $key');
      return willBeEliminated;
    });
  }
}