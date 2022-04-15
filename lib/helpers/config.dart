class Config {
  final int port;
  final int failureThreshold;
  final int cooldownPeriod;
  final int requestTimeout;
  final int heartBeat;
  final String jwt;
  static Config? _config;

  Config._(this.port, this.failureThreshold, this.cooldownPeriod,
      this.requestTimeout, this.heartBeat, this.jwt);

  factory Config(
      {int? port,
      int? failureThreshold,
      int? cooldownPeriod,
      int? requestTimeout,
      int? heartBeat,
      String? jwt}) {
    return _config ??= Config._(port ?? 5000, failureThreshold ?? 5,
        cooldownPeriod ?? 10, requestTimeout ?? 2, heartBeat ?? 5, jwt ?? '');
  }

  toJson() => {
        'port': port,
        'failureThreshold': failureThreshold,
        'cooldownPeriod': cooldownPeriod,
        'requestTimeout': requestTimeout,
        'heartBeat': heartBeat,
      };
}
