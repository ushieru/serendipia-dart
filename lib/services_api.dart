import 'dart:convert';

import 'package:serendipia/helpers/get_remote_address.dart';
import 'package:serendipia/service_registry.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final serviceRegistry = ServiceRegistry();

Router servicesApi() {
  final router = Router();

  router.post('/', (Request request) async {
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

  router.delete('/', (Request request) async {
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

  router.get('/<servicename>', (Request request, String servicename) async {
    var service = serviceRegistry.get(servicename);
    if (service == null) return Response.notFound(null);
    return Response.ok(json.encode(service.toJson()),
        headers: {'Content-Type': 'application/json'});
  });

  router.get('/<servicename>/<serviceversion>',
      (Request request, String servicename, String serviceversion) async {
    var service = serviceRegistry.get(servicename, version: serviceversion);
    if (service == null) return Response.notFound(null);
    return Response.ok(json.encode(service.toJson()),
        headers: {'Content-Type': 'application/json'});
  });

  return router;
}
