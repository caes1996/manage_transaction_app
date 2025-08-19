class Utils {
  static String getInitials(String name) {
    final names = name.split(' ');
    if (names.length > 2) {
      return '${names[0][0]}${names[1][0]}${names[2][0]}';
    }
    return names.map((name) => name[0]).join().toUpperCase();
  }
}