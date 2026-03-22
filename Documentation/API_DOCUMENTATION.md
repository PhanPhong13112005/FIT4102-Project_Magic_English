# Magic English API Documentation

## Overview

The Magic English API is a RESTful web service built with .NET 8 that provides endpoints for vocabulary management, grammar checking, and learning statistics.

## Base URL

```
http://localhost:5000/api/v1
```

---

## Authentication

Currently, the API does not require authentication. All endpoints are publicly available. In a production environment, implement JWT authentication.

---

## API Endpoints

### Users Management

#### 1. Create User
**POST** `/users`

Create a new user account.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "createdAt": "2024-03-11T10:30:00Z"
}
```

**Error Responses:**
- `400 Bad Request` - Invalid input
- `409 Conflict` - Email already exists

---

#### 2. Get User
**GET** `/users/{id}`

Retrieve user information by ID.

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "createdAt": "2024-03-11T10:30:00Z"
}
```

**Error Responses:**
- `404 Not Found` - User not found

---

#### 3. Get User by Email
**GET** `/users/search/email/{email}`

Retrieve user information by email address.

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "createdAt": "2024-03-11T10:30:00Z"
}
```

---

#### 4. List All Users
**GET** `/users`

Retrieve all users (pagination in future versions).

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2024-03-11T10:30:00Z"
  }
]
```

---

#### 5. Update User
**PUT** `/users/{id}`

Update user information.

**Request Body:**
```json
{
  "name": "Jane Doe",
  "email": "jane@example.com"
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Jane Doe",
  "email": "jane@example.com",
  "createdAt": "2024-03-11T10:30:00Z"
}
```

---

### Vocabulary Management

#### 1. Add Vocabulary
**POST** `/vocabulary/add`

Add a new word to the user's vocabulary notebook. The system calls Ollama AI to enrich the word data.

**Query Parameters:**
- `userId` (required): User ID

**Request Body:**
```json
{
  "word": "Serendipity"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "word": "Serendipity",
  "ipa": "/ˌserənˈdɪpɪti/",
  "meaning": "Sự tình cờ may mắn",
  "partOfSpeech": "Noun",
  "example": "Finding that old photo was pure serendipity.",
  "cefrLevel": "C1",
  "createdAt": "2024-03-11T10:30:00Z",
  "lastReviewedAt": null,
  "reviewCount": 0
}
```

**Error Responses:**
- `400 Bad Request` - Word is required
- `404 Not Found` - User not found

---

#### 2. Get Vocabulary List
**GET** `/vocabulary/list`

Retrieve all vocabularies for a user.

**Query Parameters:**
- `userId` (required): User ID

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "word": "Serendipity",
    "ipa": "/ˌserənˈdɪpɪti/",
    "meaning": "Sự tình cờ may mắn",
    "partOfSpeech": "Noun",
    "example": "Finding that old photo was pure serendipity.",
    "cefrLevel": "C1",
    "createdAt": "2024-03-11T10:30:00Z",
    "lastReviewedAt": null,
    "reviewCount": 0
  }
]
```

---

#### 3. Search Vocabulary
**GET** `/vocabulary/search`

Search vocabularies by word, meaning, or example.

**Query Parameters:**
- `userId` (required): User ID
- `query` (required): Search term

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "word": "Serendipity",
    "ipa": "/ˌserənˈdɪpɪti/",
    "meaning": "Sự tình cờ may mắn",
    "partOfSpeech": "Noun",
    "example": "Finding that old photo was pure serendipity.",
    "cefrLevel": "C1",
    "createdAt": "2024-03-11T10:30:00Z",
    "lastReviewedAt": null,
    "reviewCount": 0
  }
]
```

---

#### 4. Get Vocabulary Statistics
**GET** `/vocabulary/statistics`

Get vocabulary statistics for a user.

**Query Parameters:**
- `userId` (required): User ID

**Response (200 OK):**
```json
{
  "totalWords": 15,
  "partOfSpeechDistribution": {
    "Noun": 5,
    "Verb": 4,
    "Adjective": 6
  },
  "cefrLevelDistribution": {
    "A1": 2,
    "A2": 3,
    "B1": 5,
    "B2": 4,
    "C1": 1,
    "C2": 0
  }
}
```

---

#### 5. Delete Vocabulary
**DELETE** `/vocabulary/{id}`

Delete a vocabulary entry.

**Response (204 No Content)**

**Error Responses:**
- `404 Not Found` - Vocabulary not found

---

### Grammar Checking

#### 1. Check Grammar
**POST** `/grammar/check`

Check grammar of a text using Ollama AI.

**Query Parameters:**
- `userId` (required): User ID

**Request Body:**
```json
{
  "text": "She go to the store yesterday."
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "originalText": "She go to the store yesterday.",
  "score": 7.0,
  "errors": [
    {
      "type": "Grammar",
      "description": "Subject-verb agreement error",
      "position": 4,
      "suggestedFix": "goes"
    }
  ],
  "suggestions": [
    "Use correct verb form for third person singular",
    "Check tense consistency"
  ],
  "createdAt": "2024-03-11T10:30:00Z"
}
```

**Error Responses:**
- `400 Bad Request` - Text is required
- `404 Not Found` - User not found

---

#### 2. Get Grammar History
**GET** `/grammar/history`

Retrieve grammar check history for a user.

**Query Parameters:**
- `userId` (required): User ID
- `pageSize` (optional, default: 10): Number of records to return

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "originalText": "She go to the store yesterday.",
    "score": 7.0,
    "errors": [...],
    "suggestions": [...],
    "createdAt": "2024-03-11T10:30:00Z"
  }
]
```

---

#### 3. Get Specific Grammar Check
**GET** `/grammar/{id}`

Retrieve a specific grammar check result.

**Response (200 OK):**
```json
{
  "id": 1,
  "originalText": "She go to the store yesterday.",
  "score": 7.0,
  "errors": [...],
  "suggestions": [...],
  "createdAt": "2024-03-11T10:30:00Z"
}
```

---

### Statistics & Dashboard

#### 1. Get Dashboard
**GET** `/statistics/dashboard`

Get complete dashboard data for a user.

**Query Parameters:**
- `userId` (required): User ID

**Response (200 OK):**
```json
{
  "totalVocabularyLearned": 15,
  "currentStreak": 5,
  "todayActivityCount": 2,
  "streak": {
    "id": 1,
    "currentStreak": 5,
    "longestStreak": 15,
    "lastStudyDate": "2024-03-11T10:30:00Z",
    "has3DaysBadge": true,
    "has7DaysBadge": false,
    "has30DaysBadge": false
  },
  "vocabularyStats": {...},
  "activityTrend": [...]
}
```

---

#### 2. Get Streak
**GET** `/statistics/streak`

Get user's streak information.

**Query Parameters:**
- `userId` (required): User ID

**Response (200 OK):**
```json
{
  "id": 1,
  "currentStreak": 5,
  "longestStreak": 15,
  "lastStudyDate": "2024-03-11T10:30:00Z",
  "has3DaysBadge": true,
  "has7DaysBadge": false,
  "has30DaysBadge": false
}
```

---

#### 3. Get Activity Trend
**GET** `/statistics/activity-trend`

Get daily activity trend for last N days.

**Query Parameters:**
- `userId` (required): User ID
- `days` (optional, default: 30): Number of days to retrieve (1-365)

**Response (200 OK):**
```json
[
  {
    "date": "2024-03-01",
    "vocabularyCount": 2,
    "grammarCount": 1,
    "totalCount": 3
  },
  {
    "date": "2024-03-02",
    "vocabularyCount": 0,
    "grammarCount": 0,
    "totalCount": 0
  }
]
```

---

## Error Response Format

All error responses follow this format:

```json
{
  "message": "Error description here"
}
```

**HTTP Status Codes:**
- `200 OK` - Successful request
- `201 Created` - Resource created successfully
- `204 No Content` - Successful deletion (no content in response)
- `400 Bad Request` - Invalid input
- `404 Not Found` - Resource not found
- `409 Conflict` - Resource conflict (e.g., duplicate email)
- `500 Internal Server Error` - Server error

---

## Rate Limiting

Currently, there is no rate limiting. Implement in production.

---

## Pagination

Pagination will be implemented in future versions. Currently, `pageSize` parameters are supported for some endpoints.

---

## CORS

The API allows requests from any origin for development purposes. Restrict in production.

**Headers:**
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS`
- `Access-Control-Allow-Headers: Content-Type`

---

## Swagger Documentation

Access interactive API documentation at:
```
http://localhost:5000/swagger/index.html
```

---

## Implementation Notes

- All timestamps are in UTC format (ISO 8601)
- JSON in request/response bodies
- Vocabulary enrichment powered by Ollama AI
- Grammar checking powered by Ollama AI
- Streak updates automatically on each activity
- Study activities tracked for analytics

---

**API Version:** v1  
**Last Updated:** March 11, 2024
