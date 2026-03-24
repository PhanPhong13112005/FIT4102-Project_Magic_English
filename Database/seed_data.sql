-- Magic English Seed Data (PostgreSQL Version)

-- Chèn người dùng mẫu
INSERT INTO "Users" (Id, Name, Email, CreatedAt) VALUES
(1, 'John Doe', 'john@example.com', CURRENT_TIMESTAMP),
(2, 'Jane Smith', 'jane@example.com', CURRENT_TIMESTAMP),
(3, 'Mike Johnson', 'mike@example.com', CURRENT_TIMESTAMP);

-- Reset lại giá trị Serial của Id để không bị trùng
SELECT setval(pg_get_serial_sequence('"Users"', 'id'), (SELECT MAX(Id) FROM "Users"));

-- Chèn từ vựng mẫu cho User 1
INSERT INTO Vocabularies (UserId, Word, IPA, Meaning, PartOfSpeech, Example, CEFRLevel, CreatedAt)
VALUES
(1, 'Serendipity', '/ˌserənˈdɪpɪti/', 'Sự tình cờ may mắn', 'Noun', 'Finding that old photo was pure serendipity.', 'C1', CURRENT_TIMESTAMP),
(1, 'Eloquent', '/ˈeləkwənt/', 'Nói chuyện lưu loát', 'Adjective', 'The speaker gave an eloquent presentation.', 'B2', CURRENT_TIMESTAMP);

-- Chèn dữ liệu Streak
INSERT INTO Streaks (UserId, CurrentStreak, LongestStreak, LastStudyDate)
VALUES
(1, 15, 20, CURRENT_TIMESTAMP),
(2, 5, 10, CURRENT_TIMESTAMP);

-- Vòng lặp tạo hoạt động học tập 30 ngày qua (Postgres DO block)
DO $$
DECLARE
    i INT := 0;
BEGIN
    WHILE i < 30 LOOP
        INSERT INTO StudyActivities (UserId, ActivityType, CreatedAt)
        VALUES (1, 'Vocabulary', CURRENT_TIMESTAMP - (i || ' days')::interval);
        i := i + 1;
    END LOOP;
END $$;