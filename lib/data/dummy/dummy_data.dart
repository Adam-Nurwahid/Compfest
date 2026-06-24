import '../models/models.dart';

// List dummy users
final List<User> dummyUsers = [
  User(
    id: 'user_admin',
    name: 'Administrator',
    email: 'admin@seapedia.com',
    username: 'admin',
    password: 'password123',
    roles: ['Admin', 'Buyer', 'Seller', 'Driver'],
    activeRole: 'Admin',
  ),
  User(
    id: 'user_a',
    name: 'Andi Kusuma',
    email: 'andi@seapedia.com',
    username: 'andi',
    password: 'password123',
    roles: ['Buyer', 'Seller'],
    activeRole: 'Buyer',
  ),
  User(
    id: 'user_b',
    name: 'Budi Santoso',
    email: 'budi@seapedia.com',
    username: 'budi',
    password: 'password123',
    roles: ['Seller'],
    activeRole: 'Seller',
  ),
  User(
    id: 'user_c',
    name: 'Chandra Wijaya',
    email: 'chandra@seapedia.com',
    username: 'chandra',
    password: 'password123',
    roles: ['Buyer', 'Seller', 'Driver'], // Updated to include Buyer and Driver
    activeRole: 'Seller',
  ),
  User(
    id: 'user_d',
    name: 'Dedi Kurniawan',
    email: 'dedi@seapedia.com',
    username: 'dedi',
    password: 'password123',
    roles: ['Driver'],
    activeRole: 'Driver',
  ),
];

// List dummy store
final List<Store> dummyStores = [
  Store(
    id: 'store_1',
    ownerId: 'user_a',
    name: 'Oceanic Diving Gear',
    location: 'Jakarta Utara',
    logoUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=100&auto=format&fit=crop',
    rating: 4.8,
    description: 'Toko peralatan diving terlengkap, menyediakan wet suit, fins, goggle, hingga dive computer berkualitas internasional.',
  ),
  Store(
    id: 'store_2',
    ownerId: 'user_c',
    name: 'North Wind Sailing',
    location: 'Surabaya',
    logoUrl: 'https://images.unsplash.com/photo-1505244208262-19137ac24634?w=100&auto=format&fit=crop',
    rating: 4.9,
    description: 'Menyediakan segala kebutuhan berlayar dan olahraga air. Produk kami diimpor dari produsen terbaik di dunia.',
  ),
  Store(
    id: 'store_3',
    ownerId: 'user_b',
    name: 'Bluefin Elite Fishing',
    location: 'Bali',
    logoUrl: 'https://images.unsplash.com/photo-1517462964-21fdcec3f25b?w=100&auto=format&fit=crop',
    rating: 4.7,
    description: 'Pusat alat pancing premium. Reel titanium, joran serat karbon, dan umpan buatan tangan untuk hasil tangkapan maksimal.',
  ),
];

// List dummy products (4-6 per store)
final List<Product> dummyProducts = [
  // Store 1: Oceanic Diving Gear
  Product(
    id: 'prod_1_1',
    storeId: 'store_1',
    name: 'AquaPro Smart Dive Computer',
    price: 6500000,
    stock: 12,
    description: 'Komputer selam canggih dengan layar AMOLED berwarna, kompas 3-axis terintegrasi, pemantau tekanan tabung nirkabel, dan logbook otomatis hingga 200 penyelaman.',
    imageUrl: 'https://images.unsplash.com/photo-1530541930197-ff16ac917b0e?w=500&auto=format&fit=crop',
    category: 'Diving',
    rating: 4.8,
    reviewCount: 34,
  ),
  Product(
    id: 'prod_1_2',
    storeId: 'store_1',
    name: 'Premium Titanium Diving Knife',
    price: 850000,
    stock: 25,
    description: 'Pisau selam berbahan titanium murni, sangat tajam dan 100% tahan karat. Dilengkapi dengan sheath pengunci ganda dan strap kaki yang nyaman.',
    imageUrl: 'https://images.unsplash.com/photo-1582201942988-13e60e4556ee?w=500&auto=format&fit=crop',
    category: 'Diving',
    rating: 4.7,
    reviewCount: 18,
  ),
  Product(
    id: 'prod_1_3',
    storeId: 'store_1',
    name: 'Super-Stretch Neoprene Wetsuit 3mm',
    price: 1850000,
    stock: 8,
    description: 'Wetsuit 3mm super lentur untuk fleksibilitas maksimal di bawah air. Dilengkapi dengan double sealing di pergelangan tangan dan kaki untuk mengurangi sirkulasi air dingin.',
    imageUrl: 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=500&auto=format&fit=crop',
    category: 'Diving',
    rating: 4.9,
    reviewCount: 42,
  ),
  Product(
    id: 'prod_1_4',
    storeId: 'store_1',
    name: 'Professional Panoramic Scuba Mask',
    price: 750000,
    stock: 30,
    description: 'Masker scuba kaca tempered dengan sudut pandang panorama lebar 180 derajat. Menggunakan bahan silikon cair kualitas makanan untuk kenyamanan ketat tanpa bocor.',
    imageUrl: 'https://images.unsplash.com/photo-1607569762195-e8524d56d4db?w=500&auto=format&fit=crop',
    category: 'Diving',
    rating: 4.6,
    reviewCount: 29,
  ),
  Product(
    id: 'prod_1_5',
    storeId: 'store_1',
    name: 'High-Thrust Split Diving Fins',
    price: 1200000,
    stock: 15,
    description: 'Fins model split untuk kayuhan yang efisien dengan tenaga minimal. Mengurangi kram otot kaki dan meningkatkan daya dorong saat melawan arus bawah laut.',
    imageUrl: 'https://images.unsplash.com/photo-1518152006812-edab29b069ac?w=500&auto=format&fit=crop',
    category: 'Diving',
    rating: 4.8,
    reviewCount: 15,
  ),

  // Store 2: North Wind Sailing
  Product(
    id: 'prod_2_1',
    storeId: 'store_2',
    name: 'Carbon Fiber Yachting Helm Wheel',
    price: 14500000,
    stock: 3,
    description: 'Kemudi kapal yacht serat karbon ultra-ringan dengan diameter 80cm. Memberikan kontrol presisi tinggi dan estetika kemewahan modern pada dek kapal Anda.',
    imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=500&auto=format&fit=crop',
    category: 'Sailing',
    rating: 5.0,
    reviewCount: 7,
  ),
  Product(
    id: 'prod_2_2',
    storeId: 'store_2',
    name: 'Sailing Wind Speed & Direction Sensor',
    price: 4200000,
    stock: 9,
    description: 'Anemometer nirkabel tenaga surya untuk kapal layar. Mengirimkan data kecepatan angin mendetil dan arah angin secara real-time ke display dek atau smartphone Anda.',
    imageUrl: 'https://images.unsplash.com/photo-1513553404607-988bf2703777?w=500&auto=format&fit=crop',
    category: 'Sailing',
    rating: 4.7,
    reviewCount: 12,
  ),
  Product(
    id: 'prod_2_3',
    storeId: 'store_2',
    name: 'Pro-Grid Sailing Gloves (Pair)',
    price: 320000,
    stock: 45,
    description: 'Sarung tangan berlayar dengan proteksi kevlar pada telapak tangan. Desain 3-cut finger untuk memudahkan manipulasi tali simpul dan pengoperasian GPS.',
    imageUrl: 'https://images.unsplash.com/photo-1516259762381-22954d7d3ad2?w=500&auto=format&fit=crop',
    category: 'Sailing',
    rating: 4.8,
    reviewCount: 65,
  ),
  Product(
    id: 'prod_2_4',
    storeId: 'store_2',
    name: 'Marine Waterproof Deck Bag 40L',
    price: 550000,
    stock: 20,
    description: 'Dry bag duffel tahan air 100% berkapasitas 40 liter. Terbuat dari terpal PVC 500D tebal dengan sistem gulung kedap air dan strap ransel yang tebal.',
    imageUrl: 'https://images.unsplash.com/photo-1622560480605-d83c853bc5c3?w=500&auto=format&fit=crop',
    category: 'Sailing',
    rating: 4.6,
    reviewCount: 30,
  ),

  // Store 3: Bluefin Elite Fishing
  Product(
    id: 'prod_3_1',
    storeId: 'store_3',
    name: 'Titanium Series Reef Master Reel',
    price: 9500000,
    stock: 5,
    description: 'Reel pancing premium berbahan titanium alloy dengan 12+1 stainless steel ball bearings. Sangat kuat untuk memancing teknik popping dan jigging monster laut dalam.',
    imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=500&auto=format&fit=crop',
    category: 'Fishing',
    rating: 4.9,
    reviewCount: 22,
  ),
  Product(
    id: 'prod_3_2',
    storeId: 'store_3',
    name: 'Graphite Saltwater Jigging Rod',
    price: 3400000,
    stock: 10,
    description: 'Joran pancing laut berbahan grafit karbon komposit dengan pemandu cincin Fuji Alconite. Lentur namun memiliki daya angkat tinggi untuk ikan kelas berat.',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&auto=format&fit=crop',
    category: 'Fishing',
    rating: 4.8,
    reviewCount: 16,
  ),
  Product(
    id: 'prod_3_3',
    storeId: 'store_3',
    name: 'Multi-Jointed Realistic Swim Lure Set',
    price: 180000,
    stock: 50,
    description: 'Set umpan buatan menyerupai ikan hidup dengan 8 segmen tubuh bergerak. Aksi renang di air sangat realistis untuk menarik predator seperti GT, Tuna, dan Kakap.',
    imageUrl: 'https://images.unsplash.com/photo-1611095790444-1dfa4825a5a2?w=500&auto=format&fit=crop',
    category: 'Fishing',
    rating: 4.5,
    reviewCount: 54,
  ),
  Product(
    id: 'prod_3_4',
    storeId: 'store_3',
    name: 'Sonar Fish Finder Wireless Portable',
    price: 2400000,
    stock: 14,
    description: 'Detektor ikan berbasis sonar nirkabel yang dapat dihubungkan ke smartphone. Mampu memetakan kontur dasar laut, suhu air, dan posisi gerombolan ikan hingga kedalaman 45m.',
    imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=500&auto=format&fit=crop',
    category: 'Fishing',
    rating: 4.7,
    reviewCount: 31,
  ),
];

// App Testimonials
final List<AppReview> dummyAppReviews = [
  AppReview(
    id: 'rev_1',
    name: 'Budi Santoso',
    rating: 5.0,
    comment: 'Sangat membantu mencari gear menyelam premium. Transaksi mudah, dan seller di SEAPEDIA sangat responsif serta terpercaya!',
    date: DateTime.now().subtract(const Duration(days: 3)),
  ),
  AppReview(
    id: 'rev_2',
    name: 'Siti Rahma',
    rating: 4.5,
    comment: 'Pilihan joran dan reel pancing lengkap sekali. Desain aplikasinya modern dan lancar saat digunakan di HP Android saya.',
    date: DateTime.now().subtract(const Duration(days: 7)),
  ),
  AppReview(
    id: 'rev_3',
    name: 'Captain Wijaya',
    rating: 5.0,
    comment: 'Saya membeli anemometer angin kapal layar di sini. Barangnya 100% original. Aturan cart per store sangat rapi agar pengiriman tidak membingungkan.',
    date: DateTime.now().subtract(const Duration(days: 10)),
  ),
  AppReview(
    id: 'rev_4',
    name: 'Dian Pratama',
    rating: 4.0,
    comment: 'Aplikasi belanja kelautan terbaik! Flow checkout sangat transparan dengan breakdown PPN 12% dan diskon voucher yang jelas.',
    date: DateTime.now().subtract(const Duration(days: 12)),
  ),
];

// Dummy Vouchers (Kode, nominal/persen diskon, expiry date, sisa kuota)
final List<Voucher> dummyVouchers = [
  Voucher(
    code: 'SEAVOUCH100',
    discountAmount: 100000,
    isPercentage: false,
    expiryDate: DateTime.now().add(const Duration(days: 30)),
    quotaRemaining: 15,
  ),
  Voucher(
    code: 'OCEANIC15',
    discountAmount: 15, // 15%
    isPercentage: true,
    expiryDate: DateTime.now().add(const Duration(days: 15)),
    quotaRemaining: 2,
  ),
  Voucher(
    code: 'EXPIREDVOUCH',
    discountAmount: 50000,
    isPercentage: false,
    expiryDate: DateTime.now().subtract(const Duration(days: 2)),
    quotaRemaining: 10,
  ),
  Voucher(
    code: 'HABISVOUCH',
    discountAmount: 75000,
    isPercentage: false,
    expiryDate: DateTime.now().add(const Duration(days: 5)),
    quotaRemaining: 0,
  ),
];

// Dummy Promos (Kode, nominal/persen diskon, expiry date)
final List<Promo> dummyPromos = [
  Promo(
    code: 'MEGADEAL50',
    discountAmount: 50000,
    isPercentage: false,
    expiryDate: DateTime.now().add(const Duration(days: 45)),
  ),
  Promo(
    code: 'SAILSAVE10',
    discountAmount: 10, // 10%
    isPercentage: true,
    expiryDate: DateTime.now().add(const Duration(days: 20)),
  ),
  Promo(
    code: 'EXPIREDPROMO',
    discountAmount: 20000,
    isPercentage: false,
    expiryDate: DateTime.now().subtract(const Duration(days: 5)),
  ),
];

// Dummy addresses
final List<Address> dummyAddresses = [
  Address(
    id: 'addr_1',
    receiverName: 'Andi Kusuma',
    phoneNumber: '081234567890',
    fullAddress: 'Perumahan Marina Indah Blok A1 No. 5, Jl. Pantai Indah Kapuk, Penjaringan, Jakarta Utara, DKI Jakarta, 14470',
    isDefault: true,
  ),
  Address(
    id: 'addr_2',
    receiverName: 'Andi Kusuma (Kantor)',
    phoneNumber: '081234567890',
    fullAddress: 'Gedung Kelautan Nusantara Lt. 12, Jl. Sudirman Kav 21, Karet Semanggi, Jakarta Selatan, DKI Jakarta, 12930',
    isDefault: false,
  ),
];

// Pre-populated orders (5-6 orders representing all statuses)
final List<Order> dummyOrders = [
  Order(
    id: 'ORD-20260620-001',
    storeName: 'Oceanic Diving Gear',
    storeId: 'store_1',
    items: [
      OrderItem(
        productName: 'Professional Panoramic Scuba Mask',
        price: 750000,
        quantity: 2,
        imageUrl: 'https://images.unsplash.com/photo-1607569762195-e8524d56d4db?w=500&auto=format&fit=crop',
      ),
      OrderItem(
        productName: 'High-Thrust Split Diving Fins',
        price: 1200000,
        quantity: 1,
        imageUrl: 'https://images.unsplash.com/photo-1518152006812-edab29b069ac?w=500&auto=format&fit=crop',
      ),
    ],
    address: dummyAddresses[0],
    deliveryMethod: 'Regular',
    deliveryFee: 5000,
    voucherCode: 'SEAVOUCH100',
    discountAmount: 100000,
    ppnAmount: 312600, // 12% of (2,700,000 - 100,000 + 5,000) = 0.12 * 2,605,000 = 312,600
    finalTotal: 2917600, // 2,605,000 + 312,600 = 2,917,600
    status: 'Pesanan Selesai',
    statusTimeline: [
      OrderMilestone(status: 'Sedang Dikemas', timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 5)), description: 'Pesanan sedang disiapkan oleh penjual.'),
      OrderMilestone(status: 'Menunggu Pengirim', timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 2)), description: 'Menunggu kurir menjemput barang.'),
      OrderMilestone(status: 'Sedang Dikirim', timestamp: DateTime.now().subtract(const Duration(days: 3)), description: 'Kurir sedang dalam perjalanan ke alamat tujuan.'),
      OrderMilestone(status: 'Pesanan Selesai', timestamp: DateTime.now().subtract(const Duration(days: 2)), description: 'Pesanan telah diterima oleh pembeli.'),
    ],
    assignedDriverId: 'user_d',
    pickupAddress: 'Oceanic Diving Gear - Jakarta Utara',
    dropoffAddress: 'Perumahan Marina Indah Blok A1 No. 5, Jl. Pantai Indah Kapuk, Penjaringan, Jakarta Utara, DKI Jakarta, 14470',
  ),
  Order(
    id: 'ORD-20260621-002',
    storeName: 'North Wind Sailing',
    storeId: 'store_2',
    items: [
      OrderItem(
        productName: 'Pro-Grid Sailing Gloves (Pair)',
        price: 320000,
        quantity: 2,
        imageUrl: 'https://images.unsplash.com/photo-1516259762381-22954d7d3ad2?w=500&auto=format&fit=crop',
      ),
    ],
    address: dummyAddresses[0],
    deliveryMethod: 'Instant',
    deliveryFee: 20000,
    voucherCode: null,
    discountAmount: 0,
    ppnAmount: 79200, // 12% of (640,000 + 20,000) = 0.12 * 660,000 = 79,200
    finalTotal: 739200,
    status: 'Sedang Dikirim',
    statusTimeline: [
      OrderMilestone(status: 'Sedang Dikemas', timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)), description: 'Pesanan sedang dikemas oleh seller.'),
      OrderMilestone(status: 'Menunggu Pengirim', timestamp: DateTime.now().subtract(const Duration(days: 1)), description: 'Kurir GoSend/GrabExpress bersiap mengambil paket.'),
      OrderMilestone(status: 'Sedang Dikirim', timestamp: DateTime.now().subtract(const Duration(hours: 4)), description: 'Paket sedang dibawa oleh kurir menuju alamat Anda.'),
    ],
    assignedDriverId: 'user_d',
    pickupAddress: 'North Wind Sailing - Surabaya',
    dropoffAddress: 'Perumahan Marina Indah Blok A1 No. 5, Jl. Pantai Indah Kapuk, Penjaringan, Jakarta Utara, DKI Jakarta, 14470',
  ),
  Order(
    id: 'ORD-20260622-003',
    storeName: 'Bluefin Elite Fishing',
    storeId: 'store_3',
    items: [
      OrderItem(
        productName: 'Multi-Jointed Realistic Swim Lure Set',
        price: 180000,
        quantity: 3,
        imageUrl: 'https://images.unsplash.com/photo-1611095790444-1dfa4825a5a2?w=500&auto=format&fit=crop',
      ),
    ],
    address: dummyAddresses[0],
    deliveryMethod: 'Next Day',
    deliveryFee: 10000,
    voucherCode: 'SAILSAVE10',
    discountAmount: 54000, // 10% of 540,000
    ppnAmount: 59520, // 12% of (540,000 - 54,000 + 10,000) = 0.12 * 496,000 = 59,520
    finalTotal: 555520,
    status: 'Sedang Dikemas',
    statusTimeline: [
      OrderMilestone(status: 'Sedang Dikemas', timestamp: DateTime.now().subtract(const Duration(hours: 12)), description: 'Pesanan terkonfirmasi. Seller sedang mempersiapkan barang.'),
    ],
    assignedDriverId: null,
    pickupAddress: 'Bluefin Elite Fishing - Bali',
    dropoffAddress: 'Perumahan Marina Indah Blok A1 No. 5, Jl. Pantai Indah Kapuk, Penjaringan, Jakarta Utara, DKI Jakarta, 14470',
  ),
  Order(
    id: 'ORD-20260623-004',
    storeName: 'Bluefin Elite Fishing',
    storeId: 'store_3',
    items: [
      OrderItem(
        productName: 'Graphite Saltwater Jigging Rod',
        price: 3400000,
        quantity: 1,
        imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&auto=format&fit=crop',
      ),
    ],
    address: dummyAddresses[1],
    deliveryMethod: 'Regular',
    deliveryFee: 5000,
    voucherCode: null,
    discountAmount: 0,
    ppnAmount: 408600, // 12% of (3,400,000 + 5,000) = 408,600
    finalTotal: 3813600,
    status: 'Dikembalikan',
    statusTimeline: [
      OrderMilestone(status: 'Sedang Dikemas', timestamp: DateTime.now().subtract(const Duration(days: 10)), description: 'Pesanan dikemas.'),
      OrderMilestone(status: 'Menunggu Pengirim', timestamp: DateTime.now().subtract(const Duration(days: 9)), description: 'Diserahkan ke logistik.'),
      OrderMilestone(status: 'Sedang Dikirim', timestamp: DateTime.now().subtract(const Duration(days: 8)), description: 'Pengiriman gagal karena alamat kantor tutup/tidak dapat dihubungi.'),
      OrderMilestone(status: 'Dikembalikan', timestamp: DateTime.now().subtract(const Duration(days: 7)), description: 'Pesanan dikembalikan ke seller (Refund diproses).'),
    ],
    assignedDriverId: 'user_d',
    pickupAddress: 'Bluefin Elite Fishing - Bali',
    dropoffAddress: 'Gedung Kelautan Nusantara Lt. 12, Jl. Sudirman Kav 21, Karet Semanggi, Jakarta Selatan, DKI Jakarta, 12930',
  ),
  Order(
    id: 'ORD-20260624-005',
    storeName: 'Oceanic Diving Gear',
    storeId: 'store_1',
    items: [
      OrderItem(
        productName: 'AquaPro Smart Dive Computer',
        price: 6500000,
        quantity: 1,
        imageUrl: 'https://images.unsplash.com/photo-1530541930197-ff16ac917b0e?w=500&auto=format&fit=crop',
      ),
    ],
    address: dummyAddresses[0],
    deliveryMethod: 'Regular',
    deliveryFee: 5000,
    voucherCode: null,
    discountAmount: 0,
    ppnAmount: 780600, // 12% of (6,500,000 + 5,000) = 780,600
    finalTotal: 7285600,
    status: 'Menunggu Pengirim',
    statusTimeline: [
      OrderMilestone(status: 'Sedang Dikemas', timestamp: DateTime.now().subtract(const Duration(hours: 18)), description: 'Barang selesai dibungkus rapi.'),
      OrderMilestone(status: 'Menunggu Pengirim', timestamp: DateTime.now().subtract(const Duration(hours: 2)), description: 'Menunggu penjemputan oleh kurir JNE/SiCepat.'),
    ],
    assignedDriverId: null,
    pickupAddress: 'Oceanic Diving Gear - Jakarta Utara',
    dropoffAddress: 'Perumahan Marina Indah Blok A1 No. 5, Jl. Pantai Indah Kapuk, Penjaringan, Jakarta Utara, DKI Jakarta, 14470',
  ),
];
