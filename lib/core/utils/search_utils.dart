class SearchUtils {
  const SearchUtils._();

  static String normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool matchesPlayerName(
    Map<String, dynamic> data,
    String query,
  ) {
    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) return true;

    final name = normalize(data['Name']?.toString() ?? '');
    final lastName = normalize(data['Last Name']?.toString() ?? '');
    final fullName = normalize('$name $lastName');
    final reversedFullName = normalize('$lastName $name');
    final type = normalize(data['Type']?.toString() ?? '');
    final debt = normalize(data['Debt']?.toString() ?? '');
    final searchableText = normalize('$fullName $reversedFullName $type $debt');

    return normalizedQuery
        .split(' ')
        .every((term) => searchableText.contains(term));
  }
}
