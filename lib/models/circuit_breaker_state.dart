enum CircuitBreakerStates { closed, halfOpen, open }

class CircuitBreakerState {
  int failures;
  int cooldownPeriod;
  CircuitBreakerStates circuit;
  double nextTry;

  CircuitBreakerState(
      this.failures, this.cooldownPeriod, this.circuit, this.nextTry);
}
