
-- Table user-login_info Index
-- Index on USER_LOGIN_ID (already unique, but explicitly adding the index for optimization)
CREATE INDEX idx_user_login_info_user_login_id ON USER_LOGIN_INFO(USER_LOGIN_ID);

-- Index on USER_STATUS (for faster filtering by user status)
CREATE INDEX idx_user_login_info_user_status ON USER_LOGIN_INFO(USER_STATUS);

-- Index on USER_TYPE (for faster filtering by user type)
CREATE INDEX idx_user_login_info_user_type ON USER_LOGIN_INFO(USER_TYPE);

-- Index on IS_DELETED (for faster filtering out deleted records)
CREATE INDEX idx_user_login_info_is_deleted ON USER_LOGIN_INFO(IS_DELETED);

-- Index on CREATION_DATETIME (for faster queries based on the creation date)
CREATE INDEX idx_user_login_info_creation_datetime ON USER_LOGIN_INFO(CREATION_DATETIME);

-- Table user_sessions Index
-- Index for user_login_id (foreign key reference, can improve query performance for user-based searches)
CREATE INDEX idx_user_sessions_user_login_id ON user_sessions(user_login_id);

-- Index for session_token (for fast lookups by session token)
CREATE INDEX idx_user_sessions_session_token ON user_sessions(session_token);

-- Index for login_datetime (for time-based searches, e.g., finding sessions based on login time)
CREATE INDEX idx_user_sessions_login_datetime ON user_sessions(login_datetime);

-- Index for expiration_time (for fast queries to find expired sessions or those about to expire)
CREATE INDEX idx_user_sessions_expiration_time ON user_sessions(expiration_time);

