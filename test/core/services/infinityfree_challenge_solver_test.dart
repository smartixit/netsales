import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/services/infinityfree_challenge_solver.dart';

void main() {
  group('InfinityFreeChallengeSolver', () {
    const challenge = '''
<html><body><script src="/aes.js"></script><script>
var a=toNumbers("f655ba9d09a112d4968c63579db590b4"),b=toNumbers("98344c2eee86c3994890592585b49f80"),c=toNumbers("25b509cc7dadcdb532275647f94524cc");
document.cookie="__test="+toHex(slowAES.decrypt(c,2,a,b))+"; max-age=21600; path=/";
</script></body></html>
''';
    test('detects the challenge response', () {
      expect(InfinityFreeChallengeSolver.isChallengeBody(challenge), isTrue);
    });
    test('extracts minified constants', () {
      expect(InfinityFreeChallengeSolver.extractConstants(challenge), [
        'f655ba9d09a112d4968c63579db590b4',
        '98344c2eee86c3994890592585b49f80',
        '25b509cc7dadcdb532275647f94524cc',
      ]);
    });
    test('matches SlowAES for the single-block challenge', () {
      // The decrypted block ends in 0x0d, but it is not a repeated padding run.
      expect(
        InfinityFreeChallengeSolver.solveChallenge(challenge),
        'e84330a69c6df373fc2fd2a2827a5f0d',
      );
    });
    test('accepts whitespace around declarations and arguments', () {
      const spaced = '''
var a = toNumbers ( "f655ba9d09a112d4968c63579db590b4" ),
 b = toNumbers ( "98344c2eee86c3994890592585b49f80" ),
 c = toNumbers ( "25b509cc7dadcdb532275647f94524cc" );
''';
      expect(InfinityFreeChallengeSolver.extractConstants(spaced), [
        'f655ba9d09a112d4968c63579db590b4',
        '98344c2eee86c3994890592585b49f80',
        '25b509cc7dadcdb532275647f94524cc',
      ]);
    });
    test('rejects incomplete constants', () {
      expect(InfinityFreeChallengeSolver.solveChallenge(
        'var a=toNumbers("f655ba9d09a112d4968c63579db590b4");',
      ), isNull);
    });
  });
}
