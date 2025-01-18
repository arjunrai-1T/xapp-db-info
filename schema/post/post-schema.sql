-- Table to store the available post types (Post_Profile, Post_Community, Post_Channel, Post_Page & etc...)
CREATE TABLE POST_TYPES_HASH_LIST (
    ID           SERIAL PRIMARY KEY,
    POST_TYPES   VARCHAR(400) NOT NULL UNIQUE
);

-- Table to store the available post statuses (Active, Inactive, Blocked, Deleted)
CREATE TABLE POST_STATUS_HASH_LIST (
    ID            SERIAL PRIMARY KEY,
    POST_STATUS   VARCHAR(200) NOT NULL UNIQUE
);

-- Table to store the details of posts
CREATE TABLE POST_BASIC (
    POST_ID           VARCHAR(30) PRIMARY KEY, 
    POST_TYPE         VARCHAR(400) NOT NULL, 
    POST_STATUS       VARCHAR(20) NOT NULL,
    POST_PRIVACY      VARCHAR(20) NOT NULL,
    POST_AUTHOR       VARCHAR(30) NOT NULL,
    POST_TITLE        TEXT NOT NULL,
    POST_DESC         TEXT NOT NULL,
    POST_LOCATION     VARCHAR(600),
    POST_PARENT       VARCHAR(30),
    POST_ISDELETED    BOOLEAN NOT NULL DEFAULT FALSE,
    POST_HAVEANYCHILD BOOLEAN NOT NULL DEFAULT FALSE,
    POST_HAVEANYIMAGES BOOLEAN DEFAULT FALSE,
    POST_NUMBEROFIMAGES INTEGER DEFAULT 0,
    POST_HAVEANYVIDEOS BOOLEAN DEFAULT FALSE,
    POST_NUMBEROFVIDEOS INTEGER DEFAULT 0,
    CREATION_DATETIME TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key for POST_PARENT (self-referencing)
    CONSTRAINT fk_parent FOREIGN KEY (POST_PARENT) REFERENCES POST_BASIC (POST_ID) ON DELETE CASCADE,
    
    -- Foreign Key for POST_AUTHOR referencing the USER_LOGIN_INFO table
    CONSTRAINT fk_post_author FOREIGN KEY (POST_AUTHOR) REFERENCES USER_LOGIN_INFO (PROFILE_ID) ON DELETE CASCADE,
    
    -- Foreign Key for POST_TYPE referencing POST_TYPES_HASH_LIST table
    CONSTRAINT fk_post_type FOREIGN KEY (POST_TYPE) REFERENCES POST_TYPES_HASH_LIST (POST_TYPES) ON DELETE CASCADE,
    
    -- Foreign Key for POST_STATUS referencing POST_STATUS_HASH_LIST table
    CONSTRAINT fk_post_status FOREIGN KEY (POST_STATUS) REFERENCES POST_STATUS_HASH_LIST (POST_STATUS) ON DELETE CASCADE
);

-- Table store Post media info
CREATE TABLE POST_MEDIA (
    POST_ID           VARCHAR(30) NOT NULL,            -- Post ID (reference to the post)
    POST_MEDIA_ID     VARCHAR(30) NOT NULL,            -- Unique media ID for each media file
    POST_MEDIA_TYPE   VARCHAR(200) NOT NULL,           -- Media type (e.g., image, video, audio)
    POST_MEDIA_NAME   VARCHAR(2000) NOT NULL,          -- Name of the media file
    POST_MEDIA_URL    TEXT NOT NULL,                   -- URL or path to the media file
    CREATION_DATETIME TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Creation datetime
    -- Foreign key constraint (optional, depending on your data model)
    CONSTRAINT fk_post FOREIGN KEY (POST_ID) REFERENCES POST_BASIC (POST_ID) ON DELETE CASCADE
);

