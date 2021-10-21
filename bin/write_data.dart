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

  var writeApi = client.getWriteService(WriteOptions().merge(
      precision: WritePrecision.s,
      batchSize: 100,
      flushInterval: 5000,
      gzip: true));

  var point = Point('watt-hour')
      .addTag('house_name', 'The Johnsons')
      .addField('electricity_consumption', 120)
      .time(DateTime.now().toUtc());

  await writeApi.write(point).then((value) {
    print('Write completed 1');
  }).catchError((exception) {
    print(exception);
  });
}
