-- Get user posts with details
SELECT u.username, u.email, p.title, p.content, p.created_at
FROM users u
JOIN posts p ON u.id = p.user_id
WHERE u.username = :username
ORDER BY p.created_at DESC;