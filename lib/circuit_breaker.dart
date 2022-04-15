import 'dart:async';

import 'package:serendipia/models/circuit_breaker_state.dart';
import 'package:shelf/shelf.dart';
import 'package:http/http.dart' as http;

class CircuitBreaker {
  final Map<String, CircuitBreakerState> _states = {};
  final int _failureThreshold;
  final int _cooldownPeriod;
  final int _requestTimeout;

  CircuitBreaker({
    int failureThreshold = 5,
    int cooldownPeriod = 10,
    int requestTimeout = 2,
  })  : _failureThreshold = failureThreshold,
        _cooldownPeriod = cooldownPeriod,
        _requestTimeout = requestTimeout;

  Future<Response> callService(String method, String url,
      {Map<String, String>? headers, Object? body}) async {
    final endpoint = '$method:$url';
    if (!_canRequest(endpoint)) {
      return Response(503, body: 'Service Unavailable');
    }
    final uri = Uri.parse(url);
    http.Response? microResponse;
    try {
      switch (method) {
        case 'GET':
          microResponse =
              await http.get(uri).timeout(Duration(seconds: _requestTimeout));
          break;
        case 'POST':
          microResponse = await http
              .post(uri, body: body, headers: headers)
              .timeout(Duration(seconds: _requestTimeout));
          break;
        case 'PUT':
          microResponse = await http
              .put(uri, body: body, headers: headers)
              .timeout(Duration(seconds: _requestTimeout));
          break;
        case 'DELETE':
          microResponse = await http
              .delete(uri, body: body, headers: headers)
              .timeout(Duration(seconds: _requestTimeout));
          break;
      }
      if (microResponse != null) {
        _onSuccess(endpoint);
        return Response(microResponse.statusCode,
            body: microResponse.body, headers: microResponse.headers);
      } else {
        _onFailure(endpoint);
        return Response.notFound(null);
      }
    } on TimeoutException catch (_) {
      _onFailure(endpoint);
      return Response(408, body: 'Request timed out');
    } catch (e) {
      return Response.internalServerError();
    }
  }

  void _onSuccess(String endpoint) {
    _initState(endpoint);
  }

  void _onFailure(String endpoint) {
    final state = _states[endpoint]!;
    state.failures++;
    if (state.failures >= _failureThreshold) {
      state.circuit = CircuitBreakerStates.open;
      state.nextTry =
          (DateTime.now().millisecondsSinceEpoch / 1000) + _cooldownPeriod;
      print('[CircuitBreaker] $endpoint is now in open state');
    }
  }

  bool _canRequest(String endpoint) {
    if (!_states.containsKey(endpoint)) _initState(endpoint);
    final state = _states[endpoint]!;
    if (state.circuit == CircuitBreakerStates.closed) return true;
    if (DateTime.now().millisecondsSinceEpoch / 1000 >= state.nextTry) {
      state.circuit = CircuitBreakerStates.halfOpen;
      return true;
    }
    return false;
  }

  void _initState(String endpoint) {
    _states[endpoint] =
        CircuitBreakerState(0, _cooldownPeriod, CircuitBreakerStates.closed, 0);
  }
}
