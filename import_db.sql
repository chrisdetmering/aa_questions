
DROP TABLE IF EXISTS questions_follow;
DROP TABLE IF EXISTS questions_like;
DROP TABLE IF EXISTS replies; 
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;


PRAGMA foreign_keys = ON;

-- USERS 

CREATE TABLE users (
  id INTEGER PRIMARY KEY, 
  fname VARCHAR(255) NOT NULL, 
  lname VARCHAR(255) NOT NULL 
); 

-- INSERT USERS  

INSERT INTO 
  users (fname, lname) 
VALUES 
  ("Ned", "Ruggeri"), 
  ("Kush", "Patel"), 
  ("Earl", "Cat"); 




--  QUESTIONS  

CREATE TABLE questions ( 
  id INTEGER PRIMARY KEY, 
  title VARCHAR(255) NOT NULL, 
  body VARCHAR(255) NOT NULL,
  author_id INTEGER NOT NULL UNIQUE, 

  FOREIGN KEY (author_id) REFERENCES users(id)
); 

-- INSERT QUESTIONS 

INSERT INTO 
  questions (title, body, author_id)
SELECT  
  "Ned Question", "NED NED NED", users.id 
FROM 
  users 
WHERE 
  users.fname = "Ned" AND users.lname = "Ruggeri"; 

INSERT INTO 
  questions (title, body, author_id)
SELECT  
  "Kush Question", "KUSH KUSH K", users.id 
FROM 
  users 
WHERE 
  users.fname = "Kush" AND users.lname = "Patel"; 

INSERT INTO 
  questions (title, body, author_id)
SELECT  
  "Earl Question", "MEOW MEOW M", users.id 
FROM 
  users 
WHERE 
  users.fname = "Earl" AND users.lname = "Cat"; 




-- QUESTIONS FOLLOW  

CREATE TABLE questions_follow ( 
  id INTEGER PRIMARY KEY, 
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
); 

-- INSERT QUESTIONS_FOLLOW 

INSERT INTO 
  questions_follow (user_id, question_id) 
VALUES 
  ((SELECT id FROM users WHERE fname = "Ned" AND lname = "Ruggeri"), 
  (SELECT id FROM questions WHERE title = "Earl Question")),
  ((SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"), 
  (SELECT id FROM questions WHERE title = "Earl Question")
  ); 


-- REPLIES 

CREATE TABLE replies ( 
  id INTEGER PRIMARY KEY, 
  question_id INTEGER NOT NULL, 
  parent_reply_id INTEGER,
  user_reply_id INTEGER NOT NULL, 
  body VARCHAR(255) NOT NULL, 

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_reply_id) REFERENCES users(id)
); 


-- INSERT REPLIES

INSERT INTO 
  replies (question_id, parent_reply_id, user_reply_id, body)
VALUES 
  ((SELECT id FROM questions WHERE title = "Earl Question"), NULL, 
  (SELECT id FROM users WHERE fname = "Ned" AND lname = "Ruggeri"), 
  "Did you say NOW NOW NOW?" ); 

INSERT INTO 
  replies (question_id, parent_reply_id, user_reply_id, body)
VALUES 
  ((SELECT id FROM questions WHERE title = "Earl Question"), 
  (SELECT id FROM replies WHERE body = "Did you say NOW NOW NOW?"), 
  (SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"), 
  "I think he said MEOW MEOW MEOW?" ); 



-- QUESTIONS LIKE 

CREATE TABLE questions_like ( 
  id INTEGER PRIMARY KEY, 
  user_id INTEGER NOT NULL, 
  question_id INTEGER NOT NULL, 

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
); 

INSERT INTO 
  questions_like (user_id, question_id)
VALUES 
  ((SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"),  
  (SELECT id FROM questions WHERE title = "Earl Question")); 
  