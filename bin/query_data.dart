// @dart=2.9

import 'dart:async';
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

  // Reading the data
  var queryService = client.getQueryService();

  var fluxQuery = '''
  from(bucket: "test_bck")
  |> range(start: -1d)
  |> filter(fn: (r) => r["_measurement"] == "watt-hour")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
  |> yield(name: "mean")
  ''';

  // query to stream and iterate all records
  var count = 0;
  var recordStream = await queryService.query(fluxQuery);
  await recordStream.forEach((record) {
    print(
        'record: ${count++} ${record['_time']}: ${record['_field']} ${record['house_name']} ${record['_value']}');
  });

  // query to raw CSV string
  // var csvString = await queryService.queryRaw(fluxQuery);
  // print(csvString);

  // listen stream and cancel streaming after condition
  // var stream = await queryService.query(fluxQuery);
  // StreamSubscription<FluxRecord> subscription;
  // subscription = stream.listen((record) {
  //   print('record: ${count++} ${record['_time']}: '
  //       '${record['_field']} ${record['house_name']} ${record['_value']}');
  //   if (record.tableIndex > 5) {
  //     print('Cancel after 5 table');
  //     subscription.cancel();
  //   }
  // }, onError: (e) {
  //   print('Error $e');
  // }, onDone: () => print('Done.'), cancelOnError: true);

  // await Future.delayed(Duration(seconds: 10));
  client.close();
}
