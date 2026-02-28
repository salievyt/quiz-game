import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AccessoryType {
  hat,      // Шляпа
  glasses,  // Очки
  collar,  // Ошейник
  outfit,  // Одежда
  aura,    // Аура
}

// Аксессуар
class Accessory {
  final String id;
  final String name;
  final AccessoryType type;
  final int price;
  final String icon;
  final String emoji;

  const Accessory({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.icon,
    required this.emoji,
  });

  static const List<Accessory> all = [
    // Шляпы
    Accessory(id: 'hat_crown', name: 'Корона', type: AccessoryType.hat, price: 500, icon: '👑', emoji: '👑'),
    Accessory(id: 'hat_cap', name: 'Кепка', type: AccessoryType.hat, price: 100, icon: '🧢', emoji: '🧢'),
    Accessory(id: 'hat_wizard', name: 'Шляпа волшебника', type: AccessoryType.hat, price: 300, icon: '🎩', emoji: '🎩'),
    Accessory(id: 'hat_cowboy', name: 'Ковбойская шляпа', type: AccessoryType.hat, price: 200, icon: '🤠', emoji: '🤠'),
    Accessory(id: 'hat_party', name: 'Праздничный колпак', type: AccessoryType.hat, price: 150, icon: '🎉', emoji: '🎉'),
    
    // Очки
    Accessory(id: 'glasses_cool', name: 'Крутые очки', type: AccessoryType.glasses, price: 200, icon: '😎', emoji: '😎'),
    Accessory(id: 'glasses_nerd', name: 'Очки nerdy', type: AccessoryType.glasses, price: 150, icon: '🤓', emoji: '🤓'),
    Accessory(id: 'glasses_sun', name: 'Солнечные очки', type: AccessoryType.glasses, price: 100, icon: '🕶️', emoji: '🕶️'),
    
    // Ошейники
    Accessory(id: 'collar_gold', name: 'Золотой ошейник', type: AccessoryType.collar, price: 400, icon: '📿', emoji: '📿'),
    Accessory(id: 'collar_red', name: 'Красный ошейник', type: AccessoryType.collar, price: 100, icon: '🔴', emoji: '🔴'),
    Accessory(id: 'collar_blue', name: 'Синий ошейник', type: AccessoryType.collar, price: 100, icon: '🔵', emoji: '🔵'),
    
    // Одежда
    Accessory(id: 'outfit_super', name: 'Супергерой', type: AccessoryType.outfit, price: 500, icon: '🦸', emoji: '🦸'),
    Accessory(id: 'outfit_ninja', name: 'Ниндзя', type: AccessoryType.outfit, price: 400, icon: '🥷', emoji: '🥷'),
    Accessory(id: 'outfit_robot', name: 'Робот', type: AccessoryType.outfit, price: 300, icon: '🤖', emoji: '🤖'),
    
    // Ауры
    Accessory(id: 'aura_fire', name: 'Огненная аура', type: AccessoryType.aura, price: 1000, icon: '🔥', emoji: '🔥'),
    Accessory(id: 'aura_ice', name: 'Ледяная аура', type: AccessoryType.aura, price: 1000, icon: '❄️', emoji: '❄️'),
    Accessory(id: 'aura_rainbow', name: 'Радужная аура', type: AccessoryType.aura, price: 800, icon: '🌈', emoji: '🌈'),
    Accessory(id: 'aura_star', name: 'Звёздная аура', type: AccessoryType.aura, price: 600, icon: '⭐', emoji: '⭐'),
  ];
}

// Доступные питомцы
enum PetType {
  cat,     // Кот
  dog,     // Собака
  hamster, // Хомяк
  bunny,   // Кролик
  fox,     // Лиса
  panda,   // Панда
  owl,     // Сова
  dragon,  // Дракон
}

class Pet {
  final PetType type;
  final String name;
  final String emoji;
  final int price;

  const Pet({
    required this.type,
    required this.name,
    required this.emoji,
    required this.price,
  });

  static const List<Pet> all = [
    Pet(type: PetType.cat, name: 'Котёнок', emoji: '🐱', price: 0),
    Pet(type: PetType.dog, name: 'Щенок', emoji: '🐶', price: 100),
    Pet(type: PetType.hamster, name: 'Хомячок', emoji: '🐹', price: 50),
    Pet(type: PetType.bunny, name: 'Кролик', emoji: '🐰', price: 100),
    Pet(type: PetType.fox, name: 'Лиса', emoji: '🦊', price: 200),
    Pet(type: PetType.panda, name: 'Панда', emoji: '🐼', price: 300),
    Pet(type: PetType.owl, name: 'Сова', emoji: '🦉', price: 250),
    Pet(type: PetType.dragon, name: 'Дракон', emoji: '🐲', price: 1000),
  ];
}

// Провайдер питомца и аксессуаров
class PetProvider extends ChangeNotifier {
  static const String _petTypeKey = 'selected_pet';
  static const String _ownedPetsKey = 'owned_pets';
  static const String _equippedAccessoriesKey = 'equipped_accessories';
  static const String _ownedAccessoriesKey = 'owned_accessories';

  PetType _selectedPet = PetType.cat;
  Set<PetType> _ownedPets = {PetType.cat};
  Map<AccessoryType, String> _equippedAccessories = {};
  Set<String> _ownedAccessories = {};
  bool _isInitialized = false;

  PetType get selectedPet => _selectedPet;
  Set<PetType> get ownedPets => _ownedPets;
  Map<AccessoryType, String> get equippedAccessories => _equippedAccessories;
  Set<String> get ownedAccessories => _ownedAccessories;
  bool get isInitialized => _isInitialized;

  Pet get currentPet => Pet.all.firstWhere((p) => p.type == _selectedPet);

  bool hasAccessory(String id) => _ownedAccessories.contains(id);

  String? getEquippedAccessory(AccessoryType type) => _equippedAccessories[type];

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Загружаем питомца
      final petIndex = prefs.getInt(_petTypeKey) ?? 0;
      _selectedPet = PetType.values[petIndex];

      // Загружаем купленных питомцев
      final ownedPetsList = prefs.getStringList(_ownedPetsKey);
      if (ownedPetsList != null) {
        _ownedPets = ownedPetsList.map((e) => PetType.values[int.parse(e)]).toSet();
      }

      // Загружаем экипировку
      final equippedJson = prefs.getString(_equippedAccessoriesKey);
      if (equippedJson != null) {
        final decoded = jsonDecode(equippedJson) as Map<String, dynamic>;
        _equippedAccessories = decoded.map(
          (k, v) => MapEntry(AccessoryType.values[int.parse(k)], v as String),
        );
      }

      // Загружаем купленные аксессуары
      final ownedAccList = prefs.getStringList(_ownedAccessoriesKey);
      if (ownedAccList != null) {
        _ownedAccessories = ownedAccList.toSet();
      }
    } catch (e) {
      _selectedPet = PetType.cat;
      _ownedPets = {PetType.cat};
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> selectPet(PetType type) async {
    if (!_ownedPets.contains(type)) return false;
    _selectedPet = type;
    await _savePet();
    notifyListeners();
    return true;
  }

  Future<bool> buyPet(PetType type, int price, Function(int) deductCoins) async {
    if (_ownedPets.contains(type)) return false;
    if (price > 0) {
      deductCoins(price);
    }
    _ownedPets.add(type);
    _selectedPet = type;
    await _savePets();
    notifyListeners();
    return true;
  }

  Future<bool> buyAccessory(String id, int price, Function(int) deductCoins) async {
    if (_ownedAccessories.contains(id)) return false;
    
    deductCoins(price);
    
    _ownedAccessories.add(id);
    await _saveAccessories();
    notifyListeners();
    return true;
  }

  Future<void> equipAccessory(String id) async {
    final accessory = Accessory.all.firstWhere((a) => a.id == id);
    if (!_ownedAccessories.contains(id)) return;

    _equippedAccessories[accessory.type] = id;
    await _saveEquipped();
    notifyListeners();
  }

  Future<void> unequipAccessory(AccessoryType type) async {
    _equippedAccessories.remove(type);
    await _saveEquipped();
    notifyListeners();
  }

  Future<void> _savePet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_petTypeKey, _selectedPet.index);
  }

  Future<void> _savePets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_ownedPetsKey, _ownedPets.map((e) => e.index.toString()).toList());
    await prefs.setInt(_petTypeKey, _selectedPet.index);
  }

  Future<void> _saveAccessories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_ownedAccessoriesKey, _ownedAccessories.toList());
  }

  Future<void> _saveEquipped() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _equippedAccessories.map((k, v) => MapEntry(k.index.toString(), v));
    await prefs.setString(_equippedAccessoriesKey, jsonEncode(json));
  }

  // Получить эмодзи аксессуара по типу
  String? getAccessoryEmoji(AccessoryType type) {
    final id = _equippedAccessories[type];
    if (id == null) return null;
    final accessory = Accessory.all.firstWhere((a) => a.id == id, orElse: () => Accessory.all.first);
    return accessory.emoji;
  }
}
