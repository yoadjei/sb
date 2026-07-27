class BluetoothException implements Exception {
  BluetoothException(this.message);

  final String message;

  @override
  String toString() => 'BluetoothException: $message';
}
