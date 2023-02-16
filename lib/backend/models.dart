import 'dart:math';
import 'package:http/http.dart';

import 'io.dart';

class TestPath {
  String path;
  int sampleSize;
  int milliSecondsBetweenRequests;

  Map<double, int> responseTimes;
  DateTime timestamp;

  TestPath(
    this.path,
    this.sampleSize,
    this.milliSecondsBetweenRequests,
    this.responseTimes,
    this.timestamp,
  );

  double get averageResponseTime {
    double sum = 0;
    responseTimes.forEach((key, value) => sum += key);
    return sum / responseTimes.length;
  }

  double get standardDeviation {
    double sum = 0;
    responseTimes
        .forEach((key, value) => sum += pow(key - averageResponseTime, 2));
    return sqrt(sum / responseTimes.length);
  }

  // send request one request at a time
  Future<void> sendRequest() async {
    DateTime start = DateTime.now();
    Response response = await authenticatedGetRequest(path);
    int statusCode = response.statusCode;
    DateTime end = DateTime.now();
    Duration duration = end.difference(start);
    double responseTime = duration.inMilliseconds.toDouble();
    responseTimes[responseTime] = statusCode;
  }

  // send all requests one by one
  Future<void> sendRequests() async {
    responseTimes.clear();
    timestamp = DateTime.now();
    for (int i = 0; i < sampleSize; i++) {
      await sendRequest();
      await Future.delayed(Duration(milliseconds: milliSecondsBetweenRequests));
    }
  }
}
