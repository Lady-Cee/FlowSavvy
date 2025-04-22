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
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _submitQuery(context),
                  child: Text('Search'),
                ),
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
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "You asked:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(response.userQuery),
                        SizedBox(height: 10),
                        Text(
                          "Gemini says:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(response.answer),
                      ],
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


