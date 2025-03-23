class Shortcut {
  String name;
  String url;
  String? iconPath;
  String? backgroundPath;

  Shortcut({required this.name, required this.url, this.iconPath, this.backgroundPath});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'iconPath': iconPath ?? Shortcut.getDefaultIconPath(),
      'backgroundPath': backgroundPath ?? Shortcut.getDefaultBackground(),
    };
  }

  static String getDefaultIconPath(){
    return 'assets/icons/google.png';
  }

  static String getDefaultBackground(){
    return 'assets/images/Charlotta.png';
  }
}