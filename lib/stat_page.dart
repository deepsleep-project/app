import 'package:drp_19/storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Replace with your actual SleepStorage and record model import
// import 'your_storage_file.dart';

class StatPage extends StatefulWidget {
  const StatPage({super.key});

  @override
  _StatPageState createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  List<SleepRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await SleepStorage.loadRecords();
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sleep History')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? Center(child: Text('No records found.'))
          : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final r = _records[index];
                return ListTile(
                  title: Text(
                    'Start: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(r.start))}',
                  ),
                  subtitle: Text(
                    'End: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(r.end))}',
                  ),
                );
              },
            ),
    );
  }
}
