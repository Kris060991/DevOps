CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

INSERT INTO users (name, email) VALUES
('Иван', 'ivan@test.ru'),
('Анна', 'anna@test.ru'),
('Максим', 'max@test.ru');

SELECT * FROM users;