import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:junk_and_gems/services/api_service.dart';

class CartService {
  static Future<List<dynamic>> getCartItems(String userId) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3003/api/users/$userId/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load cart items: ${response.body}');
      }
    } catch (e) {
      print('Get cart items error: $e');
      throw Exception('Failed to load cart items');
    }
  }

  static Future<Map<String, dynamic>> addToCart(String userId, String productId, {int quantity = 1}) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.post(
        Uri.parse('http://localhost:3003/api/users/$userId/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to add to cart: ${response.body}');
      }
    } catch (e) {
      print('Add to cart error: $e');
      throw Exception('Failed to add to cart');
    }
  }

  static Future<Map<String, dynamic>> updateCartItem(String userId, String itemId, int quantity) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('http://localhost:3003/api/users/$userId/cart/$itemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update cart: ${response.body}');
      }
    } catch (e) {
      print('Update cart error: $e');
      throw Exception('Failed to update cart');
    }
  }

  static Future<Map<String, dynamic>> removeFromCart(String userId, String itemId) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.delete(
        Uri.parse('http://localhost:3003/api/users/$userId/cart/$itemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to remove from cart: ${response.body}');
      }
    } catch (e) {
      print('Remove from cart error: $e');
      throw Exception('Failed to remove from cart');
    }
  }

  static Future<int> getUserGems(String userId) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:3003/api/users/$userId/gems'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['available_gems'] ?? 0;
      } else {
        throw Exception('Failed to load user gems: ${response.body}');
      }
    } catch (e) {
      print('Get user gems error: $e');
      throw Exception('Failed to load user gems');
    }
  }
}