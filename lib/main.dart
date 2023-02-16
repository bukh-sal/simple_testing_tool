import 'package:flutter/material.dart';
import 'backend/models.dart';
import 'backend/io.dart';
import 'backend/export.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Response Time Test',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: const MyHomePage(title: 'Response Time Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<TestPath> _testPaths = <TestPath>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),

        // allow the user to change baseUrl and sessionID
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Settings'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          // set default value as baseUrl
                          controller: TextEditingController(text: baseUrl),

                          decoration: const InputDecoration(
                            labelText: 'Base URL',
                          ),
                          onChanged: (String value) {
                            baseUrl = value;
                          },
                        ),
                        TextField(
                          controller: TextEditingController(text: sessionID),
                          decoration: const InputDecoration(
                            labelText: 'Session ID',
                          ),
                          onChanged: (String value) {
                            sessionID = value;
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),

      // show the list of test paths
      body: ListView.builder(
        itemCount: _testPaths.length,
        itemBuilder: (BuildContext context, int index) {
          TestPath testPath = _testPaths[index];
          return ListTile(
            title: Text(testPath.path),
            subtitle: Text(
              testPath.averageResponseTime.isNaN
                  ? 'not sent yet'
                  : 'avg. response: ${testPath.averageResponseTime.toStringAsFixed(2)} ms'
                      ' (std: ${testPath.standardDeviation.toStringAsFixed(2)} ms)'
                      ' (n: ${testPath.sampleSize})'
                      ' (time between: ${testPath.milliSecondsBetweenRequests} ms)',
            ),
            // 3 buttons: send requests, edit, and delete
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    // show a spinner while sending requests and remove it when done
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                    await testPath.sendRequests();
                    Navigator.of(context).pop();
                    // update the list
                    setState(() {});

                    // show a snackbar to show the result
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'avg. response: ${testPath.averageResponseTime.toStringAsFixed(2)} ms'
                          ' (std: ${testPath.standardDeviation.toStringAsFixed(2)} ms)'
                          ' (n: ${testPath.sampleSize})'
                          ' (time between: ${testPath.milliSecondsBetweenRequests} ms)',
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Edit test path'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                // set default value as path
                                controller:
                                    TextEditingController(text: testPath.path),
                                decoration: const InputDecoration(
                                  labelText: 'Path',
                                ),
                                onChanged: (String value) {
                                  testPath.path = value;
                                },
                              ),
                              TextField(
                                // set default value as sampleSize
                                controller: TextEditingController(
                                    text: testPath.sampleSize.toString()),
                                decoration: const InputDecoration(
                                  labelText: 'Sample size',
                                ),
                                onChanged: (String value) {
                                  testPath.sampleSize = int.parse(value);
                                },
                              ),
                              // Milliseconds between requests
                              TextField(
                                // set default value as milliSecondsBetweenRequests
                                controller: TextEditingController(
                                    text: testPath.milliSecondsBetweenRequests
                                        .toString()),
                                decoration: const InputDecoration(
                                  labelText: 'Milliseconds between requests',
                                ),
                                onChanged: (String value) {
                                  testPath.milliSecondsBetweenRequests =
                                      int.parse(value);
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                // update the list
                                setState(() {});
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _testPaths.removeAt(index);
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),

      // add a new test path (all values are temporary, then saved in the list as a TestPath object)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String path = '';
              int sampleSize = 0;
              int milliSecondsBetweenRequests = 0;
              return AlertDialog(
                title: const Text('Add a new test path'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Path',
                      ),
                      onChanged: (String value) {
                        setState(() {
                          path = value;
                        });
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Sample size',
                      ),
                      onChanged: (String value) {
                        setState(() {
                          sampleSize = int.parse(value);
                        });
                      },
                    ),
                    // Milliseconds between requests
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Milliseconds between requests',
                      ),
                      onChanged: (String value) {
                        setState(() {
                          milliSecondsBetweenRequests = int.parse(value);
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      _testPaths.add(TestPath(
                          path,
                          sampleSize,
                          milliSecondsBetweenRequests,
                          {0.0: 0},
                          DateTime.now()));
                      Navigator.of(context).pop();
                      // update the list
                      setState(() {});
                    },
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Add a new test path',
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                // show a spinner while sending requests and remove it when done
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
                for (TestPath testPath in _testPaths) {
                  await testPath.sendRequests();
                }
                Navigator.of(context).pop();
                // update the list
                setState(() {});

                // show a snackbar to show the result
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All requests sent'),
                  ),
                );
              },
            ),

            //
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                await saveExcelFile(_testPaths);
                // show a snackbar to show the result
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Downloaded'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// I hope this helps you. If you have any questions, please let me know.
