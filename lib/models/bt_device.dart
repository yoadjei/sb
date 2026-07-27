class BtDevice {
  final String name;
  final String address;
  final int? rssi;

  const BtDevice({
    required this.name,
    required this.address,
    this.rssi,
  });
}
