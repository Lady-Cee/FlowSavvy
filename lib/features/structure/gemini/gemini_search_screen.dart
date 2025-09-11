import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gemini_provider.dart';

class GeminiSearchScreen extends StatefulWidget {
  @override
  _GeminiSearchScreenState createState() => _GeminiSearchScreenState();
}

class _GeminiSearchScreenState extends State<GeminiSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  void _submitQuery(BuildContext context) {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      Provider.of<GeminiProvider>(context, listen: false).getGeminiResponse(query);
      _controller.clear();
      FocusScope.of(context).unfocus(); // Close keyboard
    }
  }

  @override
  Widget build(BuildContext context) {
    final geminiProvider = Provider.of<GeminiProvider>(context);
    final appColor = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Menstrual Hygiene Info'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: geminiProvider.clearResponses,
            tooltip: "Clear All",
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Ask a question...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _submitQuery(context),
                    maxLines: 3,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                    decoration: BoxDecoration(
                      color: appColor.primary,
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: IconButton(onPressed: () => _submitQuery(context), icon: Icon(Icons.search, color: appColor.secondary,))),
              ],
            ),
          ),
          geminiProvider.isLoading
              ? CircularProgressIndicator()
              : Expanded(
            child: geminiProvider.responses.isEmpty
                ? Center(child: Text('Ask a question to get started'))
                : ListView.builder(
              itemCount: geminiProvider.responses.length,
              itemBuilder: (ctx, i) {
                final response = geminiProvider.responses[i];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: appColor.primary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("You asked:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(response.userQuery, style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text("Gemini says:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(response.answer, style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        final provider = Provider.of<GeminiProvider>(context, listen: false);

                        // remove and keep a copy
                        final deletedResponse = provider.removeResponseAt(i);

                        // show snackbar with undo
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Record deleted"),
                            backgroundColor: appColor.primary,
                            action: SnackBarAction(
                              label: "Undo",
                              textColor: Colors.white,
                              onPressed: () {
                                // re-insert at the same position
                                provider.insertResponseAt(i, deletedResponse);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


