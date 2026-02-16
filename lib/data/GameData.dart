class Gamedata {
  final List<String> gameNames = ["Логикичеткая", "Geeks", "Для детей"];
  final List<int> gameIds = [1, 2, 3];
  final List<String> images = [
    "https://i.ibb.co/k2fJzLgx/logic.jpg",
    "https://i.ibb.co/TxcY9GVk/Geeks.jpg",
    "https://i.ibb.co/zWPLDptZ/jun.jpg"
  ];
  final List<String> imagesLocal = [
    "assets/images/logic.jpg",
    "assets/images/geeks.jpg",
    "assets/images/jun.jpg",
  ];
  final List<String> Icons = [
    "assets/icons/LOGIC_ICON.jpg",
    "assets/icons/GEEKS_ICON.jpg",
    "assets/icons/JUNIOR_ICON.jpg",
  ];
  final List<String> descriptions = [
    "Это не просто вопросы - это челлендж для твоего интеллекта. Проверь, насколько ты умеешь анализировать, сравнивать и находить скрытые решения.",
    "Тут вопросы про нашу академию - На сколько ты знаешь академию Geeks и разные направления IT",
    "Весёлые задачки, которые помогут тебе думать быстрее и находить правильные решения!"
  ];

  List<String> getGameNames(){
    return gameNames;
  }
  List<int> getGameIds(){
    return gameIds;
  }
  List<String> getImages(){
    return images;
  }
  List<String> getImagesLocal(){
    return imagesLocal;
  }
  List<String> getIcons(){
    return Icons;
  }
  List<String> getDescriptions(){
    return descriptions;
  }
}