import 'dart:convert';

class NetworkLogger {
  // Maximum characters per print line to avoid truncation
  static const int _maxChunkSize = 1000;

  static void logRequest(String method, String url, Map<String, String> headers, String body) {
    print('🌐 === NETWORK REQUEST ===');
    print('📤 Method: $method');
    print('🔗 URL: $url');
    print('📋 Headers:');
    headers.forEach((key, value) {
      print('   $key: $value');
    });
    print('📦 Body:');
    _printInChunks(body, indent: '   ');
    print('');
    
    // Generate curl command
    final curlCommand = _generateCurlCommand(method, url, headers, body);
    print('💻 CURL Command:');
    _printInChunks(curlCommand);
    print('');
  }

  static void logResponse(String method, String url, int statusCode, String body) {
    print('🌐 === NETWORK RESPONSE ===');
    print('📥 Method: $method');
    print('🔗 URL: $url');
    print('📊 Status Code: $statusCode');
    print('📦 Response Size: ${body.length} characters');
    print('📄 Response Body:');
    
    try {
      final jsonResponse = json.decode(body);
      final prettyJson = JsonEncoder.withIndent('   ').convert(jsonResponse);
      _printInChunks(prettyJson, indent: '   ');
    } catch (e) {
      _printInChunks(body, indent: '   ');
    }
    print('');
  }

  static void logError(String method, String url, String error) {
    print('🌐 === NETWORK ERROR ===');
    print('❌ Method: $method');
    print('🔗 URL: $url');
    print('💥 Error:');
    _printInChunks(error);
    print('');
  }

  /// Print long strings in chunks to avoid truncation
  static void _printInChunks(String content, {String indent = ''}) {
    if (content.length <= _maxChunkSize) {
      print('$indent$content');
      return;
    }

    // Split into chunks
    for (int i = 0; i < content.length; i += _maxChunkSize) {
      final end = (i + _maxChunkSize < content.length) ? i + _maxChunkSize : content.length;
      final chunk = content.substring(i, end);
      print('$indent$chunk');
    }
  }

  static String _generateCurlCommand(String method, String url, Map<String, String> headers, String body) {
    final buffer = StringBuffer();
    buffer.write('curl --location');
    
    if (method != 'GET') {
      buffer.write(" --request $method");
    }
    
    buffer.write(" '$url'");
    
    headers.forEach((key, value) {
      // Escape single quotes in header values
      final escapedValue = value.replaceAll("'", "'\\''");
      buffer.write(" --header '$key: $escapedValue'");
    });
    
    if (body.isNotEmpty && method != 'GET') {
      // Escape single quotes in body
      final escapedBody = body.replaceAll("'", "'\\''");
      // For very long bodies, use --data-raw with file or show truncated version
      if (body.length > 5000) {
        buffer.write(" --data-raw '${escapedBody.substring(0, 5000)}... (truncated, full body is ${body.length} chars)'");
      } else {
        buffer.write(" --data-raw '$escapedBody'");
      }
    }
    
    return buffer.toString();
  }
} 