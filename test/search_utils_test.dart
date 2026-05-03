import 'package:balanceballers/core/utils/search_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchUtils.matchesPlayerName', () {
    const player = {
      'Name': 'Ahmad',
      'Last Name': 'Wali',
      'Type': 'VIP',
      'Debt': 250,
    };

    test('matches first name, last name, full name, and reversed full name',
        () {
      expect(SearchUtils.matchesPlayerName(player, 'ahm'), isTrue);
      expect(SearchUtils.matchesPlayerName(player, 'wali'), isTrue);
      expect(SearchUtils.matchesPlayerName(player, 'Ahmad Wali'), isTrue);
      expect(SearchUtils.matchesPlayerName(player, 'Wali Ahmad'), isTrue);
    });

    test('matches multiple search terms in any supported field', () {
      expect(SearchUtils.matchesPlayerName(player, '  ahmad   vip  '), isTrue);
      expect(SearchUtils.matchesPlayerName(player, 'wali 250'), isTrue);
    });

    test('returns false when the query does not match', () {
      expect(SearchUtils.matchesPlayerName(player, 'karim'), isFalse);
    });
  });
}
