import 'dart:convert';

import 'package:args/args.dart';
import 'package:serendipia/gateway.dart';
import 'package:serendipia/service_registry.dart';
import 'package:serendipia/services_api.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main(List<String> arguments) async {
  final parser = _getParser();
  final result = parser.parse(arguments);
  final app = Router();
  final serviceRegistry = ServiceRegistry();

  app.get('/', (_, [__]) {
    final services = <String, List<Map<String, dynamic>>>{};
    for (var service in serviceRegistry.services.values) {
      if (services.containsKey(service.name)) {
        services[service.name]!.add(service.toJson());
      } else {
        services[service.name] = [service.toJson()];
      }
    }
    return Response.ok(json.encode(services),
        headers: {'Content-Type': 'application/json'});
  });

  app.mount('/services', servicesApi());

  app.all('/<ignored|.*>', gateway);

  io
      .serve(app, '0.0.0.0', int.tryParse(result['port'] as String) ?? 5000)
      .then((server) => print(_initMsg(server.address.host, server.port)));
}

String _initMsg(String host, int port) => ''
    '.------------.\n'
    '| serendipia |\n'
    "'------------'\n"
    'Running at '
    'http://$host:$port';

ArgParser _getParser() =>
    ArgParser()..addOption('port', abbr: 'p', defaultsTo: '5000');
