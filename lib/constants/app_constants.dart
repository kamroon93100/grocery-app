class AppConstants {
  // ================================
  // CHANGE THESE TO YOUR STORE INFO
  // ================================
  static const String storeName      = 'My Grocery Store';
  static const String storePhone     = '+1234567890';
  static const String storeWhatsApp  = '1234567890'; // without + sign
  static const String storeAddress   = '123 Main Street, City';
  static const String storeEmail     = 'store@mygrocery.com';
  static const String currency       = '\$';
  static const String version        = '2.0.0';

  // Storage Keys
  static const String keyToken        = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId       = 'user_id';
  static const String keyUserName     = 'user_name';
  static const String keyUserEmail    = 'user_email';
  static const String keyUserPhone    = 'user_phone';
  static const String keyUserRole     = 'user_role';
  static const String keyIsLogged     = 'is_logged_in';
  static const String keyWallet       = 'wallet_balance';

  // Categories
  static const List<String> categories = [
    'All','Vegetables','Fruits','Dairy',
    'Meat','Grains','Bakery','Beverages','Snacks',
  ];

  // Order Statuses
  static const List<String> orderStatuses = [
    'pending','confirmed','preparing','ready',
    'picked_up','out_for_delivery','delivered','cancelled',
  ];

  // Free delivery above this amount
  static const double freeDeliveryAbove = 50.0;

  // Tax percentage
  static const double taxPercent = 5.0;
}
