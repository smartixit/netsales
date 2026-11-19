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

    test(
      'matches the challenge cookie for the supplied single AES block',
      () {
        expect(
          InfinityFreeChallengeSolver.solveChallenge(challenge),
          'e84330a69c6df373fc2fd2a2827a5f',
        );
      },
    );

    test(
      'decrypts a multi-block CBC challenge against an independent vector',
      () {
        final multiBlockChallenge = challenge.replaceFirst(
          '25b509cc7dadcdb532275647f94524cc',
          '848cbc60dcde88fe99cfe77c054994ce'
          '60a11c76f356fe15a23aa2d618e0e504'
          '35020a24332ee3fa1643fa52935a2b01',
        );

        expect(
          InfinityFreeChallengeSolver.solveChallenge(multiBlockChallenge),
          '4e657453616c657320496e66696e69747946726565206368616c6c656e6765207265747279',
        );
      },
    );

    test(
      'matches SlowAES behavior when padding-like bytes are inconsistent',
      () {
        final inconsistentPaddingChallenge = challenge.replaceFirst(
          '25b509cc7dadcdb532275647f94524cc',
          '7faa7da20fa612dde3cf9b7f3331b50c',
        );

        // SlowAES cancels unpadding when the preceding byte is another value
        // in the 1..16 range; it must not strip only the final 0x0c byte.
        expect(
          InfinityFreeChallengeSolver.solveChallenge(
            inconsistentPaddingChallenge,
          ),
          '4142434445464748494a4b4c4d4e0d0c',
        );
      },
    );

    test(
      'removes a complete thirteen-byte SlowAES padding suffix',
      () {
        final paddedChallenge = challenge.replaceFirst(
          '25b509cc7dadcdb532275647f94524cc',
          '0216da59dd377dd41308e253403e5aed',
        );

        expect(
          InfinityFreeChallengeSolver.solveChallenge(paddedChallenge),
          '414243',
        );
      },
    );

    test(
      'matches SlowAES handling of a full zero-byte trailing block',
      () {
        final zeroBlockChallenge = challenge.replaceFirst(
          '25b509cc7dadcdb532275647f94524cc',
          '9b9a54eb2de11baef8f0060729ce78fb',
        );

        expect(
          InfinityFreeChallengeSolver.solveChallenge(zeroBlockChallenge),
          '',
        );
      },
    );

    test(
      'preserves unrelated cookies and replaces an existing challenge cookie',
      () {
        expect(
          InfinityFreeChallengeSolver.mergeChallengeCookie(
            existingCookieHeader:
                'laravel_session=session-value; __test=old-value; XSRF-TOKEN=csrf-value',
            challengeCookie: 'new-value',
          ),
          'laravel_session=session-value; XSRF-TOKEN=csrf-value; __test=new-value',
        );
      },
    );

    test(
      'adds the challenge cookie when no cookie header exists',
      () {
        expect(
          InfinityFreeChallengeSolver.mergeChallengeCookie(
            existingCookieHeader: null,
            challengeCookie: 'new-value',
          ),
          '__test=new-value',
        );
      },
    );

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
