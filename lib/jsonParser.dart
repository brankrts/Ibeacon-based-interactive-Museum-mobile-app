class JsonFormat {
  String? name;
  String? uuid;
  String? macAddress;
  String? major;
  String? minor;
  double distance = 0.0;
  String? proximity;
  String? scanTime;
  String? rssi;
  String? txPower;

  JsonFormat(
      {this.name,
      this.uuid,
      this.macAddress,
      this.major,
      this.minor,
      this.distance = 0,
      this.proximity,
      this.scanTime,
      this.rssi,
      this.txPower});

  JsonFormat.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    uuid = json['uuid'];
    macAddress = json['macAddress'];
    major = json['major'];
    minor = json['minor'];
    distance = double.parse(json['distance']);
    proximity = json['proximity'];
    scanTime = json['scanTime'];
    rssi = json['rssi'];
    txPower = json['txPower'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['uuid'] = this.uuid;
    data['macAddress'] = this.macAddress;
    data['major'] = this.major;
    data['minor'] = this.minor;
    data['distance'] = this.distance;
    data['proximity'] = this.proximity;
    data['scanTime'] = this.scanTime;
    data['rssi'] = this.rssi;
    data['txPower'] = this.txPower;
    return data;
  }
}
