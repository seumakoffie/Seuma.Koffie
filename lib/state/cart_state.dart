// lib/state/cart_state.dart
import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';

class CartItem {
  final String id;
  final String menuItemId;
  final String name;
  final String category;
  final bool isHot;
  final bool extraShot;
  final int unitPrice;
  int quantity;
  final String iconEmoji;

  CartItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.category,
    required this.isHot,
    required this.extraShot,
    required this.unitPrice,
    this.quantity = 1,
    required this.iconEmoji,
  });

  String? get imagePath => kMenuImageMap[name] ?? kMenuImageMap[menuItemId];
  bool get hasImage => imagePath != null;

  int get totalPrice => unitPrice * quantity;
}

class CartManager extends ChangeNotifier {
  static final CartManager instance = CartManager._();
  CartManager._();

  final List<CartItem> _items = [];
  String? _appliedVoucher;
  int _discount = 0;

  List<CartItem> get items => List.unmodifiable(_items);
  String? get appliedVoucher => _appliedVoucher;
  int get discount => _discount;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  int get grandTotal {
    final total = subtotal - _discount;
    return total > 0 ? total : 0;
  }

  void addItem({
    required String menuItemId,
    required String name,
    required String category,
    required bool isHot,
    required bool extraShot,
    required int unitPrice,
    required int quantity,
    required String iconEmoji,
  }) {
    final itemKey = '$menuItemId-${isHot ? "hot" : "ice"}-${extraShot ? "shot" : "none"}';
    final existingIndex = _items.indexWhere((i) => i.id == itemKey);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          id: itemKey,
          menuItemId: menuItemId,
          name: extraShot ? '$name (+Extra Shot)' : name,
          category: category,
          isHot: isHot,
          extraShot: extraShot,
          unitPrice: unitPrice,
          quantity: quantity,
          iconEmoji: iconEmoji,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(String id, int delta) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index >= 0) {
      final newQty = _items[index].quantity + delta;
      if (newQty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQty;
      }
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  bool applyVoucher(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'SEUMAFIRST') {
      _appliedVoucher = 'SEUMAFIRST';
      _discount = 15000;
      notifyListeners();
      return true;
    } else if (clean == 'JUMATBERKAH') {
      _appliedVoucher = 'JUMATBERKAH';
      _discount = 10000;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeVoucher() {
    _appliedVoucher = null;
    _discount = 0;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _appliedVoucher = null;
    _discount = 0;
    notifyListeners();
  }
}

String formatRupiah(int number) {
  final str = number.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(str[i]);
  }
  return 'Rp ${buffer.toString()}';
}

