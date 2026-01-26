CREATE TABLE IF EXISTS Users(
  user_id CHAR(36) PRIMARY KEY,
  phone VARCHAR(15) UNIQUE NOT NULL,
  display_name VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status_text VARCHAR(50),
  picture_url_attachment CHAR(36)
);
