import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LegalWebViewScreen extends StatefulWidget {
  final String title;
  final String htmlContent;

  const LegalWebViewScreen({
    super.key,
    required this.title,
    required this.htmlContent,
  });

  @override
  State<LegalWebViewScreen> createState() => _LegalWebViewScreenState();
}

class _LegalWebViewScreenState extends State<LegalWebViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF7F2E4))
      ..loadHtmlString(_wrapInHtmlTemplate(widget.htmlContent));
  }

  String _wrapInHtmlTemplate(String content) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            padding: 24px; 
            line-height: 1.6;
            color: #333;
            background-color: #F7F2E4;
            max-width: 800px;
            margin: 0 auto;
        }
        h1 { 
            color: #88844D; 
            font-size: 28px;
            margin-bottom: 16px;
        }
        h2 { 
            color: #BEC092; 
            font-size: 22px;
            margin: 24px 0 12px 0;
        }
        h3 {
            color: #88844D;
            font-size: 18px;
            margin: 20px 0 10px 0;
        }
        p { 
            margin-bottom: 16px;
            font-size: 16px;
        }
        ul, ol {
            margin-bottom: 16px;
            padding-left: 24px;
        }
        li {
            margin-bottom: 8px;
        }
        .section {
            background: white;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .last-updated {
            font-size: 14px;
            color: #666;
            text-align: center;
            margin-top: 32px;
            font-style: italic;
        }
    </style>
</head>
<body>
    <div class="section">
        $content
        <div class="last-updated">
            Last updated: ${DateTime.now().toString().split(' ')[0]}
        </div>
    </div>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2E4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF88844D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}