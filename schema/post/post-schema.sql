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

-- Table to store individual ratings for each post, given by each user
CREATE TABLE POST_RATINGS (
    POST_ID          VARCHAR(50) NOT NULL,              -- Reference to the post being rated
    PROFILE_ID       VARCHAR(30) NOT NULL,              -- Reference to the user giving the rating
    RATING_VALUE     INTEGER CHECK (RATING_VALUE BETWEEN 1 AND 10),  -- Rating value (1-10)
    CREATION_DATETIME TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Date and time of the rating
    -- Foreign key constraints
    CONSTRAINT fk_post FOREIGN KEY (POST_ID) REFERENCES POST_BASIC (POST_ID) ON DELETE CASCADE,
    CONSTRAINT fk_user FOREIGN KEY (PROFILE_ID) REFERENCES USER_LOGIN_INFO (PROFILE_ID) ON DELETE CASCADE,
    -- Ensure each user can only rate a post once
    CONSTRAINT unique_user_post UNIQUE (PROFILE_ID, POST_ID),
    -- Primary key for the table (combination of post and user to ensure uniqueness)
    CONSTRAINT pk_post_ratings PRIMARY KEY (POST_ID, PROFILE_ID)
);

-- Optional: Aggregated rating information for each post (average rating, rating count)
CREATE TABLE POST_RATING_AGGREGATES (
    POST_ID          VARCHAR(50) PRIMARY KEY,           -- Reference to the post
    AVERAGE_RATING   NUMERIC(3, 2) NOT NULL,           -- Calculated average rating (e.g., 7.8)
    RATING_COUNT     INTEGER NOT NULL,                 -- Total number of ratings for the post
    -- Foreign key constraint to the POST_BASIC table
    CONSTRAINT fk_post_aggregate FOREIGN KEY (POST_ID) REFERENCES POST_BASIC (POST_ID) ON DELETE CASCADE
);

-- Optional: Indexes for better performance
CREATE INDEX idx_post_ratings_post_id ON POST_RATINGS (POST_ID);
CREATE INDEX idx_post_ratings_profile_id ON POST_RATINGS (PROFILE_ID);



-- Trigger to call the function after inserting or updating a rating
CREATE TRIGGER trigger_update_post_rating_aggregate
AFTER INSERT OR UPDATE ON POST_RATINGS
FOR EACH ROW EXECUTE FUNCTION update_post_rating_aggregate();


-- Adding indexes for commonly queried columns
CREATE INDEX idx_post_author ON POST_BASIC (POST_AUTHOR);
CREATE INDEX idx_post_status ON POST_BASIC (POST_STATUS);
CREATE INDEX idx_creation_datetime ON POST_BASIC (CREATION_DATE, CREATION_TIME);


CREATE TABLE POST_LIKE_DISLIKE_DETAILS (
    POST_ID        VARCHAR(50) NOT NULL,          -- Reference to the post
    PROFILE_ID     VARCHAR(50) NOT NULL,          -- Reference to the user
    ACTION         VARCHAR(10) CHECK (ACTION IN ('LIKE', 'DISLIKE')), -- LIKE or DISLIKE action
    CREATION_DATETIME TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Time of the action
    -- Composite primary key (user can only like/dislike a post once)
    CONSTRAINT pk_post_like_dislike PRIMARY KEY (POST_ID, PROFILE_ID),
    -- Foreign keys to ensure data integrity
    CONSTRAINT fk_post FOREIGN KEY (POST_ID) REFERENCES POST_BASIC (POST_ID) ON DELETE CASCADE,
    CONSTRAINT fk_user FOREIGN KEY (PROFILE_ID) REFERENCES USER_LOGIN_INFO (PROFILE_ID) ON DELETE CASCADE
);

CREATE TABLE POST_LIKE_DISLIKE_SUMMARY (
    POST_ID        VARCHAR(50) PRIMARY KEY,       -- Reference to the post
    TOTAL_LIKES    INTEGER NOT NULL DEFAULT 0,    -- Total likes for the post
    TOTAL_DISLIKE  INTEGER NOT NULL DEFAULT 0,    -- Total dislikes for the post
    CREATION_DATETIME TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP -- Timestamp of aggregation
    -- Foreign key constraint
    CONSTRAINT fk_post_summary FOREIGN KEY (POST_ID) REFERENCES POST_BASIC (POST_ID) ON DELETE CASCADE
);

-- Trigger to execute after an insert into POST_LIKE_DISLIKE_DETAILS
CREATE TRIGGER trigger_update_post_like_dislike_summary
AFTER INSERT ON POST_LIKE_DISLIKE_DETAILS
FOR EACH ROW
EXECUTE FUNCTION update_post_like_dislike_summary();


-- Unique views per user: A user can view the video multiple times, but only the first view from that user counts towards the total.

-- View threshold: A view is only counted after the video has been watched for a certain duration (e.g., 30 seconds or more).

-- Excluding views from bots: YouTube filters out views that are considered to be spam or from non-human sources (e.g., bot traffic).

-- View counting window: For a single session, a view may be counted if the user watches the video for a substantial amount of time 
-- within a certain time window (e.g., in a 24-hour window).

-- High-Level Approach:

-- Track Views by User: Each time a user watches a video, check if the user has already watched it within a recent 
-- timeframe or met the required duration for counting the view.

-- Track View Duration: You could use timestamps to determine how long the user watched the video. A video view is only counted if it exceeds 
-- a certain duration threshold (e.g., 30 seconds).

-- Prevent Spammy or Bot Views: This would involve filtering views based on certain parameters like IP addresses, user behavior, 
-- or using CAPTCHA to prevent bot views.

-- Unique Views Per User: Only count a view once per user within a certain time window (e.g., within a 24-hour period).
CREATE TABLE POST_VIDEO_VIEW_DETAILS (
    POST_ID            VARCHAR(50) NOT NULL,  -- Reference to the post (video)
    PROFILE_ID         VARCHAR(50) NOT NULL,  -- Reference to the user
    VIEW_START_DATETIME TIMESTAMP NOT NULL,   -- Start time of the view
    VIEW_END_DATETIME   TIMESTAMP NOT NULL,   -- End time of the view
    VIEW_DURATION       INTEGER NOT NULL,     -- Duration in seconds (e.g., number of seconds watched)
    VIEW_DATETIME       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Timestamp when the view record was inserted
    UNIQUE (POST_ID, PROFILE_ID, VIEW_START_DATETIME),  -- Ensure a user can only view a post once at a given time
    CONSTRAINT fk_post FOREIGN KEY (POST_ID) REFERENCES POST_BASIC (POST_ID) ON DELETE CASCADE,
    CONSTRAINT fk_user FOREIGN KEY (PROFILE_ID) REFERENCES USER_LOGIN_INFO (PROFILE_ID) ON DELETE CASCADE
);

CREATE TABLE POST_VIDEO_VIEWS (
    POST_ID          VARCHAR(50) PRIMARY KEY,  -- Reference to the post (video)
    TOTAL_VIEWS      INTEGER NOT NULL DEFAULT 0,  -- Total valid views
    UNIQUE_VIEWS     INTEGER NOT NULL DEFAULT 0,  -- Total unique users who viewed the video
    LAST_VIEW_DATETIME TIMESTAMP,  -- Last view time (optional)
    CREATION_DATETIME TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Record creation timestamp
    CONSTRAINT fk_post FOREIGN KEY (POST_ID) REFERENCES POST_BASIC (POST_ID) ON DELETE CASCADE
);

CREATE INDEX idx_post_video_views_post_id ON POST_VIDEO_VIEW_DETAILS (POST_ID);
CREATE INDEX idx_user_video_views_profile_id ON POST_VIDEO_VIEW_DETAILS (PROFILE_ID);
CREATE INDEX idx_view_datetime ON POST_VIDEO_VIEW_DETAILS (VIEW_DATETIME);

--function


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

-- Index for parent-child relationship (important for threaded comments)
CREATE INDEX idx_comment_parent ON POST_COMMENT (COMMENT_PARENT);

-- Index for fetching comments for a specific post
CREATE INDEX idx_post_comments ON POST_COMMENT (POST_ID);

-- Index for sorting comments by creation date (e.g., for displaying comments in order)
CREATE INDEX idx_creation_datetime ON POST_COMMENT (CREATION_DATETIME);


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


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- CREATE TABLE `POST_COMMENT` (
--   `COMMENT_ID` varchar(10) NOT NULL,
--   `PROFILE_ID` varchar(10) NOT NULL,
--   `POST_ID` varchar(10) NOT NULL,
--   `COMMENT_STATUS` varchar(100) NOT NULL,
--   `COMMENT_PARENT` varchar(10) DEFAULT NULL,
--   `COMMENT_HAVEANYCHILD` tinyint(1) DEFAULT '0',
--   `COMMENT_HAVEANYIMAGES` tinyint(1) DEFAULT '0',
--   `COMMENT_NUMBEROFIMAGES` varchar(10) DEFAULT '0',
--   `COMMENT_HAVEANYVIDEOS` tinyint(1) DEFAULT '0',
--   `COMMENT_NUMBEROFVIDEOS` varchar(10) DEFAULT '0',
--   `COMMENT_STATEMENT` text NOT NULL,
--   `CREATION_DATE` date DEFAULT NULL,
--   `CREATION_TIME` time DEFAULT NULL
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- CREATE TABLE `POST_COMMENT_LIKE_DISLIKE` (
--   `COMMENT_ID` varchar(10) NOT NULL,
--   `TOTAL_LIKES` int(11) NOT NULL,
--   `TOTAL_DISLIKE` int(11) NOT NULL,
--   `CREATION_DATE` date NOT NULL,
--   `CREATION_TIME` time NOT NULL
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- CREATE TABLE `POST_COMMENT_MEDIA` (
--   `COMMENT_ID` varchar(10) NOT NULL,
--   `COMMENT_MEDIA_ID` varchar(10) NOT NULL,
--   `COMMENT_MEDIA_TYPE` varchar(200) NOT NULL,
--   `COMMENT_MEDIA_NAME` varchar(200) NOT NULL,
--   `ALBUM_ID` varchar(10) NOT NULL,
--   `CREATION_DATE` date DEFAULT NULL,
--   `CREATION_TIME` time DEFAULT NULL
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- CREATE TABLE `POST_MEDIA` (
--   `POST_ID` varchar(10) NOT NULL,
--   `POST_MEDIA_ID` varchar(10) NOT NULL,
--   `POST_MEDIA_TYPE` varchar(200) NOT NULL,
--   `POST_MEDIA_NAME` varchar(2000) NOT NULL,
--   `ALBUM_ID` varchar(10) NOT NULL,
--   `CREATION_DATE` date DEFAULT NULL,
--   `CREATION_TIME` time DEFAULT NULL
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;




