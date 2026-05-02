import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:niche_find/services/niche_parser.dart';

void main() {
  const parser = NicheParser();

  group('NicheParser', () {
    test('parses clean JSON object with niches key', () {
      const raw = '''
      {
        "niches": [
          {
            "title": "AI prompt packs for recruiters",
            "description": "Curated prompt libraries for technical recruiters.",
            "demand": "High",
            "competition": "Low",
            "firstSteps": ["interview 5", "build 30 prompts", "ship pack"]
          }
        ]
      }
      ''';

      final result = parser.parse(raw);
      expect(result, hasLength(1));
      expect(result.first.title, 'AI prompt packs for recruiters');
      expect(result.first.demand, 'High');
      expect(result.first.firstSteps, hasLength(3));
    });

    test('parses fenced JSON', () {
      const raw = '''
```json
{
  "niches": [
    {
      "title": "Mobility for desk workers over 40",
      "description": "Short follow-along routines.",
      "demand": "High",
      "competition": "Medium",
      "firstSteps": ["film 5", "post weekly", "share in r/desksetup"]
    }
  ]
}
```
''';

      final result = parser.parse(raw);
      expect(result, hasLength(1));
      expect(result.first.title, 'Mobility for desk workers over 40');
    });

    test('parses JSON with leading and trailing commentary', () {
      const raw = '''
Sure! Here are some niches for you:

{
  "niches": [
    {
      "title": "Voice-control workflows for accessibility",
      "description": "Tutorials covering Voice Control on Apple devices.",
      "demand": "Medium",
      "competition": "Low",
      "firstSteps": ["record one feature per video", "caption everything"]
    }
  ]
}

Let me know if you want a different angle!
''';

      final result = parser.parse(raw);
      expect(result, hasLength(1));
      expect(result.first.title, contains('Voice-control'));
    });

    test('handles missing demand field gracefully', () {
      const raw = '''
      {
        "niches": [
          {
            "title": "Watercolor for absolute beginners over 60",
            "description": "Slow-paced lessons.",
            "competition": "Low",
            "firstSteps": ["film one", "build PDF", "Facebook group"]
          }
        ]
      }
      ''';

      final result = parser.parse(raw);
      expect(result, hasLength(1));
      expect(result.first.title, 'Watercolor for absolute beginners over 60');
      expect(result.first.demand, '-');
      expect(result.first.competition, 'Low');
    });

    test('parses array root', () {
      const raw = '''
      [
        {
          "title": "Vintage road bike maintenance",
          "description": "Step-by-step videos.",
          "demand": "Medium",
          "competition": "Low",
          "firstSteps": ["pick 5 repairs", "publish weekly"]
        }
      ]
      ''';

      final result = parser.parse(raw);
      expect(result, hasLength(1));
      expect(result.first.firstSteps, hasLength(2));
    });

    test('falls back to markdown parser when no JSON is present', () {
      const raw = '''
## Mindfulness for ICU nurses

Description: Short audio meditations designed for 5-minute breaks.
Demand: High
Competition: Low
First steps:
- Record 10 short meditations
- Pitch to nursing newsletters
- Offer a free starter pack

## Local SEO for trade businesses

Description: Practical checklists for plumbers and electricians.
Demand: High
Competition: Medium
First steps:
- Audit 5 trade websites
- Publish a Google Business checklist
''';

      final result = parser.parse(raw);
      expect(result, hasLength(2));
      expect(result.first.title, 'Mindfulness for ICU nurses');
      expect(result.first.demand, 'High');
      expect(result.first.firstSteps, hasLength(3));
    });

    test('throws NicheParseException on unparseable garbage', () {
      const raw = 'totally not json or markdown sections';
      expect(
        () => parser.parse(raw),
        throwsA(isA<NicheParseException>()),
      );
    });

    test('throws NicheParseException on empty response', () {
      expect(
        () => parser.parse('   '),
        throwsA(isA<NicheParseException>()),
      );
    });

    test('all 10 sample fixtures parse to non-empty NicheSuggestion lists',
        () {
      final dir = Directory('docs/samples');
      expect(
        dir.existsSync(),
        isTrue,
        reason: 'docs/samples directory should exist',
      );

      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.md'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      expect(
        files.length,
        greaterThanOrEqualTo(10),
        reason: 'expected at least 10 sample fixtures',
      );

      for (final file in files) {
        final raw = file.readAsStringSync();
        final result = parser.parse(raw);
        expect(
          result,
          isNotEmpty,
          reason: 'sample ${file.uri.pathSegments.last} produced no niches',
        );
        for (final n in result) {
          expect(n.title, isNotEmpty);
        }
      }
    });
  });
}
