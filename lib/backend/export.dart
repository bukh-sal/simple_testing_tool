import 'dart:io';

// path provider for windows
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'models.dart';
import 'package:excel/excel.dart';

Future<void> saveExcelFile(List<TestPath> testPaths) async {
  // create a new excel file
  var excel = Excel.createExcel();

  // create a new sheet
  var sheet = excel['Summary'];

  // add headers (timestamp, path, sample size, average response time, standard deviation)
  sheet.appendRow([
    'Timestamp',
    'Path',
    'Sample Size',
    'Average Response Time (ms)',
    'Standard Deviation'
  ]);

  // add test results
  for (var testPath in testPaths) {
    sheet.appendRow([
      testPath.timestamp.toString().split('.')[0],
      testPath.path,
      testPath.sampleSize,
      testPath.averageResponseTime,
      testPath.standardDeviation,
    ]);
  }

  // another sheet for raw data
  var sheet2 = excel['Raw Data'];

  // add headers (timestamp, path, sample size, response time, status code)
  sheet2.appendRow(['Timestamp', 'Path', 'Response Time (ms)', 'Status Code']);

  // add raw data
  for (var testPath in testPaths) {
    for (var responseTime in testPath.responseTimes.keys) {
      sheet2.appendRow([
        testPath.timestamp.toString().split('.')[0],
        testPath.path,
        responseTime,
        testPath.responseTimes[responseTime],
      ]);
    }
  }

  DateTime now = DateTime.now();
  String today = '${now.year}-${now.month}-${now.day}';
  String fileName = 'testingResults_$today.xlsx';

  // if device is IOS or Android
  if (Platform.isIOS || Platform.isAndroid) {
    var fileBytes = excel.save();
    var directory = await getApplicationDocumentsDirectory();

    File('$directory/$fileName')
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
  } else if (kIsWeb) {
    var fileBytes = excel.save(fileName: fileName);
  } else if (Platform.isWindows) {
    var downloadsDirectory = await getDownloadsDirectory();
    var downloadsPath = downloadsDirectory!.path;
    var filePath = '$downloadsPath/$fileName';
    var file = File(filePath);
    file.writeAsBytesSync(excel.encode()!);
  }
}
