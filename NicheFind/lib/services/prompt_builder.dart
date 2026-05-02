import '../models/niche_suggestion.dart';
import '../models/questionnaire_data.dart';

class PromptBuilder {
  String buildSystemPrompt() {
    return '''
You are NicheFind, an assistant that helps creators discover specific niches
for YouTube channels, blogs, online stores or digital products.

Respond with a single JSON object only. No prose. No markdown fences.

Schema:
{
  "niches": [
    {
      "title": "short niche name, max 6 words",
      "description": "1-2 sentences explaining who it serves and why it works",
      "demand": "Low" | "Medium" | "High",
      "competition": "Low" | "Medium" | "High",
      "firstSteps": ["step 1", "step 2", "step 3"]
    }
  ]
}

Rules:
- Return between 3 and 5 niches.
- Niches must be specific (not "fitness" but "mobility routines for desk workers over 40").
- Stay realistic for the user's skill level and weekly time commitment.
- Vary angles across the list (different audiences, formats, or sub-topics).
''';
  }

  String buildUserPrompt(QuestionnaireData data) {
    final json = data.toJson();
    final interests = (json['interests'] as List).join(', ');
    final notes = (json['additionalNotes'] as String).trim();
    final notesLine = notes.isEmpty ? '(none)' : notes;

    return '''
Find 3-5 niches for this creator.

- Interests: $interests
- Goal: ${json['goal']}
- Skill level: ${json['skillLevel']}
- Weekly time commitment: ${json['timeCommitment']}
- Extra notes: $notesLine

Return JSON only, matching the schema in the system message.
''';
  }

  String buildRefinementPrompt(String userFeedback) {
    return 'Refine the previous niches with this feedback: "$userFeedback". '
        'Keep the same JSON schema.';
  }

  String buildRegeneratePrompt(List<NicheSuggestion> previousResults) {
    if (previousResults.isEmpty) {
      return 'Provide a different set of niches than the obvious ones. '
          'Vary the angles and combinations.';
    }
    final titles = previousResults.map((n) => '- ${n.title}').join('\n');
    return '''
Provide a brand-new set of niches. Do NOT repeat or rephrase any of these
previously suggested titles:
$titles

Pick different audiences, formats, or sub-topics.
Keep the same JSON schema.
''';
  }
}
