import 'package:serendipia/circuit_breaker.dart';
import 'package:serendipia/service_registry.dart';
import 'package:shelf/shelf.dart';

final serviceRegistry = ServiceRegistry();
final _circuitBreaker = CircuitBreaker();

Future<Response> gateway(Request request, [params]) async {
  final segments = request.requestedUri.pathSegments;
  final serviceName = segments.first;
  final service = serviceRegistry.get(serviceName);
  if (service == null) return Response.notFound(null);
  final path = segments.skip(1).join('/');
  final method = request.method;
  final url = 'http://${service.ip}:${service.port}/$path';
  final body = await request.readAsString();
  print('[Gateway] => [$method] $url\n\tbody=>\n$body');
  return await _circuitBreaker.callService(method, url,
      body: body, headers: request.headers);
}
