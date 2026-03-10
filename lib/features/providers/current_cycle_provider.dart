import 'package:flutter/material.dart';
import 'period_log_provider.dart';
import 'profile_complete_provider.dart';

class CycleProvider with ChangeNotifier {
  DateTime? lastPeriod;
  int cycleLength = 28;
  int periodLength = 5;

  DateTime? nextPeriod;
  DateTime? ovulationDate;
  DateTime? fertileStart;
  DateTime? fertileEnd;

  void updateCycle(
      PeriodLogProvider logProvider,
      ProfileCompleteProvider profileProvider,
      ) {
    final profile = profileProvider.profile;

    if (profile == null) return;

    cycleLength = profile.cycleLength ?? 28;
    periodLength = profile.periodLength ?? 5;

    /// Use logged period if available
    if (logProvider.logs.isNotEmpty) {
      lastPeriod = logProvider.logs.first.startDate;
    } else {
      lastPeriod = profile.Date;
    }

    if (lastPeriod == null) return;

    nextPeriod = lastPeriod!.add(Duration(days: cycleLength));
    ovulationDate = nextPeriod!.subtract(const Duration(days: 14));

    fertileStart = ovulationDate!.subtract(const Duration(days: 5));
    fertileEnd = ovulationDate;

    notifyListeners();
  }
}