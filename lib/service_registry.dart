import 'dart:async';
import 'package:serendipia/helpers/config.dart';
import 'package:serendipia/models/service.dart';
import 'package:version/version.dart';

class ServiceRegistry {
  final Map<String, Service> _services = <String, Service>{};
  final Map<String, int> _counter = <String, int>{};
  final int heartBeat = Config().heartBeat;
  static ServiceRegistry? _serviceRegistry;
  final List<void Function()> _handlers = [];

  ServiceRegistry._() {
    _initTimer();
  }

  factory ServiceRegistry() {
    return _serviceRegistry ??= ServiceRegistry._();
  }

  void _initTimer() =>
      Timer.periodic(Duration(seconds: heartBeat), (timer) => cleanup());

  void setHandler(void Function() handler) {
    _handlers.add(handler);
  }

  void _triggerHandlers() async {
    for (var handler in _handlers) {
      handler();
    }
  }

  int _getnextMicro(String name, int maxLimit) {
    final serviceNum = _counter[name] ??= 0;
    final virtualNext = serviceNum + 1;
    final next = virtualNext >= maxLimit ? 0 : virtualNext;
    _counter[name] = next;
    return serviceNum;
  }

  Service? get(String name, {version = '1.0.0'}) {
    Version _version = Version.parse(version);
    var candidates = _services.values
        .where((service) => service.name == name && service.version >= _version)
        .toList();
    if (candidates.isEmpty) return null;
    return candidates[_getnextMicro(name, candidates.length)];
  }

  String register(String name, String ip, String port,
      {String version = '1.0.0'}) {
    final key = '$name$version$ip$port';
    final now = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    if (_services.containsKey(key)) {
      _services[key]!.timestamp = now;
      print('[ServiceRegistry] Updated service: $name, $version at $ip:$port');
    } else {
      _services[key] = Service(name, Version.parse(version), ip, port, now);
      _triggerHandlers();
      print(
          '[ServiceRegistry] Registered service: $name, $version at $ip:$port');
    }
    return key;
  }

  String unregister(String name, String ip, String port,
      {String version = '1.0.0'}) {
    final key = '$name$version$ip$port';
    final service = _services.remove(key);
    if (service != null) {
      print('[ServiceRegistry] Unregister service: $key');
      _triggerHandlers();
    }
    return key;
  }

  void cleanup() {
    var someRemoved = false;
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    _services.removeWhere((key, service) {
      var willBeEliminated = now - service.timestamp > heartBeat;
      if (willBeEliminated) {
        print('[ServiceRegistry] Eliminating service: $key');
        someRemoved = true;
      }
      return willBeEliminated;
    });
    if (someRemoved) _triggerHandlers();
  }

  Map<String, Service> get services => _services;
}
