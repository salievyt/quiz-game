import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz/ui/providers/pet_provider.dart';
import 'package:quiz/ui/providers/coins_provider.dart';

class PetShopScreen extends StatefulWidget {
  const PetShopScreen({super.key});

  @override
  State<PetShopScreen> createState() => _PetShopScreenState();
}

class _PetShopScreenState extends State<PetShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final coinsProvider = context.watch<CoinsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FB);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text("Магазин", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text("🪙", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  coinsProvider.formattedCoins,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF7ED421),
          labelColor: const Color(0xFF7ED421),
          unselectedLabelColor: isDark ? Colors.grey : Colors.grey,
          tabs: const [
            Tab(text: "🎩"),
            Tab(text: "😎"),
            Tab(text: "📿"),
            Tab(text: "👕"),
            Tab(text: "✨"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AccessoryGrid(
            type: AccessoryType.hat,
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
          ),
          _AccessoryGrid(
            type: AccessoryType.glasses,
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
          ),
          _AccessoryGrid(
            type: AccessoryType.collar,
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
          ),
          _AccessoryGrid(
            type: AccessoryType.outfit,
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
          ),
          _AccessoryGrid(
            type: AccessoryType.aura,
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _AccessoryGrid extends StatelessWidget {
  final AccessoryType type;
  final Color cardColor;
  final Color textColor;
  final bool isDark;

  const _AccessoryGrid({
    required this.type,
    required this.cardColor,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final coinsProvider = context.watch<CoinsProvider>();
    
    final accessories = Accessory.all.where((a) => a.type == type).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: accessories.length,
      itemBuilder: (context, index) {
        final accessory = accessories[index];
        final isOwned = petProvider.hasAccessory(accessory.id);
        final isEquipped = petProvider.getEquippedAccessory(type) == accessory.id;
        final canAfford = coinsProvider.canAfford(accessory.price);

        return _AccessoryCard(
          accessory: accessory,
          isOwned: isOwned,
          isEquipped: isEquipped,
          canAfford: canAfford,
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
          onBuy: () async {
            final success = await petProvider.buyAccessory(accessory.id, accessory.price, coinsProvider.spendCoins);
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Куплено ${accessory.name}! 🎉")),
              );
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Недостаточно монет! 😢")),
              );
            }
          },
          onEquip: () {
            if (isEquipped) {
              petProvider.unequipAccessory(type);
            } else {
              petProvider.equipAccessory(accessory.id);
            }
          },
        );
      },
    );
  }
}

class _AccessoryCard extends StatelessWidget {
  final Accessory accessory;
  final bool isOwned;
  final bool isEquipped;
  final bool canAfford;
  final Color cardColor;
  final Color textColor;
  final bool isDark;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  const _AccessoryCard({
    required this.accessory,
    required this.isOwned,
    required this.isEquipped,
    required this.canAfford,
    required this.cardColor,
    required this.textColor,
    required this.isDark,
    required this.onBuy,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isEquipped 
            ? Border.all(color: const Color(0xFF7ED421), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Иконка
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isEquipped 
                  ? const Color(0xFF7ED421).withValues(alpha: 0.2)
                  : (isDark ? Colors.grey[800] : Colors.grey[100]),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(accessory.emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Название
          Text(
            accessory.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Кнопка
          if (!isOwned)
            ElevatedButton(
              onPressed: canAfford ? onBuy : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? const Color(0xFFFFD700) : Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("🪙", style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    "${accessory.price}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: onEquip,
              style: ElevatedButton.styleFrom(
                backgroundColor: isEquipped ? Colors.red : const Color(0xFF7ED421),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                isEquipped ? "Снять" : "Надеть",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
