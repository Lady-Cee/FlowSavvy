import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/period_log.dart';
import '../../../../providers/period_log_provider.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../widgets/long_custom_button.dart';

// import '../../../models/period_log.dart';
// import '../../../providers/period_log_provider.dart';
// import '../../../utils/app_text_styles.dart';
// import '../../../widgets/long_custom_button.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    await Provider.of<PeriodLogProvider>(context, listen: false).loadLogs();
    setState(() => _isLoading = false);
  }

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
        SnackBar(
          content: Text('Please complete all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('End date cannot be before start date'),
          backgroundColor: Colors.red,
        ),
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
    return DateFormat('MMM d, yyyy').format(date);
  }

  Widget _flowChip(String intensity) {
    Color color;
    switch (intensity) {
      case 'Light':
        color = Colors.green;
        break;
      case 'Moderate':
        color = Colors.orange;
        break;
      case 'Heavy':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(intensity, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
      side: BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodLogs = Provider.of<PeriodLogProvider>(context).logs;
    final appColor = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Track Your Period",
              style: AppTextStyles.largeTextSemiBold(context)),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Start Date
              Text("Start Date",
                  style: AppTextStyles.smallTextSemiBold(context)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _startDate == null
                            ? 'Select start date'
                            : _formatDate(_startDate!),
                        style: TextStyle(
                          color: _startDate == null
                              ? Colors.grey
                              : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: Colors.pink),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // End Date
              Text("End Date",
                  style: AppTextStyles.smallTextSemiBold(context)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context, false),
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _endDate == null
                            ? 'Select end date'
                            : _formatDate(_endDate!),
                        style: TextStyle(
                          color: _endDate == null
                              ? Colors.grey
                              : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: Colors.pink),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              Text("Flow Intensity",
                  style: AppTextStyles.mediumTextSemiBold(context)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _intensityOptions.map((option) {
                  return Row(
                    children: [
                      Radio<String>(
                        value: option,
                        groupValue: _flowIntensity,
                        activeColor: Colors.pink,
                        onChanged: (value) {
                          setState(() {
                            _flowIntensity = value;
                          });
                        },
                      ),
                      Text(option),
                    ],
                  );
                }).toList(),
              ),

              SizedBox(height: 20),
              Text("Notes (Optional)",
                  style: AppTextStyles.smallTextRegular(context)),
              SizedBox(height: 20),
              TextField(
                controller: _noteController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'How do you feel today?',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: Colors.pink, width: 2),
                  ),
                ),
              ),

              SizedBox(height: 20),
              Center(
                child: LongCustomButton(
                  onTap: () => _savePeriodLog(context),
                  title: 'Save Log',
                ),
              ),

              SizedBox(height: 30),
              Divider(),
              Text("Period History",
                  style: AppTextStyles.mediumTextSemiBold(context)),
              SizedBox(height: 10),

              periodLogs.isEmpty
                  ? Text("No logs yet.")
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: periodLogs.length,
                itemBuilder: (ctx, index) {
                  final log = periodLogs[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: appColor.primary.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(
                          "Start: ${_formatDate(log.startDate)}"),
                      subtitle: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text("End: ${_formatDate(log.endDate)}"),
                          SizedBox(height: 4),
                          _flowChip(log.flowIntensity),
                          if (log.note != null &&
                              log.note!.isNotEmpty)
                            Text("Note: ${log.note}"),
                          Text("Month: ${log.monthLabel}"),
                          Text(
                            log.cycleLength == null
                                ? "Cycle Length: Not available."
                                : "Cycle Length: ${log.cycleLength} days",
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          final provider =
                          Provider.of<PeriodLogProvider>(
                              context,
                              listen: false);
                          final deletedLog = periodLogs[index];
                          provider.removeLog(index);

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text("Log deleted"),
                              backgroundColor: appColor.primary,
                              action: SnackBarAction(
                                label: "Undo",
                                textColor: Colors.white,
                                onPressed: () {
                                  provider.addLog(deletedLog);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
