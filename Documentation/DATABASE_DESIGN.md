# Database Design - Magic English

## Overview

The Magic English database is designed using a relational model with SQL Server 2019+, optimized for learning analytics and user activity tracking.

---

## Entity Relationship Diagram

```
┌─────────────┐
│   Users     │
│─────────────│
│ Id (PK)     │────┐
│ Name        │    │
│ Email       │    │
│ CreatedAt   │    │
└─────────────┘    │
                   │ 1:N
                   ├────────────────────┬──────────────┬────────────────┐
                   │                    │              │                │
                   ▼                    ▼              ▼                ▼
            ┌─────────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐
            │  Vocabularies   │  │ GrammarCheck │  │ StudyActivity│  │   Streaks   │
            │─────────────────│  │──────────────│  │──────────────│  │─────────────│
            │ Id (PK)         │  │ Id (PK)      │  │ Id (PK)      │  │ Id (PK)     │
            │ UserId (FK)     │  │ UserId (FK)  │  │ UserId (FK)  │  │ UserId (FK) │
            │ Word            │  │ OriginalText │  │ ActivityType │  │ CurrentStr  │
            │ IPA             │  │ Score        │  │ CreatedAt    │  │ LongestStr  │
            │ Meaning         │  │ Errors       │  │              │  │ Badges      │
            │ PartOfSpeech    │  │ Suggestions  │  └──────────────┘  │ LastStudyD  │
            │ Example         │  │ CreatedAt    │                     │ CreatedAt   │
            │ CEFRLevel       │  └──────────────┘                     │ UpdatedAt   │
            │ CreatedAt       │                                        └─────────────┘
            │ ReviewCount     │
            └─────────────────┘
```

---

## Table Specifications

### 1. Users Table

Stores user account information.

| Column | Type | Constraint | Description |
|--------|------|-----------|-------------|
| **Id** | INT | PRIMARY KEY, IDENTITY | Unique user identifier |
| **Name** | NVARCHAR(100) | NOT NULL | User's full name |
| **Email** | NVARCHAR(256) | NOT NULL, UNIQUE | User's email address (unique) |
| **CreatedAt** | DATETIME2 | DEFAULT GETUTCDATE() | Account creation timestamp |

**Indexes:**
- Primary Key: `Id`
- Unique Index: `Email`

---

### 2. Vocabularies Table

Stores vocabulary words with AI-enriched data.

| Column | Type | Constraint | Description |
|--------|------|-----------|-------------|
| **Id** | INT | PRIMARY KEY, IDENTITY | Vocabulary entry ID |
| **UserId** | INT | FOREIGN KEY, NOT NULL | Reference to Users table |
| **Word** | NVARCHAR(100) | NOT NULL | English word |
| **IPA** | NVARCHAR(100) | NULL | International Phonetic Alphabet |
| **Meaning** | NVARCHAR(500) | NOT NULL | Vietnamese translation |
| **PartOfSpeech** | NVARCHAR(50) | NULL | Grammar type (noun, verb, etc.) |
| **Example** | NVARCHAR(500) | NULL | Example sentence |
| **CEFRLevel** | NVARCHAR(2) | DEFAULT 'A1' | CEFR proficiency level |
| **CreatedAt** | DATETIME2 | DEFAULT GETUTCDATE() | Entry creation time |
| **LastReviewedAt** | DATETIME2 | NULL | Last review timestamp |
| **ReviewCount** | INT | DEFAULT 0 | Number of times reviewed |

**Indexes:**
- Primary Key: `Id`
- Foreign Key: `UserId` (ON DELETE CASCADE)
- Index: `UserId`
- Index: `CreatedAt`
- Index: `CEFRLevel`

**CEFR Levels:**
- A1: Beginner
- A2: Elementary
- B1: Intermediate
- B2: Upper Intermediate
- C1: Advanced
- C2: Mastery

---

### 3. GrammarChecks Table

Stores grammar checking results from Ollama AI.

| Column | Type | Constraint | Description |
|--------|------|-----------|-------------|
| **Id** | INT | PRIMARY KEY, IDENTITY | Check result ID |
| **UserId** | INT | FOREIGN KEY, NOT NULL | Reference to Users table |
| **OriginalText** | NVARCHAR(2000) | NOT NULL | Text checked |
| **Score** | DECIMAL(5,2) | NOT NULL | Score (0-10) |
| **Errors** | NVARCHAR(MAX) | NULL | JSON array of errors |
| **Suggestions** | NVARCHAR(MAX) | NULL | JSON array of suggestions |
| **CreatedAt** | DATETIME2 | DEFAULT GETUTCDATE() | Check timestamp |

**Indexes:**
- Primary Key: `Id`
- Foreign Key: `UserId` (ON DELETE CASCADE)
- Index: `UserId`
- Index: `CreatedAt`

**Error JSON Schema:**
```json
[
  {
    "type": "Grammar|Spelling|Style",
    "description": "Error description",
    "position": 0,
    "suggestedFix": "Suggested correction"
  }
]
```

---

### 4. StudyActivities Table

Tracks user study activities for streak calculation and analytics.

| Column | Type | Constraint | Description |
|--------|------|-----------|-------------|
| **Id** | INT | PRIMARY KEY, IDENTITY | Activity ID |
| **UserId** | INT | FOREIGN KEY, NOT NULL | Reference to Users table |
| **ActivityType** | NVARCHAR(50) | NOT NULL | 'Vocabulary' or 'Grammar' |
| **CreatedAt** | DATETIME2 | DEFAULT GETUTCDATE() | Activity timestamp |

**Indexes:**
- Primary Key: `Id`
- Foreign Key: `UserId` (ON DELETE CASCADE)
- Index: `UserId`
- Index: `CreatedAt`
- Composite Index: `(UserId, CreatedAt)`

---

### 5. Streaks Table

Stores streak and badge information per user.

| Column | Type | Constraint | Description |
|--------|------|-----------|-------------|
| **Id** | INT | PRIMARY KEY, IDENTITY | Streak record ID |
| **UserId** | INT | FOREIGN KEY, UNIQUE, NOT NULL | Reference to Users (1:1) |
| **CurrentStreak** | INT | DEFAULT 0 | Current consecutive days |
| **LongestStreak** | INT | DEFAULT 0 | Longest streak achieved |
| **LastStudyDate** | DATETIME2 | DEFAULT GETUTCDATE() | Last study date |
| **Badge3Days** | INT | DEFAULT 0 | 3-day badge (0/1) |
| **Badge7Days** | INT | DEFAULT 0 | 7-day badge (0/1) |
| **Badge30Days** | INT | DEFAULT 0 | 30-day badge (0/1) |
| **CreatedAt** | DATETIME2 | DEFAULT GETUTCDATE() | Record creation |
| **UpdatedAt** | DATETIME2 | DEFAULT GETUTCDATE() | Last update |

**Indexes:**
- Primary Key: `Id`
- Foreign Key: `UserId` (1:1, ON DELETE CASCADE, UNIQUE)
- Index: `UserId`

---

## Views

### vw_UserStatistics

Summary statistics per user.

```sql
SELECT 
    u.Id,
    u.Name,
    u.Email,
    COUNT(DISTINCT v.Id) AS TotalVocabulary,
    COUNT(DISTINCT gc.Id) AS TotalGrammarChecks,
    s.CurrentStreak,
    s.LongestStreak,
    u.CreatedAt
```

---

### vw_DailyActivity

Activities grouped by date per user.

```sql
SELECT 
    UserId,
    CAST(CreatedAt AS DATE) AS ActivityDate,
    SUM(CASE WHEN ActivityType = 'Vocabulary' THEN 1 ELSE 0 END) AS VocabularyCount,
    SUM(CASE WHEN ActivityType = 'Grammar' THEN 1 ELSE 0 END) AS GrammarCount,
    COUNT(*) AS TotalActivities
```

---

### vw_CEFRDistribution

CEFR level statistics per user.

```sql
SELECT 
    UserId,
    CEFRLevel,
    COUNT(*) AS WordCount
```

---

### vw_PartOfSpeechDistribution

Part of speech statistics per user.

```sql
SELECT 
    UserId,
    PartOfSpeech,
    COUNT(*) AS WordCount
```

---

## Constraints & Relationships

### Primary Keys
- Each table has an `Id` column as primary key with IDENTITY

### Foreign Keys
- **Vocabularies.UserId** → Users.Id (CASCADE DELETE)
- **GrammarChecks.UserId** → Users.Id (CASCADE DELETE)
- **StudyActivities.UserId** → Users.Id (CASCADE DELETE)
- **Streaks.UserId** → Users.Id (UNIQUE, CASCADE DELETE)

### Unique Constraints
- Users.Email
- Streaks.UserId (1:1 relationship)

### Default Values
- CreatedAt: `GETUTCDATE()` (current UTC time)
- UpdatedAt: `GETUTCDATE()` (for Streaks)
- CEFRLevel: `'A1'`
- All counters: `0`

---

## Data Integrity

1. **Referential Integrity**: Foreign key constraints prevent orphaned records
2. **Cascade Delete**: Deleting a user deletes all related records
3. **Unique Email**: Prevents duplicate user accounts
4. **Data Types**: 
   - Names/Text: NVARCHAR for Unicode support
   - JSON Data: NVARCHAR(MAX) for flexibility
   - Decimals: DECIMAL(5,2) for scores (0-10)

---

## Indexing Strategy

**Indexes created for:**
- User lookup by email (Email search)
- Vocabulary lookup by user (UserId queries)
- Activity filtering by date (CreatedAt ranges)
- Combined lookups (UserId + CreatedAt)

**Expected Query Patterns:**
- Get user vocabularies → UserId index
- Get today's activities → (UserId, CreatedAt) composite
- Find user by email → Email unique index
- Grammar history → UserId + CreatedAt

---

## Performance Considerations

1. **Pagination**: Implement for Vocabulary and GrammarChecks lists
2. **Indexes**: Composite indexes on frequently queried column combinations
3. **Archive**: Consider archiving old grammar checks (>1 year)
4. **Materialized Views**: For heavy analytics queries

---

## Backup & Recovery

- **Backup Frequency**: Daily
- **Recovery Point**: Should be < 1 hour
- **Retention**: 30 days minimum
- **Test Recovery**: Monthly

---

## Database Size Estimates

For 10,000 users:
- Users: 1 MB
- Vocabularies: 150 MB (average 15,000 words per user)
- GrammarChecks: 200 MB (average 20,000 checks per user)
- StudyActivities: 500 MB (high volume)
- **Total**: ~850 MB (minimal)

---

**Database Version**: SQL Server 2019+  
**Design Date**: March 2024  
**Last Updated**: March 11, 2024
