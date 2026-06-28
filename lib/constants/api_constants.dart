class ApiConstants {
  // ========================================
  // 🌐 PRODUCTION URL - Railway Cloud
  // ========================================
  static const String baseUrl   = 'https://grocery-backend-production-ded1.up.railway.app/api/v1';
  static const String socketUrl = 'https://grocery-backend-production-ded1.up.railway.app';

  // Auth
  static const String login           = '/auth/login';
  static const String register        = '/auth/register';
  static const String logout          = '/auth/logout';
  static const String me              = '/auth/me';
  static const String refreshToken    = '/auth/refresh';
  static const String changePassword  = '/auth/change-password';
  static const String updateProfile   = '/auth/update-profile';
  static const String sendOTP         = '/auth/send-otp';
  static const String verifyOTP       = '/auth/verify-otp';
  static const String resendOTP       = '/auth/resend-otp';

  static const String updateFcmToken  = '/auth/update-fcm-token';

  // Categories
  static const String categories      = '/categories';

  // Products
  static const String products        = '/products';
  static const String featured        = '/products/featured';
  static const String search          = '/products/search';

  // Orders
  static const String orders          = '/orders';
  static const String myOrders        = '/orders/my-orders';

  // Payments
  static const String createIntent    = '/payments/create-intent';
  static const String confirmPayment  = '/payments/confirm';
  static const String walletBalance   = '/payments/wallet-balance';
  static const String addWallet       = '/payments/add-wallet';

  // Coupons
  static const String validateCoupon  = '/coupons/validate';

  // Notifications
  static const String notifications   = '/notifications';
  static const String markAllRead     = '/notifications/read-all';

  // Analytics (Admin)
  static const String dashboard       = '/analytics/dashboard';
  static const String salesAnalytics  = '/analytics/sales';
  static const String topProducts     = '/analytics/top-products';
  static const String inventory       = '/analytics/inventory';

  // Users (Admin)
  static const String users           = '/users';
  static const String addresses       = '/users/addresses';

  // Delivery
  static const String availableOrders = '/delivery/available-orders';
  static const String acceptOrder     = '/delivery/accept';
  static const String myDeliveries    = '/delivery/my-deliveries';
  static const String earnings        = '/delivery/earnings';

  // Google Auth
  static const String googleLogin     = '/auth/google';

  // Razorpay
  static const String razorpayCreateOrder = '/payments/razorpay/create-order';
  static const String razorpayVerify  = '/payments/razorpay/verify';
  static const String razorpayWalletTopup = '/payments/razorpay/wallet-topup';

  // Maps
  static const String geocode         = '/maps/geocode';
  static const String reverseGeocode  = '/maps/reverse-geocode';
  static const String distanceMatrix  = '/maps/distance-matrix';
  static const String placeAutocomplete = '/maps/places/autocomplete';
  static const String placeDetails    = '/maps/places/details';

  // Wishlist
  static const String wishlist        = '/wishlist';

  // Timeouts
  static const int connectTimeout     = 30;
  static const int receiveTimeout     = 30;
}

