import 'dart:convert';

import 'package:args/args.dart';
import 'package:serendipia/gateway.dart';
import 'package:serendipia/helpers/config.dart';
import 'package:serendipia/helpers/init_msg.dart';
import 'package:serendipia/jwt_checker.dart';
import 'package:serendipia/service_registry.dart';
import 'package:serendipia/services_api.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main(List<String> arguments) async {
  final parser = _getParser();
  final result = parser.parse(arguments);
  final config = Config(
    port: int.tryParse(result['port'] as String),
    failureThreshold: int.tryParse(result['failureThreshold'] as String),
    cooldownPeriod: int.tryParse(result['cooldownPeriod'] as String),
    requestTimeout: int.tryParse(result['requestTimeout'] as String),
    heartBeat: int.tryParse(result['heartBeat'] as String),
    jwt: result['jwt'] as String,
  );

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
    final payload = {'config': config.toJson(), 'services': services};
    return Response.ok(json.encode(payload),
        headers: {'Content-Type': 'application/json'});
  });

  app.mount('/services', servicesApi());

  app.all('/<ignored|.*>', (Request request) async {
    if (config.jwt.isNotEmpty && jwtChecker(request)) {
      return Response.forbidden('You are not allowed to access this resource.');
    }
    final response = await gateway(request);
    return Response(response.statusCode,
        body: response.readAsString(), headers: response.headers);
  });

  io
      .serve(app, '0.0.0.0', config.port)
      .then((server) => print(initMsg(server.address.host, server.port)));
}

ArgParser _getParser() => ArgParser()
  ..addOption('port', abbr: 'p', defaultsTo: '5000')
  ..addOption('heartBeat', abbr: 'h', defaultsTo: '5')
  ..addOption('jwt', abbr: 'j', defaultsTo: '')
  ..addOption('failureThreshold', abbr: 'f', defaultsTo: '5')
  ..addOption('cooldownPeriod', abbr: 'c', defaultsTo: '10')
  ..addOption('requestTimeout', abbr: 'r', defaultsTo: '2');
