import 'package:serendipia/helpers/config.dart';
import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

bool jwtChecker(Request request) {
  final authHeader = request.headers['authorization'];
  if (authHeader == null) return false;
  final config = Config();
  try {
    final authType = authHeader.split(' ')[0];
    if (authType != 'Bearer') return false;
    final token = authHeader.split(' ')[1];
    JWT.verify(token, SecretKey(config.jwt));
    return true;
  } catch (e) {
    return false;
  }
}
