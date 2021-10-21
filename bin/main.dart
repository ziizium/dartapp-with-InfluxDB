// @dart=2.9

import 'dart:io';

import 'package:influxdb_client/api.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = DevHttpOverrides();

  var client = InfluxDBClient(
      url: 'https://localhost:8086',
      token:
          'Your token',
      org: 'Your org name',
      bucket: 'Your bucket name',
      debug: true);

  var healthCheck = await client.getHealthApi().getHealth();
  print(
      'Health check: ${healthCheck.name}/${healthCheck.version} - ${healthCheck.message}');
  
  client.close();
}
