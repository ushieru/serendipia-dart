import 'package:version/version.dart';

class Service {
  final String name;
  final Version version;
  final String ip;
  final String port;
  int timestamp;
  Service(this.name, this.version, this.ip, this.port, this.timestamp);
  toJson() => {
        'name': name,
        'version': version.toString(),
        'ip': ip,
        'port': port,
        'timestamp': timestamp,
      };
}
