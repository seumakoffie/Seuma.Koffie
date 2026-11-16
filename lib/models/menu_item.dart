// lib/models/menu_item.dart

enum TempOption { hotOnly, iceOnly, both }

class MenuItem {
  final String id;
  final String name;
  final int? priceHot;
  final int? priceIce;
  final int? priceFixed;
  final String category;
  final String categorySlug;
  final String description;
  final TempOption tempOption;
  final bool isBestSeller;
  final bool isNew;
  final String iconEmoji;

  const MenuItem({
    required this.id,
    required this.name,
    this.priceHot,
    this.priceIce,
    this.priceFixed,
    required this.category,
    required this.categorySlug,
    required this.description,
    required this.tempOption,
    this.isBestSeller = false,
    this.isNew = false,
    required this.iconEmoji,
  });

  int get startingPrice {
    if (priceFixed != null) return priceFixed!;
    if (priceHot != null && priceIce != null) {
      return priceHot! < priceIce! ? priceHot! : priceIce!;
    }
    return priceHot ?? priceIce ?? 0;
  }

  int get price => startingPrice;

  String get formattedPrice {
    final str = startingPrice.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  String get imageAsset => iconEmoji;
}

class CategoryInfo {
  final String slug;
  final String name;
  final String iconEmoji;
  final String subtitle;

  const CategoryInfo({
    required this.slug,
    required this.name,
    required this.iconEmoji,
    required this.subtitle,
  });
}

const List<CategoryInfo> kCategories = [
  CategoryInfo(slug: 'all', name: 'Semua', iconEmoji: '✨', subtitle: 'Seluruh Pilihan Menu'),
  CategoryInfo(slug: 'espresso', name: 'Espresso', iconEmoji: '☕', subtitle: 'Pekat & Murni (Hot)'),
  CategoryInfo(slug: 'americano', name: 'Kopi Americano', iconEmoji: '🫖', subtitle: 'Ringan & Segar'),
  CategoryInfo(slug: 'sanger', name: 'Kopi Sanger', iconEmoji: '🥛', subtitle: 'Khas Otentik Aceh'),
  CategoryInfo(slug: 'susu', name: 'Kopi Susu', iconEmoji: '🧋', subtitle: 'Creamy & Manis Aren'),
  CategoryInfo(slug: 'latte', name: 'Latte', iconEmoji: '☕', subtitle: 'Espresso & Smooth Milk'),
  CategoryInfo(slug: 'rasa', name: 'Kopi Rasa', iconEmoji: '🎨', subtitle: 'Twist Rasa Istimewa'),
  CategoryInfo(slug: 'non-kopi', name: 'Non Kopi', iconEmoji: '🍵', subtitle: 'Tanpa Kafein'),
  CategoryInfo(slug: 'matcha', name: 'Matcha', iconEmoji: '🍃', subtitle: 'Matcha Premium'),
  CategoryInfo(slug: 'squash', name: 'Squash', iconEmoji: '🍊', subtitle: 'Buah Segar Tropis'),
  CategoryInfo(slug: 'saku', name: 'Kopi Saku 200ml', iconEmoji: '📦', subtitle: 'Kemasan Botol Praktis'),
];

const List<MenuItem> kMenuItems = [
  // === ESPRESSO ===
  MenuItem(
    id: 'esp-1',
    name: 'Espresso',
    priceHot: 10000,
    category: 'Espresso',
    categorySlug: 'espresso',
    description: 'Single shot espresso murni dari biji kopi sangrai terbaik, pekat dan kaya crema.',
    tempOption: TempOption.hotOnly,
    isBestSeller: true,
    iconEmoji: '☕',
  ),

  // === KOPI AMERICANO ===
  MenuItem(
    id: 'ame-1',
    name: 'Americano',
    priceHot: 10000,
    priceIce: 12000,
    category: 'Kopi Americano',
    categorySlug: 'americano',
    description: 'Espresso diencerkan dengan air panas/dingin, rasa bersih dengan aftertaste manis.',
    tempOption: TempOption.both,
    isBestSeller: true,
    iconEmoji: '🫖',
  ),
  MenuItem(
    id: 'ame-2',
    name: 'Peach Americano',
    priceIce: 15000,
    category: 'Kopi Americano',
    categorySlug: 'americano',
    description: 'Sensasi asam manis buah peach segar berpadu sempurna dengan dinginnya espresso.',
    tempOption: TempOption.iceOnly,
    isNew: true,
    iconEmoji: '🍑',
  ),
  MenuItem(
    id: 'ame-3',
    name: 'Lemon Americano',
    priceIce: 15000,
    category: 'Kopi Americano',
    categorySlug: 'americano',
    description: 'Perasan jeruk lemon segar menyatu dengan espresso dingin, sangat membangkitkan stamina.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '🍋',
  ),
  MenuItem(
    id: 'ame-4',
    name: 'Orange Americano',
    priceIce: 15000,
    category: 'Kopi Americano',
    categorySlug: 'americano',
    description: 'Kombinasi eksotis sari jeruk orange tropis dan double shot espresso chilled.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '🍊',
  ),

  // === KOPI SANGER ===
  MenuItem(
    id: 'san-1',
    name: 'Sanger Espresso',
    priceHot: 12000,
    priceIce: 15000,
    category: 'Kopi Sanger',
    categorySlug: 'sanger',
    description: 'Kopi khas Aceh legendaris! Racikan espresso pekat dengan susu kental manis proporsi pas.',
    tempOption: TempOption.both,
    isBestSeller: true,
    iconEmoji: '🥛',
  ),
  MenuItem(
    id: 'san-2',
    name: 'Sanger Tegur',
    priceIce: 17000,
    category: 'Kopi Sanger',
    categorySlug: 'sanger',
    description: 'Varian Sanger dengan body ekstra mantap dan aroma biji sangrai lebih pekat menggoda.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '☕',
  ),

  // === KOPI SUSU (ICE) ===
  MenuItem(
    id: 'sus-1',
    name: 'Kopi Susu Aren',
    priceIce: 15000,
    category: 'Kopi Susu',
    categorySlug: 'susu',
    description: 'Espresso berpadu susu segar dan gula aren alami murni, manis legit tanpa enek.',
    tempOption: TempOption.iceOnly,
    isBestSeller: true,
    iconEmoji: '🧋',
  ),
  MenuItem(
    id: 'sus-2',
    name: 'Kopi Susu Vanilla',
    priceIce: 17000,
    category: 'Kopi Susu',
    categorySlug: 'susu',
    description: 'Aroma harum ekstrak vanilla lembut menyatu dalam gurihnya susu dan kopi.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '🍦',
  ),
  MenuItem(
    id: 'sus-3',
    name: 'Kopi Susu Hazelnut',
    priceIce: 17000,
    category: 'Kopi Susu',
    categorySlug: 'susu',
    description: 'Rasa nutty hazelnut gurih yang mewah dalam setiap tegukan dingin.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '🌰',
  ),
  MenuItem(
    id: 'sus-4',
    name: 'Kopi Susu Caramel',
    priceIce: 17000,
    category: 'Kopi Susu',
    categorySlug: 'susu',
    description: 'Drizzle sirup karamel bakar manis berpadu lembut bersama kopi susu segar.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '🍯',
  ),
  MenuItem(
    id: 'sus-5',
    name: 'Kopi Susu Pandan',
    priceIce: 17000,
    category: 'Kopi Susu',
    categorySlug: 'susu',
    description: 'Aroma wangi daun pandan alami berpadu klasik dengan kopi nusantara.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '🍃',
  ),
  MenuItem(
    id: 'sus-6',
    name: 'Kopi Susu Butterscotch',
    priceIce: 17000,
    category: 'Kopi Susu',
    categorySlug: 'susu',
    description: 'Kombinasi butter caramel keemasan yang gurih creamy memanjakan lidah.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '🧈',
  ),
  MenuItem(
    id: 'sus-7',
    name: 'Seasalt Caramel Latte',
    priceIce: 18000,
    category: 'Kopi Susu',
    categorySlug: 'susu',
    description: 'Menu favorit! Sentuhan garam laut gurih menyeimbangkan manisnya saus karamel.',
    tempOption: TempOption.iceOnly,
    isNew: true,
    isBestSeller: true,
    iconEmoji: '🧂',
  ),
  MenuItem(
    id: 'sus-8',
    name: 'Seasalt Butterscotch Latte',
    priceIce: 18000,
    category: 'Kopi Susu',
    categorySlug: 'susu',
    description: 'Lapisan foam seasalt lembut di atas butterscotch latte dingin yang memikat.',
    tempOption: TempOption.iceOnly,
    isNew: true,
    iconEmoji: '🌊',
  ),

  // === LATTE (ICE) ===
  MenuItem(
    id: 'lat-1',
    name: 'Coffee Latte',
    priceIce: 15000,
    category: 'Latte',
    categorySlug: 'latte',
    description: 'Espresso halus dengan susu segar berbusa lembut, seimbang dan ringan di perut.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '☕',
  ),
  MenuItem(
    id: 'lat-2',
    name: 'Spanish Latte',
    priceIce: 17000,
    category: 'Latte',
    categorySlug: 'latte',
    description: 'Latte bergaya Spanyol dengan sentuhan susu kental manis yang lebih creamy dan rich.',
    tempOption: TempOption.iceOnly,
    isBestSeller: true,
    iconEmoji: '🥛',
  ),

  // === KOPI RASA (ICE) ===
  MenuItem(
    id: 'ras-1',
    name: 'Kopi Taro',
    priceIce: 15000,
    category: 'Kopi Rasa',
    categorySlug: 'rasa',
    description: 'Perpaduan unik rasa taro ungu gurih manis dengan sentuhan kafein espresso.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '🍠',
  ),
  MenuItem(
    id: 'ras-2',
    name: 'Kopi Coklat',
    priceIce: 15000,
    category: 'Kopi Rasa',
    categorySlug: 'rasa',
    description: 'Mocha klasik dengan bubuk cokelat dark premium yang pekat dan memuaskan.',
    tempOption: TempOption.iceOnly,
    isBestSeller: true,
    iconEmoji: '🍫',
  ),
  MenuItem(
    id: 'ras-3',
    name: 'Kopi Red Velved',
    priceIce: 15000,
    category: 'Kopi Rasa',
    categorySlug: 'rasa',
    description: 'Warna merah menawan dengan hint rasa kue red velvet dan kopi aromatik.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '🍰',
  ),

  // === NON KOPI ===
  MenuItem(
    id: 'non-1',
    name: 'Taro Latte',
    priceHot: 10000,
    priceIce: 13000,
    category: 'Non Kopi',
    categorySlug: 'non-kopi',
    description: 'Minuman taro lembut tanpa kopi, manis gurih dan sangat menenangkan.',
    tempOption: TempOption.both,
    iconEmoji: '🍠',
  ),
  MenuItem(
    id: 'non-2',
    name: 'Coklat Latte',
    priceHot: 10000,
    priceIce: 13000,
    category: 'Non Kopi',
    categorySlug: 'non-kopi',
    description: 'Cokelat murni diseduh bersama susu hangat atau es batu, cocok untuk semua usia.',
    tempOption: TempOption.both,
    isBestSeller: true,
    iconEmoji: '🍫',
  ),
  MenuItem(
    id: 'non-3',
    name: 'Red Velved Latte',
    priceHot: 10000,
    priceIce: 13000,
    category: 'Non Kopi',
    categorySlug: 'non-kopi',
    description: 'Minuman red velvet creamy berbusa halus, manis dan harum menggoda.',
    tempOption: TempOption.both,
    iconEmoji: '🍰',
  ),

  // === MATCHA (ICE) ===
  MenuItem(
    id: 'mat-1',
    name: 'Matcha Original',
    priceIce: 13000,
    category: 'Matcha',
    categorySlug: 'matcha',
    description: 'Teh hijau jepang otentik dengan aroma earthy alami yang menyegarkan.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '🍵',
  ),
  MenuItem(
    id: 'mat-2',
    name: 'Matcha Latte',
    priceIce: 15000,
    category: 'Matcha',
    categorySlug: 'matcha',
    description: 'Matcha premium berpadu lembutnya susu murni, seimbang antara pahit manis.',
    tempOption: TempOption.iceOnly,
    isBestSeller: true,
    iconEmoji: '🍃',
  ),
  MenuItem(
    id: 'mat-3',
    name: 'Strawberry Matcha',
    priceIce: 18000,
    category: 'Matcha',
    categorySlug: 'matcha',
    description: 'Kreasi visual ombre 3 lapis: selai strawberry segar, susu, dan matcha pekat.',
    tempOption: TempOption.iceOnly,
    isNew: true,
    iconEmoji: '🍓',
  ),

  // === SQUASH (ICE) ===
  MenuItem(
    id: 'squ-1',
    name: 'Orange Squash',
    priceIce: 10000,
    category: 'Squash',
    categorySlug: 'squash',
    description: 'Sensasi soda segar dingin dengan bulir rasa jeruk manis penangkal dahaga.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '🍊',
  ),
  MenuItem(
    id: 'squ-2',
    name: 'Lemon Squash',
    priceIce: 10000,
    category: 'Squash',
    categorySlug: 'squash',
    description: 'Asam manis menyegarkan perasan lemon dengan gelembung soda yang berdesis.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '🍋',
  ),
  MenuItem(
    id: 'squ-3',
    name: 'Strawberry Squash',
    priceIce: 10000,
    category: 'Squash',
    categorySlug: 'squash',
    description: 'Soda merah menyala dengan sari buah strawberry segar yang membangkitkan mood.',
    tempOption: TempOption.iceOnly,
    isBestSeller: true,
    iconEmoji: '🍓',
  ),
  MenuItem(
    id: 'squ-4',
    name: 'Lychee Squash',
    priceIce: 10000,
    category: 'Squash',
    categorySlug: 'squash',
    description: 'Aroma wangi buah leci manis menyatu dalam dinginnya soda kristal.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '🍈',
  ),
  MenuItem(
    id: 'squ-5',
    name: 'Mango Squash',
    priceIce: 10000,
    category: 'Squash',
    categorySlug: 'squash',
    description: 'Kelezatan mangga tropis harum dengan sensasi sparkling soda es batu.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '🥭',
  ),

  // === KOPI SAKU 200ML ===
  MenuItem(
    id: 'sak-1',
    name: 'Kopi Sanger Espresso 200ml',
    priceFixed: 17000,
    category: 'Kopi Saku 200ml',
    categorySlug: 'saku',
    description: 'Sanger khas Aceh dalam botol saku 200ml, siap dibawa kerja atau nongkrong.',
    tempOption: TempOption.iceOnly,
    isBestSeller: true,
    iconEmoji: '📦',
  ),
  MenuItem(
    id: 'sak-2',
    name: 'Kopi Susu Aren 200ml',
    priceFixed: 18000,
    category: 'Kopi Saku 200ml',
    categorySlug: 'saku',
    description: 'Kopi susu gula aren andalan dalam botol praktis, tahan simpan di kulkas.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '📦',
  ),
  MenuItem(
    id: 'sak-3',
    name: 'Kopi Susu Pandan 200ml',
    priceFixed: 18000,
    category: 'Kopi Saku 200ml',
    categorySlug: 'saku',
    description: 'Wangi pandan khas dalam kemasan 200ml yang higienis dan mudah dibawa.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '📦',
  ),
  MenuItem(
    id: 'sak-4',
    name: 'Kopi Susu Caramel 200ml',
    priceFixed: 18000,
    category: 'Kopi Saku 200ml',
    categorySlug: 'saku',
    description: 'Karamel gurih manis siap minum kapan saja Anda butuh suntikan semangat.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '📦',
  ),
  MenuItem(
    id: 'sak-5',
    name: 'Kopi Susu Hazelnut 200ml',
    priceFixed: 18000,
    category: 'Kopi Saku 200ml',
    categorySlug: 'saku',
    description: 'Cita rasa hazelnut mewah dalam botol saku anti tumpah.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '📦',
  ),
  MenuItem(
    id: 'sak-6',
    name: 'Kopi Susu Butterscotch 200ml',
    priceFixed: 18000,
    category: 'Kopi Saku 200ml',
    categorySlug: 'saku',
    description: 'Varian butterscotch premium dalam botol 200ml dingin menyegarkan.',
    tempOption: TempOption.iceOnly,
    iconEmoji: '📦',
  ),
];

