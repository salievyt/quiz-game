import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz/ui/providers/pet_provider.dart';
import 'package:quiz/ui/providers/coins_provider.dart';
import 'package:quiz/features/pet/presentation/pages/pet_shop_screen.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _bounceAnimation;
  bool _isPetHappy = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _petThePet() {
    setState(() => _isPetHappy = true);
    _animController.forward().then((_) {
      _animController.reverse();
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _isPetHappy = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final coinsProvider = context.watch<CoinsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FB);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final pet = petProvider.currentPet;
    final hatEmoji = petProvider.getAccessoryEmoji(AccessoryType.hat);
    final glassesEmoji = petProvider.getAccessoryEmoji(AccessoryType.glasses);
    final collarEmoji = petProvider.getAccessoryEmoji(AccessoryType.collar);
    final outfitEmoji = petProvider.getAccessoryEmoji(AccessoryType.outfit);
    final auraEmoji = petProvider.getAccessoryEmoji(AccessoryType.aura);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text("Питомец", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Монеты
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Карточка питомца
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Аура
                  if (auraEmoji != null)
                    Text(auraEmoji, style: const TextStyle(fontSize: 60)),
                  
                  // Питомец с анимацией
                  ScaleTransition(
                    scale: _bounceAnimation,
                    child: GestureDetector(
                      onTap: _petThePet,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Тень
                          Container(
                            width: 100,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Одежда + питомец + очки + шляпа
                              if (outfitEmoji != null)
                                Text(outfitEmoji, style: const TextStyle(fontSize: 20)),
                              Text(
                                _isPetHappy ? _getHappyEmoji(pet.type) : pet.emoji,
                                style: const TextStyle(fontSize: 80),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (glassesEmoji != null)
                                    Text(glassesEmoji, style: const TextStyle(fontSize: 24)),
                                  if (collarEmoji != null)
                                    Text(collarEmoji, style: const TextStyle(fontSize: 20)),
                                ],
                              ),
                              if (hatEmoji != null)
                                Text(hatEmoji, style: const TextStyle(fontSize: 28)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Имя питомца
                  Text(
                    pet.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Кнопка взаимодействия
                  ElevatedButton.icon(
                    onPressed: _petThePet,
                    icon: const Text("👋", style: TextStyle(fontSize: 20)),
                    label: Text(_isPetHappy ? "Счастлив! ❤️" : "Погладить"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7ED421),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Магазин аксессуаров
            _ShopButton(
              cardColor: cardColor,
              textColor: textColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PetShopScreen()),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Выбор питомца
            _PetSelector(
              cardColor: cardColor,
              textColor: textColor,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  String _getHappyEmoji(PetType type) {
    switch (type) {
      case PetType.cat: return '😺';
      case PetType.dog: return '🐶';
      case PetType.hamster: return '🐹';
      case PetType.bunny: return '🐰';
      case PetType.fox: return '🦊';
      case PetType.panda: return '🐼';
      case PetType.owl: return '🦉';
      case PetType.dragon: return '🐲';
    }
  }
}

class _ShopButton extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ShopButton({
    required this.cardColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text("🛍️", style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Магазин аксессуаров",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Купи предметы для питомца",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PetSelector extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final bool isDark;

  const _PetSelector({
    required this.cardColor,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final coinsProvider = context.watch<CoinsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Мои питомцы",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: Pet.all.map((pet) {
                  final isOwned = petProvider.ownedPets.contains(pet.type);
                  final isSelected = petProvider.selectedPet == pet.type;
                  
                  return GestureDetector(
                    onTap: () {
                      if (isOwned) {
                        petProvider.selectPet(pet.type);
                      } else if (coinsProvider.canAfford(pet.price)) {
                        _showBuyDialog(context, pet, petProvider, coinsProvider);
                      }
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF7ED421).withOpacity(0.2)
                            : (isDark ? Colors.grey[800] : Colors.grey[100]),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected 
                            ? Border.all(color: const Color(0xFF7ED421), width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(pet.emoji, style: const TextStyle(fontSize: 28)),
                          if (!isOwned && pet.price > 0)
                            Text("🪙${pet.price}", style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBuyDialog(BuildContext context, Pet pet, PetProvider petProvider, CoinsProvider coinsProvider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Купить ${pet.name}?"),
        content: Text("Цена: ${pet.price} монет"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
          TextButton(
            onPressed: () async {
              final success = await petProvider.buyPet(pet.type, pet.price, coinsProvider.spendCoins);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Куплен ${pet.name}! 🎉")),
                );
              }
            },
            child: const Text("Купить"),
          ),
        ],
      ),
    );
  }
}
