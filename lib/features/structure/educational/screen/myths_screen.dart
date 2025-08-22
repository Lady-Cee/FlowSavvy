import 'package:flow_savvy/features/models/myths_and_facts_model.dart';
import 'package:flow_savvy/features/utils/app_strings.dart';
import 'package:flow_savvy/features/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

import '../../../data/myths_and_facts_data.dart';
import '../../../utils/constants.dart';

class MythsScreen extends StatefulWidget {
  @override
  State<MythsScreen> createState() => _MythsScreenState();
}

class _MythsScreenState extends State<MythsScreen> {
  // Track visibility for each fact individually
  late List<bool> factVisibility;
  late List<MythsAndFactsModel> filteredList;
  AppStrings appStrings = AppStrings();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    factVisibility = List.generate(mythsAndFacts.length, (_) => false);
    filteredList = List.from(mythsAndFacts); // start with full list
  }

  void toggleFact(int index) {
    setState(() {
      factVisibility[index] = !factVisibility[index];
    });
  }

  void filterMyths(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredList = List.from(mythsAndFacts);
      } else {
        filteredList = mythsAndFacts
            .where((item) =>
        item.myth.toLowerCase().contains(query.toLowerCase()) ||
            item.fact.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      // reset visibility list so indices stay consistent
      factVisibility = List.generate(filteredList.length, (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.chevron_left),
        ),
        title: Text(
          appStrings.mythsAndFactsTitleText,
          style: AppTextStyles.mediumTextSemiBold(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: AppConstants.scaffoldPadding,
        child: Column(
          children: [
            Text(
              'Ever wondered which period beliefs are fact and myths? '
                  'Test your knowledge and discover the truth!',
              style: AppTextStyles.semiBold(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // 🔍 Search bar
            TextField(
              controller: searchController,
              onChanged: filterMyths,
              decoration: InputDecoration(
                hintText: "Search myths...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 📋 Filtered list
            Expanded(
              child: ListView.builder(
                itemCount: filteredList.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, i) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Myth: ${filteredList[i].myth}"),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(appStrings.mythsAndFactsViewFactText),
                            IconButton(
                              onPressed: () => toggleFact(i),
                              icon: Icon(
                                factVisibility[i]
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                        if (factVisibility[i])
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text("Fact: ${filteredList[i].fact}"),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
