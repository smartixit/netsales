import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/services/infinityfree_challenge_solver.dart';

void main() {
  group('InfinityFreeChallengeSolver', () {
    const challenge = '''
<html><body><script type="text/javascript" src="/aes.js"></script><script>
function toNumbers(d){var e=[];d.replace(/(..)/g,function(d){e.push(parseInt(d,16))});return e}
var a=toNumbers("f655ba9d09a112d4968c63579db590b4"),b=toNumbers("98344c2eee86c3994890592585b49f80"),c=toNumbers("25b509cc7dadcdb532275647f94524cc");
document.cookie="__test="+toHex(slowAES.decrypt(c,2,a,b))+"; max-age=21600; path=/";
</script></body></html>
''';

    test('detects the real InfinityFree challenge page', () {
      expect(InfinityFreeChallengeSolver.isChallengeBody(challenge), isTrue);
    });

    test('extracts constants from minified challenge JavaScript', () {
      expect(InfinityFreeChallengeSolver.extractConstants(challenge), [
        'f655ba9d09a112d4968c63579db590b4',
        '98344c2eee86c3994890592585b49f80',
        '25b509cc7dadcdb532275647f94524cc',
      ]);
    });

    test('matches the challenge cookie for the supplied single AES block', () {
      expect(
        InfinityFreeChallengeSolver.solveChallenge(challenge),
        'e84330a69c6df373fc2fd2a2827a5f',
      );
    });

    test('extracts constants despite whitespace and line breaks', () {
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

    test('rejects incomplete challenge constants', () {
      expect(
        InfinityFreeChallengeSolver.solveChallenge(
          'var a=toNumbers("f655ba9d09a112d4968c63579db590b4");',
        ),
        isNull,
      );
    });

    test('rejects malformed hexadecimal constants', () {
      expect(
        InfinityFreeChallengeSolver.solveChallenge('''
var a=toNumbers("zz559a9d09a112d4968c63579db590b4"),
b=toNumbers("98344c2eee86c3994890592585b49f80"),
c=toNumbers("25b509cc7dadcdb532275647f94524cc");
'''),
        isNull,
      );
    });
  });
}
