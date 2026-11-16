// lib/widgets/story_and_quiz_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/menu_item.dart';
import '../theme/app_theme.dart';
import 'product_dialog.dart';

class StoryAndQuizSection extends StatefulWidget {
  const StoryAndQuizSection({super.key});

  @override
  State<StoryAndQuizSection> createState() => _StoryAndQuizSectionState();
}

class _StoryAndQuizSectionState extends State<StoryAndQuizSection> {
  String _selectedTaste = 'creamy'; // 'creamy' | 'bold' | 'fruity'

  List<MenuItem> get _recommendedItems {
    if (_selectedTaste == 'bold') {
      return kMenuItems.where((i) => i.categorySlug == 'espresso' || i.categorySlug == 'sanger').take(3).toList();
    } else if (_selectedTaste == 'fruity') {
      return kMenuItems.where((i) => i.categorySlug == 'squash' || i.name.contains('Peach') || i.name.contains('Lemon')).take(3).toList();
    } else {
      return kMenuItems.where((i) => i.categorySlug == 'susu' || i.categorySlug == 'latte' || i.categorySlug == 'matcha').take(3).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : 16,
          vertical: 36,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. STORYLINE: DARI BIJI KE CANGKIR
            // ==========================================
            Container(
              padding: EdgeInsets.all(isDesktop ? 36 : 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppColors.softShadow,
                border: Border.all(color: AppColors.caramel.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.caramel.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'FILOSOFI SEUMA',
                          style: TextStyle(
                            color: AppColors.caramel,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dari Biji Pilihan ke Cangkir Sempurnamu',
                    style: TextStyle(
                      fontSize: isDesktop ? 26 : 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Perjalanan autentik setiap tetes kopi Seuma yang diseduh dengan teknik Sanger tradisional dan standar higienis modern.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.45),
                  ),
                  const SizedBox(height: 24),

                  // 4-step grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isDesktop ? 4 : (screenWidth > 500 ? 2 : 1),
                    childAspectRatio: isDesktop ? 1.05 : 1.7,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    children: [
                      _buildStoryCard('01', '🌱', 'Biji Pilihan Gayo', 'Petik merah matang dari perkebunan dataran tinggi Aceh.'),
                      _buildStoryCard('02', '🔥', 'Roasting Artisanal', 'Profil sangrai medium-dark demi aroma karamel dan aroma floral.'),
                      _buildStoryCard('03', '🥛', 'Tarikan Sanger Asli', 'Teknik tuang tarikan khas demi tekstur lembut creamy sempurna.'),
                      _buildStoryCard('04', '📦', 'Kemasan Cepat & Higienis', 'Penyajian steril dalam cup tebal dan botol saku anti tumpah.'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ==========================================
            // 2. INTERACTIVE TASTE QUIZ
            // ==========================================
            Container(
              padding: EdgeInsets.all(isDesktop ? 36 : 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.espresso,
                    const Color(0xFF2E1505),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.espresso.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'PENCARI KOPI PAS (TASTE QUIZ)',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: isDesktop ? 11 : 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bingung Mau Minum Apa Hari Ini?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 26 : 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih suasana hatimu, dan sistem kami akan merekomendasikan racikan yang paling pas.',
                    style: TextStyle(color: AppColors.cream.withValues(alpha: 0.8), fontSize: 12.5),
                  ),

                  const SizedBox(height: 20),

                  // Question 1: Taste Profile
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _buildTasteOption('creamy', '🧋 Manis & Creamy', _selectedTaste == 'creamy'),
                      _buildTasteOption('bold', '☕ Pekat & Kuat', _selectedTaste == 'bold'),
                      _buildTasteOption('fruity', '🍊 Segar Tropis & Soda', _selectedTaste == 'fruity'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Recommended Items Result
                  Text(
                    'Rekomendasi Untukmu:',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _recommendedItems.map((item) {
                      return InkWell(
                        onTap: () => ProductDialog.show(context, item),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: isDesktop ? 240 : double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.caramel.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Text(item.iconEmoji, style: const TextStyle(fontSize: 26)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      item.category,
                                      style: TextStyle(
                                        color: AppColors.cream.withValues(alpha: 0.7),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.caramel,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Pesan',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ==========================================
            // 3. PROMO VOUCHER BANNER
            // ==========================================
            Container(
              padding: EdgeInsets.all(isDesktop ? 28 : 18),
              decoration: BoxDecoration(
                gradient: AppColors.caramelGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.caramel.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Voucher Diskon Spesial: SEUMAFIRST',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dapatkan potongan Rp 15.000 untuk pesanan pertamamu di web Seuma!',
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: 'SEUMAFIRST'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kode voucher SEUMAFIRST disalin!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.espresso,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Salin Kode', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(String step, String emoji, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.caramel.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              Text(
                step,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.caramel.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _buildTasteOption(String id, String label, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedTaste = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.caramel : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

