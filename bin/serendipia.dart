import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:serendipia/helpers/check_run_time_type.dart';
import 'package:yaml/yaml.dart';
import 'package:serendipia/gateway.dart';
import 'package:serendipia/helpers/config.dart';
import 'package:serendipia/helpers/init_msg.dart';
import 'package:serendipia/helpers/jwt_checker.dart';
import 'package:serendipia/service_registry.dart';
import 'package:serendipia/services_api.dart';
import 'package:serendipia/templates/index.html.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

void main() async {
  final file = File(join(Directory.current.path, 'config.yaml'));
  if (file.existsSync()) {
    final ymlConfig = loadYaml(file.readAsStringSync());
    List<String> ignorejwt =
        checkRunTimeType(ymlConfig['ignorejwt'], 'YamlList') != null
            ? List.castFrom<dynamic, String>(ymlConfig['ignorejwt'])
            : <String>[];
    print(checkRunTimeType(ymlConfig['jwt'], 'String'));
    Config(
        port: checkRunTimeType(ymlConfig['port'], 'int'),
        heartBeat: checkRunTimeType(ymlConfig['heartBeat'], 'int'),
        failureThreshold:
            checkRunTimeType(ymlConfig['failureThreshold'], 'int'),
        cooldownPeriod: checkRunTimeType(ymlConfig['cooldownPeriod'], 'int'),
        requestTimeout: checkRunTimeType(ymlConfig['requestTimeout'], 'int'),
        jwt: checkRunTimeType(ymlConfig['jwt'], 'String'),
        instancesIgnoreJWT: ignorejwt);
  }
  final config = Config();

  final app = Router();
  final serviceRegistry = ServiceRegistry();

  app.get('/favicon.ico', (_, [__]) => Response.ok(''));

  app.get(
      '/service-worker.js',
      (_, [__]) =>
          Response.ok('', headers: {'content-type': 'text/javascript'}));

  app.get(
      '/ws',
      (Request request, [__]) => webSocketHandler((webSocket) {
            serviceRegistry.setHandler(() {
              final services = <String, List<Map<String, dynamic>>>{};
              for (var service in serviceRegistry.services.values) {
                if (services.containsKey(service.name)) {
                  services[service.name]!.add(service.toJson());
                } else {
                  services[service.name] = [service.toJson()];
                }
              }
              webSocket.sink.add(JsonEncoder().convert(services));
            });
          })(request));

  app.get('/', (_, [__]) {
    final services = <String, List<Map<String, dynamic>>>{};
    for (var service in serviceRegistry.services.values) {
      if (services.containsKey(service.name)) {
        services[service.name]!.add(service.toJson());
      } else {
        services[service.name] = [service.toJson()];
      }
    }
    return Response.ok(indexHtml(config, services), headers: {
      'content-type': 'text/html',
    });
  });

  app.mount('/services', servicesApi());

  app.all('/<ignored|.*>', (Request request) async {
    final segments = request.requestedUri.pathSegments;
    final serviceName = segments.first;
    if (!config.instancesIgnoreJWT.contains(serviceName) &&
        (config.jwt.isNotEmpty && !jwtChecker(request))) {
      return Response.forbidden('You are not allowed to access this resource.');
    }
    final response = await gateway(request);
    return Response(response.statusCode,
        body: await response.readAsString(), headers: response.headers);
  });

  io
      .serve(app, '0.0.0.0', config.port)
      .then((server) => print(initMsg('localhost', server.port)));
}
