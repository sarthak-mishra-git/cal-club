import 'dart:convert';

class NetworkLogger {
  static void logRequest(String method, String url, Map<String, String> headers, String body) {
    print('🌐 === NETWORK REQUEST ===');
    print('📤 Method: $method');
    print('🔗 URL: $url');
    print('📋 Headers:');
    headers.forEach((key, value) {
      print('   $key: $value');
    });
    print('📦 Body: $body');
    print('');
    
    // Generate curl command
    final curlCommand = _generateCurlCommand(method, url, headers, body);
    print('💻 CURL Command:');
    print(curlCommand);
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
      print('   $prettyJson');
    } catch (e) {
      print('   $body');
    }
    print('');
  }

  static void logError(String method, String url, String error) {
    print('🌐 === NETWORK ERROR ===');
    print('❌ Method: $method');
    print('🔗 URL: $url');
    print('💥 Error: $error');
    print('');
  }

  static String _generateCurlCommand(String method, String url, Map<String, String> headers, String body) {
    final buffer = StringBuffer();
    buffer.write('curl --location');
    
    if (method != 'GET') {
      buffer.write(" --request $method");
    }
    
    buffer.write(" '$url'");
    
    headers.forEach((key, value) {
      buffer.write(" --header '$key: $value'");
    });
    
    if (body.isNotEmpty && method != 'GET') {
      buffer.write(" --data '$body'");
    }
    
    return buffer.toString();
  }
} 