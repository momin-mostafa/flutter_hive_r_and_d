import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_r_and_d/app_const.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(AppConst.outgoing);
  await Hive.openBox(AppConst.incoming);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userDataController = TextEditingController();

  final outgoing = Hive.box(AppConst.outgoing);
  List<Map<String, dynamic>> _listOfMap = [{}];

  @override
  void initState() {
    super.initState();
  }

  void _showBottomModal() async {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                TextField(
                  controller: userNameController,
                ),
                TextField(
                  controller: userDataController,
                ),
                ElevatedButton(
                  onPressed: () => _createItem({
                    'userName': userNameController.text,
                    'userData': userDataController.text,
                  }),
                  child: const Text('Submit'),
                ),
              ],
            ),
          );
        });
  }

  _createItem(Map<String, dynamic> data) async {
    await outgoing.add(data);
    log('ammount of data : ${outgoing.length}', name: 'Outgoing');
    _refreshItem();
  }

  _refreshItem() {
    final data = outgoing.keys.map((key) {
      final item = outgoing.get(key);
      log('${item.runtimeType}', name: 'item type');
      // log('${key.runtimeType}', name: 'key type');
      log("'key': $key,'userName': ${item['userName']},'userData': ${item['userData']},",
          name: 'item value');

      return {
        'key': key,
        'userName': item['userName'],
        'userData': item['userData'],
      };
    }).toList();

    setState(() {
      _listOfMap = data;
    });
  }

  Future<void> _deleteItem(int key) async {
    await outgoing.delete(key);
    log('item deleted $key', name: 'Delete Status');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
            itemCount: _listOfMap.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(_listOfMap[index]['userName'] ?? ''),
                  subtitle: Text(_listOfMap[index]['userData'] ?? ''),
                  trailing: IconButton(
                      onPressed: () async {
                        _deleteItem(_listOfMap[index]['key']);
                        _refreshItem();
                      },
                      icon: const Icon(Icons.delete)),
                ),
              );
            }),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: _showBottomModal,
            tooltip: 'add',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: _refreshItem,
            tooltip: 'add',
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
