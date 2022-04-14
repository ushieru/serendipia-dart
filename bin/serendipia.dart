import 'package:args/args.dart';
import 'package:serendipia/gateway.dart';
import 'package:serendipia/services_api.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main(List<String> arguments) async {
  final parser = _getParser();
  final result = parser.parse(arguments);
  final app = Router();

  app.get('/', (_, [__]) => Response.ok('Hello, world!'));

  app.mount('/services', ServicesApi().router);

  app.all('/<ignored|.*>', Gateway().proxy);

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

ArgParser _getParser() => ArgParser()
  ..addOption('port', abbr: 'p', defaultsTo: '5000')
  ..addFlag('');
