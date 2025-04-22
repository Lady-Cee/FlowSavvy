import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/period_log.dart';
import '../../../providers/period_log_provider.dart';

class PeriodLogScreen extends StatefulWidget {
  @override
  _PeriodLogScreenState createState() => _PeriodLogScreenState();
}

class _PeriodLogScreenState extends State<PeriodLogScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _flowIntensity;
  final _noteController = TextEditingController();

  final List<String> _intensityOptions = ['Light', 'Moderate', 'Heavy'];

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        isStart ? _startDate = picked : _endDate = picked;
      });
    }
  }

  void _savePeriodLog(BuildContext context) {
    if (_startDate == null || _endDate == null || _flowIntensity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final newLog = PeriodLog(
      startDate: _startDate!,
      endDate: _endDate!,
      flowIntensity: _flowIntensity!,
      note: _noteController.text.trim(),
    );

    Provider.of<PeriodLogProvider>(context, listen: false).addLog(newLog);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Period log saved!')),
    );

    // Clear form
    setState(() {
      _startDate = null;
      _endDate = null;
      _flowIntensity = null;
      _noteController.clear();
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final periodLogs = Provider.of<PeriodLogProvider>(context).logs;

    return Scaffold(
      appBar: AppBar(
        title: Text("Log Your Period"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Start Date", style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                title: Text(_startDate == null
                    ? 'Select start date'
                    : _formatDate(_startDate!)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              SizedBox(height: 10),
              Text("End Date", style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                title: Text(_endDate == null
                    ? 'Select end date'
                    : _formatDate(_endDate!)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              SizedBox(height: 10),
              Text("Flow Intensity", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _flowIntensity,
                hint: Text("Select intensity"),
                isExpanded: true,
                items: _intensityOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _flowIntensity = value;
                  });
                },
              ),
              SizedBox(height: 10),
              Text("Notes", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'Optional note...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _savePeriodLog(context),
                  child: Text("Save Log"),
                ),
              ),
              SizedBox(height: 30),
              Divider(),
              Text("Period History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              periodLogs.isEmpty
                  ? Text("No logs yet.")
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: periodLogs.length,
                // itemBuilder: (ctx, index) {
                //   final log = periodLogs[index];
                itemBuilder: (ctx, index) {
                  final log = periodLogs[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text("Start: ${_formatDate(log.startDate)}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("End: ${_formatDate(log.endDate)}"),
                          Text("Flow: ${log.flowIntensity}"),
                          if (log.note != null && log.note!.isNotEmpty)
                            Text("Note: ${log.note}"),
                          Text("Month: ${log.monthLabel}"),
                          Text(
                            log.cycleLength == null
                                ? "Cycle Length: Not available."
                                : "Cycle Length: ${log.cycleLength} days",
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
