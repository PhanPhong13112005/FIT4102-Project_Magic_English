# AI Prompt Engineering - Magic English

## Overview

Magic English uses Ollama Cloud API to power two core features:
1. **Vocabulary Enrichment** - Extract word information
2. **Grammar Checking** - Analyze and improve text

This document details the exact prompts and response handling.

---

## Part 1: Vocabulary Enrichment

### Purpose

When a user adds a new English word, the system calls Ollama API to automatically enrich it with:
- IPA (International Phonetic Alphabet)
- Vietnamese meaning
- Part of speech
- Example sentence
- CEFR level (A1-C2)

### Prompt Design

#### The Prompt Template

```
You are an expert English teacher helping students learn vocabulary. 

Provide vocabulary information for the English word: "{WORD}"

Return ONLY a JSON object with these exact fields (no markdown, no code blocks):
{
  "word": "{WORD}",
  "ipa": "",
  "meaning": "",
  "partOfSpeech": "",
  "example": "",
  "cefrLevel": ""
}

Fill each field with accurate information:
- ipa: International Phonetic Alphabet pronunciation
- meaning: Vietnamese translation
- partOfSpeech: noun, verb, adjective, adverb, preposition, etc.
- example: Example sentence using the word
- cefrLevel: CEFR level (A1, A2, B1, B2, C1, C2)

Return only the JSON object, nothing else.
```

### Examples

#### Example 1: Simple Word

**Input Word:** "Serendipity"

**System Prompt:**
```
You are an expert English teacher helping students learn vocabulary. 

Provide vocabulary information for the English word: "Serendipity"

Return ONLY a JSON object...
```

**Expected Response:**
```json
{
  "word": "Serendipity",
  "ipa": "/ˌserənˈdɪpɪti/",
  "meaning": "Sự tình cờ may mắn; may mắn bất ngờ",
  "partOfSpeech": "noun",
  "example": "Finding that old photo was pure serendipity; it brought back wonderful memories.",
  "cefrLevel": "C1"
}
```

#### Example 2: Verb

**Input Word:** "Ameliorate"

**Expected Response:**
```json
{
  "word": "Ameliorate",
  "ipa": "/əˈmiːlɪəreɪt/",
  "meaning": "Cải thiện, làm tốt hơn",
  "partOfSpeech": "verb",
  "example": "The government implemented policies to ameliorate the living conditions of poor citizens.",
  "cefrLevel": "C2"
}
```

#### Example 3: Adjective

**Input Word:** "Pragmatic"

**Expected Response:**
```json
{
  "word": "Pragmatic",
  "ipa": "/praɡˈmatɪk/",
  "meaning": "Thực tế, thiết thực",
  "partOfSpeech": "adjective",
  "example": "We need a pragmatic approach to solve this problem, not an idealistic one.",
  "cefrLevel": "B2"
}
```

### CEFR Level Guidelines

| Level | Proficiency | Vocabulary Type | Examples |
|-------|-------------|-----------------|----------|
| A1 | Beginner | Basic, common | cat, run, happy |
| A2 | Elementary | Simple, everyday | restaurant, vacation, difficult |
| B1 | Intermediate | More complex | environmental, organize, convenient |
| B2 | Upper Int. | Advanced | eloquent, comprehensive, feasible |
| C1 | Advanced | Very complex | quintessential, ubiquitous, ephemeral |
| C2 | Mastery | Rare, sophisticated | serendipity, ameliorate, cacophony |

### Response Parsing

The backend parses the JSON response:

```csharp
var jsonElement = JsonSerializer.Deserialize<JsonElement>(response);

var vocabulary = new OllamaVocabularyResponse
{
    Word = jsonElement.GetProperty("word").GetString(),
    IPA = jsonElement.GetProperty("ipa").GetString(),
    Meaning = jsonElement.GetProperty("meaning").GetString(),
    PartOfSpeech = jsonElement.GetProperty("partOfSpeech").GetString(),
    Example = jsonElement.GetProperty("example").GetString(),
    CEFRLevel = jsonElement.GetProperty("cefrLevel").GetString()
};
```

### Common Issues & Solutions

**Issue: Response includes markdown formatting**
```
```json
{ "word": "..." }
```
```

**Solution:** Prompt explicitly states: "Return ONLY a JSON object (no markdown, no code blocks)"

**Issue: Extra text before/after JSON**

**Solution:** Backend includes cleanup logic:
```csharp
if (cleanedResponse.StartsWith("```json"))
    cleanedResponse = cleanedResponse["```json".Length..];
```

---

## Part 2: Grammar Checking

### Purpose

When user inputs text, the system calls Ollama API to:
- Calculate grammar score (0-10)
- Identify errors (Grammar, Spelling, Style)
- Provide suggestions for improvement

### Prompt Design

#### The Prompt Template

```
You are an expert English grammar checker. Analyze the following text for grammar, spelling, and style errors.

Text to check: "{TEXT}"

Return ONLY a JSON object with these exact fields (no markdown, no code blocks):
{
  "score": 0,
  "errors": [
    {
      "type": "",
      "description": "",
      "position": 0,
      "suggestedFix": ""
    }
  ],
  "suggestions": []
}

Guidelines:
- score: A number from 0 to 10 (10 = perfect English)
- errors: Array of grammar, spelling, or style errors found
  - type: 'Grammar', 'Spelling', or 'Style'
  - description: Description of the error
  - position: Character position where error occurs
  - suggestedFix: How to correct the error
- suggestions: Array of general improvement suggestions

If the text is correct, return score 10 with empty errors and suggestions arrays.

Return only the JSON object, nothing else.
```

### Examples

#### Example 1: Grammar Error

**Input Text:**
```
She go to the store yesterday.
```

**Expected Response:**
```json
{
  "score": 7.0,
  "errors": [
    {
      "type": "Grammar",
      "description": "Subject-verb agreement error. Third person singular requires 'goes', not 'go'",
      "position": 4,
      "suggestedFix": "goes"
    }
  ],
  "suggestions": [
    "Check verb conjugation for third person singular subjects",
    "Use past tense verbs consistently with time indicators like 'yesterday'"
  ]
}
```

#### Example 2: Multiple Errors

**Input Text:**
```
The cat sitting on the mat and look very happy yesterday.
```

**Expected Response:**
```json
{
  "score": 5.0,
  "errors": [
    {
      "type": "Grammar",
      "description": "Missing auxiliary verb for continuous tense",
      "position": 8,
      "suggestedFix": "is sitting"
    },
    {
      "type": "Grammar",
      "description": "Tense inconsistency - mix of present continuous and past tense",
      "position": 39,
      "suggestedFix": "looked"
    }
  ],
  "suggestions": [
    "Maintain consistent tense throughout the sentence",
    "Use 'was' or 'were' with past continuous action",
    "Review subject-verb agreement"
  ]
}
```

#### Example 3: Correct English

**Input Text:**
```
She went to the store yesterday and bought some groceries.
```

**Expected Response:**
```json
{
  "score": 10.0,
  "errors": [],
  "suggestions": []
}
```

#### Example 4: Style Suggestions

**Input Text:**
```
I think that the thing that happened yesterday was bad.
```

**Expected Response:**
```json
{
  "score": 7.5,
  "errors": [],
  "suggestions": [
    "Avoid repetitive use of 'that' - consider restructuring: 'The incident yesterday was unfortunate'",
    "Replace vague words like 'bad' with more specific descriptors",
    "Use active voice for stronger expression",
    "Consider: 'Yesterday's unfortunate incident...' for more sophisticated expression"
  ]
}
```

### Error Type Definitions

| Type | Definition | Example |
|------|-----------|---------|
| **Grammar** | Syntax, verb conjugation, agreement errors | "She go" → "She goes" |
| **Spelling** | Misspelled words, typos | "recieve" → "receive" |
| **Style** | Clarity, conciseness, word choice | Weak expressions, repetition |

### Scoring Scale

| Score | Meaning | Feedback Level |
|-------|---------|-----------------|
| 9-10 | Excellent | Minimal or no suggestions |
| 7-8 | Good | Minor improvements suggested |
| 5-6 | Fair | Several errors identified |
| 3-4 | Poor | Multiple significant errors |
| 0-2 | Very Poor | Severe comprehension issues |

### Response Parsing

```csharp
var jsonElement = JsonSerializer.Deserialize<JsonElement>(response);

var errors = new List<GrammarErrorDetail>();
foreach (var error in jsonElement.GetProperty("errors").EnumerateArray())
{
    errors.Add(new GrammarErrorDetail
    {
        Type = error.GetProperty("type").GetString(),
        Description = error.GetProperty("description").GetString(),
        Position = error.GetProperty("position").GetInt32(),
        SuggestedFix = error.GetProperty("suggestedFix").GetString()
    });
}

var suggestions = new List<string>();
foreach (var suggestion in jsonElement.GetProperty("suggestions").EnumerateArray())
{
    suggestions.Add(suggestion.GetString());
}

return new OllamaGrammarResponse
{
    Score = jsonElement.GetProperty("score").GetDouble(),
    Errors = errors,
    Suggestions = suggestions
};
```

---

## Part 3: API Configuration

### Ollama Cloud API Settings

**Base URL:**
```
https://api.ollamcloud.com/api
```

**Endpoint:**
```
POST /generate
```

**Request Format:**
```json
{
  "model": "llama2:13b",
  "prompt": "Your prompt here",
  "stream": false
}
```

**Headers:**
```
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json
```

### Model Selection

#### Vocabulary Enrichment Model
- **Model**: `llama2:13b`
- **Reasoning**: Good factual accuracy, efficient
- **Alternative**: `neural-chat-7b` (faster, slightly less accurate)

#### Grammar Checking Model
- **Model**: `llama2:13b`
- **Reasoning**: Good at analyzing text structure and syntax
- **Alternative**: `mistral-7b` (faster, specialized models available)

### Timeout Settings

- **Vocabulary**: 30 seconds (usually returns in 5-15 seconds)
- **Grammar**: 30 seconds (depends on text length)
- **Total Request**: 60 seconds

---

## Part 4: Best Practices

### Do's ✓

1. **Use clear, structured prompts**
   ```
   - Specify the task clearly
   - Define output format precisely
   - Include examples when helpful
   ```

2. **Request JSON output**
   ```
   - Always specify JSON format
   - Don't use markdown
   - Include field definitions
   ```

3. **Handle responses robustly**
   ```
   - Clean markdown formatting
   - Validate JSON structure
   - Provide fallbacks
   ```

4. **Optimize for accuracy**
   ```
   - Use appropriate models
   - Include context in prompts
   - Test with diverse inputs
   ```

### Don'ts ✗

1. **Avoid ambiguous prompts**
   - ❌ "Analyze this word"
   - ✓ "Provide vocabulary information with IPA..."

2. **Don't expect perfect JSON**
   - ❌ Assume clean response
   - ✓ Clean markdown/code blocks

3. **Don't ignore edge cases**
   - ❌ Assume every word is in English
   - ✓ Validate and handle errors

4. **Don't overload with requests**
   - ❌ Batch multiple words in one prompt
   - ✓ Process individually

---

## Testing Prompts Locally

### Using Ollama CLI

```bash
# For vocabulary
ollama run llama2:13b "You are an expert English teacher..."

# For grammar
ollama run llama2:13b "You are an expert English grammar checker..."
```

### Using API Call

```bash
curl -X POST https://api.ollamcloud.com/api/generate \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama2:13b",
    "prompt": "Your prompt here",
    "stream": false
  }'
```

---

## Monitoring & Optimization

### Track Performance

- **API Response Time**: Target < 15 seconds
- **Success Rate**: Target > 95%
- **JSON Validity**: 100%

### Cost Optimization

- Cache common words
- Batch requests when possible
- Use faster models for high-volume tasks

### Quality Assurance

- Test with diverse vocabulary levels
- Verify grammar corrections
- A/B test model versions

---

**Prompt Engineering Guide Version:** 1.0  
**Last Updated:** March 11, 2024  
**Ollama Cloud API**: https://ollama.cloud
