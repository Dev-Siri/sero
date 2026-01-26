CREATE TABLE IF NOT EXISTS Attachments(
  attachment_id CHAR(36) PRIMARY KEY,
  file_name VARCHAR(255) NOT NULL,
  mime_type VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  source_url VARCHAR(255) NOT NULL,
  processed_url VARCHAR(255)
);
