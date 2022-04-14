import 'dart:io';
import 'package:shelf/shelf.dart';

String getRemoteAddress(Request request) {
  return (request.context['shelf.io.connection_info'] as HttpConnectionInfo)
      .remoteAddress
      .address;
}
