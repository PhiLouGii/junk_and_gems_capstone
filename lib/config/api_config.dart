class ApiConfig {
  // 🚀 PRODUCTION URL - My Render backend
  static const String baseUrl = 'https://junk-and-gems-api.onrender.com';
  
  // API Endpoints
  static String get signup => '$baseUrl/signup';
  static String get login => '$baseUrl/login';
  static String get materials => '$baseUrl/materials';
  static String get products => '$baseUrl/api/products';
  static String get artisans => '$baseUrl/api/artisans';
  static String get contributors => '$baseUrl/api/contributors';
  
  // User endpoints
  static String userProfile(int userId) => '$baseUrl/api/users/$userId/profile';
  static String userConversations(int userId) => '$baseUrl/api/users/$userId/conversations';
  static String userCart(int userId) => '$baseUrl/api/users/$userId/cart';
  
  // Conversations
  static String conversationMessages(int conversationId) => '$baseUrl/api/conversations/$conversationId/messages';
  static String startConversation() => '$baseUrl/api/conversations/start';
  
  // Helper to build custom endpoint URLs
  static String endpoint(String path) => '$baseUrl$path';
}