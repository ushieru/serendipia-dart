import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:serendipia/service_registry.dart';

void main(List<String> arguments) async {
  final parser = _getParser();
  final result = parser.parse(arguments);
  var app = Router();
  var serviceRegistry = ServiceRegistry();

  app.post('/services', (Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body);
    var serviceName = json['service_name'];
    var serviceVersion = json['service_version'];
    var servicePort = json['service_port'];
    if (serviceName == null || servicePort == null) {
      return Response.badRequest();
    }
    final servicekey = serviceRegistry.register(
        serviceName, getRemoteAddress(request), servicePort,
        version: serviceVersion ?? '1.0.0');
    return Response.ok('{"servicekey":"$servicekey"}',
        headers: {'Content-Type': 'application/json'});
  });

  app.delete('/services', (Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body);
    var serviceName = json['service_name'];
    var serviceVersion = json['service_version'];
    var servicePort = json['service_port'];
    if (serviceName == null || servicePort == null) {
      return Response.badRequest();
    }
    final servicekey = serviceRegistry.unregister(
        serviceName, getRemoteAddress(request), servicePort,
        version: serviceVersion ?? '1.0.0');
    return Response.ok('{"servicekey":"$servicekey"}',
        headers: {'Content-Type': 'application/json'});
  });

  app.get('/services/<servicename>',
      (Request request, String servicename) async {
    var service = serviceRegistry.get(servicename);
    if (service == null) return Response.notFound(null);
    return Response.ok('${service.toJson()}',
        headers: {'Content-Type': 'application/json'});
  });

  app.get('/services/<servicename>/<serviceversion>',
      (Request request, String servicename, String serviceversion) async {
    var service = serviceRegistry.get(servicename, version: serviceversion);
    if (service == null) return Response.notFound(null);
    return Response.ok('${service.toJson()}',
        headers: {'Content-Type': 'application/json'});
  });

  app.all('/<ignored|.*>', (Request request) async {
    final segments = request.requestedUri.pathSegments;
    final serviceName = segments.first;
    final path = segments.skip(1).join('/');
    final service = serviceRegistry.get(serviceName);
    if (service == null) return Response.notFound(null);
    final uri = 'http://${service.ip}:${service.port}/$path';
    final method = request.method;
    var url = Uri.parse(uri);
    switch (method) {
      case 'GET':
        print('GET $uri');
        final response = await http.get(url);
        return Response.ok(response.body, headers: response.headers);
      case 'POST':
        print('POST $uri');
        final response = await http.post(url,
            body: await request.readAsString(),
            headers: {'Content-Type': 'application/json'});
        return Response.ok(response.body, headers: response.headers);
      case 'PUT':
        print('PUT $uri');
        final response = await http.put(url,
            body: await request.readAsString(),
            headers: {'Content-Type': 'application/json'});
        return Response.ok(response.body, headers: response.headers);
      case 'DELETE':
        print('DELETE $uri');
        final response = await http.delete(url,
            body: await request.readAsString(),
            headers: {'Content-Type': 'application/json'});
        return Response.ok(response.body, headers: response.headers);
      default:
        return Response.notFound(null);
    }
  });

  io
      .serve(app, '0.0.0.0', int.parse(result['port'] as String))
      .then((server) => print('.------------.\n'
          '| serendipia |\n'
          "'------------'\n"
          'Running at '
          'http://${server.address.host}:${server.port}'));
}

getRemoteAddress(Request request) {
  return (request.context['shelf.io.connection_info'] as HttpConnectionInfo)
      .remoteAddress
      .address;
}

ArgParser _getParser() =>
    ArgParser()..addOption('port', abbr: 'p', defaultsTo: '5000');
