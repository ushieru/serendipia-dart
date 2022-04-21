checkRunTimeType(runTimeType, String type) {
  if (runTimeType.runtimeType.toString() == type) {
    return runTimeType;
  }
  return null;
}
