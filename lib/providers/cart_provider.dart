// providers/cart_provider.dart
import 'package:flutter/foundation.dart';

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

  // Convert to Map for CheckoutScreen compatibility
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'image': imageUrl ?? 'assets/images/placeholder.jpg',
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

  // Add this method - no parameters needed
  Future<void> fetchCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(Duration(seconds: 1));
      
      // For testing - add some dummy items
      _items = [
        CartItem(
          id: 1,
          productId: 1,
          title: 'Sta-Soft Lamp',
          price: 400,
          imageUrl: 'assets/images/featured3.jpg',
          quantity: 1,
        ),
        CartItem(
          id: 2,
          productId: 2,
          title: 'Can Tab Lamp',
          price: 650,
          imageUrl: 'assets/images/featured6.jpg',
          quantity: 1,
        ),
        CartItem(
          id: 3,
          productId: 3,
          title: 'Denim Patchwork Bag',
          price: 330,
          imageUrl: 'assets/images/upcycled1.jpg',
          quantity: 2,
        ),
      ];
    } catch (error) {
      _error = 'Failed to load cart: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCartItemQuantity(int itemId, int newQuantity) async {
    _error = null;
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(int itemId) async {
    _error = null;
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}