// providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import 'package:junk_and_gems/services/api_service.dart';

class CartItem {
  final int? id;
  final int productId;
  final String title;
  final double price;
  final String? imageUrl;
  final String? description;
  int quantity;

  CartItem({
    this.id,
    required this.productId,
    required this.title,
    required this.price,
    this.imageUrl,
    this.description,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['product_id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
      description: json['description'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'title': title,
      'price': price,
      'image_url': imageUrl,
      'description': description,
      'quantity': quantity,
    };
  }
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get subtotal {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  Future<void> fetchCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService().get('/api/cart');
      final cartData = response['items'] as List? ?? [];
      
      _items = cartData.map((item) => CartItem.fromJson(item)).toList();
    } catch (error) {
      _error = 'Failed to load cart: $error';
      print('Error fetching cart: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    _error = null;
    notifyListeners();

    try {
      await ApiService().post('/api/cart/items', {
        'productId': productId,
        'quantity': quantity,
      });
      
      // Refresh cart after adding
      await fetchCart();
    } catch (error) {
      _error = 'Failed to add item to cart: $error';
      print('Error adding to cart: $error');
      throw error;
    }
  }

  Future<void> updateCartItemQuantity(int itemId, int newQuantity) async {
    _error = null;
    notifyListeners();

    try {
      await ApiService().put('/api/cart/items/$itemId', {
        'quantity': newQuantity,
      });
      
      // Update local state immediately for better UX
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _items[index].quantity = newQuantity;
        notifyListeners();
      }
    } catch (error) {
      _error = 'Failed to update quantity: $error';
      print('Error updating cart item: $error');
      throw error;
    }
  }

  Future<void> removeFromCart(int itemId) async {
    _error = null;
    notifyListeners();

    try {
      await ApiService().delete('/api/cart/items/$itemId');
      
      // Update local state immediately
      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (error) {
      _error = 'Failed to remove item: $error';
      print('Error removing from cart: $error');
      throw error;
    }
  }

  Future<void> clearCart() async {
    _error = null;
    notifyListeners();

    try {
      await ApiService().delete('/api/cart');
      _items.clear();
      notifyListeners();
    } catch (error) {
      _error = 'Failed to clear cart: $error';
      print('Error clearing cart: $error');
      throw error;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}