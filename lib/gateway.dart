import 'package:serendipia/service_registry.dart';
import 'package:shelf/shelf.dart';
import 'package:http/http.dart' as http;

final serviceRegistry = ServiceRegistry();

gateway(Request request, [params]) async {
  final segments = request.requestedUri.pathSegments;
  final serviceName = segments.first;
  final service = serviceRegistry.get(serviceName);
  if (service == null) return Response.notFound(null);
  final path = segments.skip(1).join('/');
  final method = request.method;
  final url = Uri.parse('http://${service.ip}:${service.port}/$path');
  final body = await request.readAsString();
  print('PROXY => [$method] $url\n\tbody=>\n$body');
  switch (method) {
    case 'GET':
      final response = await http.get(url);
      return Response.ok(response.body, headers: response.headers);
    case 'POST':
      final response =
          await http.post(url, body: body, headers: request.headers);
      return Response.ok(response.body, headers: response.headers);
    case 'PUT':
      final response =
          await http.put(url, body: body, headers: request.headers);
      return Response.ok(response.body, headers: response.headers);
    case 'DELETE':
      final response =
          await http.delete(url, body: body, headers: request.headers);
      return Response.ok(response.body, headers: response.headers);
    default:
      return Response.notFound(null);
  }
}
