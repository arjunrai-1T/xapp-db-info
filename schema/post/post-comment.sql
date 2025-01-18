-- Table to store the available comment status (Active, Inactive, Blocked, Deleted, etc.)
CREATE TABLE COMMENT_STATUS_HASH_LIST (
    ID               SERIAL PRIMARY KEY,
    COMMENT_STATUS   VARCHAR(50) NOT NULL UNIQUE  -- Use a smaller size for the status name
);

-- Table for storing comments on posts
CREATE TABLE POST_COMMENT (
    COMMENT_ID            VARCHAR(30) PRIMARY KEY,  -- Using UUID for unique and scalable comment IDs
    COMMENT_HAVEANYCHILD  BOOLEAN DEFAULT FALSE,  -- Whether the comment has any child comments
    COMMENT_PARENT        VARCHAR(30) DEFAULT NULL,  -- Parent comment ID (nullable), UUID for scalability
    PROFILE_ID            VARCHAR(30) NOT NULL,  -- Profile ID (user)
    POST_ID               VARCHAR(30) NOT NULL,  -- Post ID (reference to the post)
    COMMENT_STATEMENT     TEXT NOT NULL,  -- Comment text
    COMMENT_STATUS        VARCHAR(50) NOT NULL,  -- COMMENT_STATUS references COMMENT_STATUS_HASH_LIST
    COMMENT_HAVEANYIMAGES BOOLEAN DEFAULT FALSE,  -- Whether the comment has images
    COMMENT_NUMBEROFIMAGES INTEGER DEFAULT 0,  -- Number of images in the comment
    COMMENT_HAVEANYVIDEOS BOOLEAN DEFAULT FALSE,  -- Whether the comment has videos
    COMMENT_NUMBEROFVIDEOS INTEGER DEFAULT 0,  -- Number of videos in the comment
    CREATION_DATETIME     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Creation datetime
    -- Foreign key constraints
    CONSTRAINT fk_post    FOREIGN KEY (POST_ID) REFERENCES POST_BASIC (POST_ID) ON DELETE CASCADE,  -- Foreign key to POST_BASIC
    CONSTRAINT fk_profile FOREIGN KEY (PROFILE_ID) REFERENCES USER_LOGIN_INFO (PROFILE_ID) ON DELETE CASCADE,  -- Foreign key to USER_LOGIN_INFO
    CONSTRAINT fk_comment_status FOREIGN KEY (COMMENT_STATUS) REFERENCES COMMENT_STATUS_HASH_LIST (COMMENT_STATUS) ON DELETE CASCADE  -- Foreign key to COMMENT_STATUS_HASH_LIST
);

-- Table to store media (images/videos) attached to comments
CREATE TABLE COMMENT_MEDIA (
    COMMENT_ID           VARCHAR(30) NOT NULL,  -- Reference to the comment
    COMMENT_MEDIA_TYPE   VARCHAR(20) NOT NULL,  -- 'image' or 'video'
    COMMENT_MEDIA_NAME   VARCHAR(2000) NOT NULL,         -- Name of the media file
    COMMENT_MEDIA_URL    TEXT NOT NULL,         -- URL or path to the media file
    CREATION_DATETIME    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Foreign key constraint
    CONSTRAINT fk_comment FOREIGN KEY (COMMENT_ID) REFERENCES POST_COMMENT (COMMENT_ID) ON DELETE CASCADE
);
