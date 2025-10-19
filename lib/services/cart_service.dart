import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:junk_and_gems/services/api_service.dart';

class CartService {
  static const String baseUrl = 'https://junk-and-gems-api.onrender.com';

  static Future<List<dynamic>> getCartItems(String userId) async {
    try {
      print('🛒 Getting cart items for user: $userId');
      
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('Please login to view your cart');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Cart response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Cart items loaded: ${data.length} items');
        return data;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ Authentication failed - clearing token');
        await ApiService.removeToken();
        throw Exception('Session expired. Please login again.');
      } else {
        print('❌ Failed to load cart items: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load cart items: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get cart items error: $e');
      throw Exception('Failed to load cart items: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  static Future<Map<String, dynamic>> addToCart(String userId, String productId, {int quantity = 1}) async {
    try {
      print('🛒 Adding to cart - User: $userId, Product: $productId, Quantity: $quantity');
      
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('Please login to add items to cart');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/$userId/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'product_id': int.parse(productId),
          'quantity': quantity,
        }),
      );

      print('📡 Add to cart response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        print('✅ Item added to cart successfully');
        return result;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ Authentication failed - clearing token');
        await ApiService.removeToken();
        throw Exception('Session expired. Please login again.');
      } else {
        print('❌ Failed to add to cart: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to add to cart: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Add to cart error: $e');
      throw Exception('Failed to add to cart: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  static Future<Map<String, dynamic>> updateCartItem(String userId, String itemId, int quantity) async {
    try {
      print('🛒 Updating cart item - User: $userId, Item: $itemId, Qty: $quantity');
      
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('Please login to update cart');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId/cart/$itemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'quantity': quantity,
        }),
      );

      print('📡 Update cart response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ Cart item updated successfully');
        return result;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ Authentication failed - clearing token');
        await ApiService.removeToken();
        throw Exception('Session expired. Please login again.');
      } else {
        print('❌ Failed to update cart: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to update cart: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Update cart error: $e');
      throw Exception('Failed to update cart: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  static Future<Map<String, dynamic>> removeFromCart(String userId, String itemId) async {
    try {
      print('🛒 Removing from cart - User: $userId, Item: $itemId');
      
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('Please login to remove items from cart');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/$userId/cart/$itemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Remove from cart response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ Item removed from cart successfully');
        return result;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ Authentication failed - clearing token');
        await ApiService.removeToken();
        throw Exception('Session expired. Please login again.');
      } else {
        print('❌ Failed to remove from cart: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to remove from cart: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Remove from cart error: $e');
      throw Exception('Failed to remove from cart: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  static Future<int> getUserGems(String userId) async {
    try {
      print('💎 Getting user gems for: $userId');
      
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('Please login to view your gems');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/gems'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Get gems response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final gems = data['available_gems'] ?? 0;
        print('✅ User gems loaded: $gems');
        return gems;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ Authentication failed - clearing token');
        await ApiService.removeToken();
        throw Exception('Session expired. Please login again.');
      } else {
        print('❌ Failed to load user gems: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load user gems: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get user gems error: $e');
      throw Exception('Failed to load user gems: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // Test connection without authentication
  static Future<void> testConnection() async {
    try {
      print('🔌 Testing connection to server...');
      await ApiService.testConnection();
    } catch (e) {
      print('❌ Cannot reach server: $e');
      rethrow;
    }
  }

  // Clear user's entire cart
  static Future<Map<String, dynamic>> clearCart(String userId) async {
    try {
      print('🛒 Clearing entire cart for user: $userId');
      
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('Please login to clear cart');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/$userId/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Clear cart response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ Cart cleared successfully');
        return result;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ Authentication failed - clearing token');
        await ApiService.removeToken();
        throw Exception('Session expired. Please login again.');
      } else {
        print('❌ Failed to clear cart: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to clear cart: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Clear cart error: $e');
      throw Exception('Failed to clear cart: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}