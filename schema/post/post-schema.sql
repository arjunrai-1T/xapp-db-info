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

-- Function to update the aggregate ratings incrementally
CREATE OR REPLACE FUNCTION update_post_rating_aggregate() 
RETURNS TRIGGER AS $$
DECLARE
    current_rating_count INTEGER;
    current_average_rating NUMERIC(3, 2);
BEGIN
    -- Fetch the current aggregate values for the post
    SELECT RATING_COUNT, AVERAGE_RATING
    INTO current_rating_count, current_average_rating
    FROM POST_RATING_AGGREGATES
    WHERE POST_ID = NEW.POST_ID
    FOR UPDATE;

    -- If no aggregate data exists, initialize it
    IF NOT FOUND THEN
        current_rating_count := 0;
        current_average_rating := 0;
        -- Insert a new row into POST_RATING_AGGREGATES if it doesn't exist
        INSERT INTO POST_RATING_AGGREGATES (POST_ID, AVERAGE_RATING, RATING_COUNT)
        VALUES (NEW.POST_ID, 0, 0);
    END IF;

    -- Update aggregate count and average (incremental)
    IF TG_OP = 'INSERT' THEN
        -- New rating added
        UPDATE POST_RATING_AGGREGATES
        SET RATING_COUNT = current_rating_count + 1,
            AVERAGE_RATING = ((current_average_rating * current_rating_count) + NEW.RATING_VALUE) / (current_rating_count + 1)
        WHERE POST_ID = NEW.POST_ID;
    ELSIF TG_OP = 'UPDATE' THEN
        -- Rating updated
        UPDATE POST_RATING_AGGREGATES
        SET RATING_COUNT = current_rating_count,  -- Rating count stays the same
            AVERAGE_RATING = ((current_average_rating * current_rating_count) - OLD.RATING_VALUE + NEW.RATING_VALUE) / current_rating_count
        WHERE POST_ID = NEW.POST_ID;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

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

-- Trigger function to update the aggregate counts
CREATE OR REPLACE FUNCTION update_post_like_dislike_summary() 
RETURNS TRIGGER AS $$
BEGIN
    -- Increment the like or dislike count based on the action
    IF NEW.ACTION = 'LIKE' THEN
        UPDATE POST_LIKE_DISLIKE_SUMMARY
        SET TOTAL_LIKES = TOTAL_LIKES + 1
        WHERE POST_ID = NEW.POST_ID;
    ELSIF NEW.ACTION = 'DISLIKE' THEN
        UPDATE POST_LIKE_DISLIKE_SUMMARY
        SET TOTAL_DISLIKE = TOTAL_DISLIKE + 1
        WHERE POST_ID = NEW.POST_ID;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

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
CREATE OR REPLACE FUNCTION record_video_view(
    p_post_id VARCHAR(50),
    p_profile_id VARCHAR(50),
    p_view_start_datetime TIMESTAMP,
    p_view_end_datetime TIMESTAMP
)
RETURNS VOID AS $$
DECLARE
    v_view_duration INTEGER;
BEGIN
    -- Step 1: Calculate the view duration
    v_view_duration := EXTRACT(EPOCH FROM (p_view_end_datetime - p_view_start_datetime))::INTEGER;
    
    -- Step 2: Insert the view into POST_VIDEO_VIEW_DETAILS
    INSERT INTO POST_VIDEO_VIEW_DETAILS (POST_ID, PROFILE_ID, VIEW_START_DATETIME, VIEW_END_DATETIME, VIEW_DURATION)
    VALUES (p_post_id, p_profile_id, p_view_start_datetime, p_view_end_datetime, v_view_duration);

    -- Step 3: Only update views if the view duration exceeds 30 seconds
    IF v_view_duration >= 30 THEN
        -- Step 4: Update the aggregated views count in POST_VIDEO_VIEWS
        UPDATE POST_VIDEO_VIEWS
        SET TOTAL_VIEWS = TOTAL_VIEWS + 1,
            UNIQUE_VIEWS = UNIQUE_VIEWS + 1
        WHERE POST_ID = p_post_id;
    END IF;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

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
    CONSTRAINT fk_comment_status FOREIGN KEY (COMMENT_STATUS) REFERENCES COMMENT_STATUS_HASH_LIST (COMMENT_STATUS) ON DELETE CASCADE,  -- Foreign key to COMMENT_STATUS_HASH_LIST
    CONSTRAINT chk_comment_images CHECK (COMMENT_NUMBEROFIMAGES >= 0),  -- Ensure non-negative image count
    CONSTRAINT chk_comment_videos CHECK (COMMENT_NUMBEROFVIDEOS >= 0)  -- Ensure non-negative video count
);

-- Optional: Create index for COMMENT_PARENT for better performance in threaded comments
CREATE INDEX idx_comment_parent ON POST_COMMENT (COMMENT_PARENT);


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE `POST_COMMENT` (
  `COMMENT_ID` varchar(10) NOT NULL,
  `PROFILE_ID` varchar(10) NOT NULL,
  `POST_ID` varchar(10) NOT NULL,
  `COMMENT_STATUS` varchar(100) NOT NULL,
  `COMMENT_PARENT` varchar(10) DEFAULT NULL,
  `COMMENT_HAVEANYCHILD` tinyint(1) DEFAULT '0',
  `COMMENT_HAVEANYIMAGES` tinyint(1) DEFAULT '0',
  `COMMENT_NUMBEROFIMAGES` varchar(10) DEFAULT '0',
  `COMMENT_HAVEANYVIDEOS` tinyint(1) DEFAULT '0',
  `COMMENT_NUMBEROFVIDEOS` varchar(10) DEFAULT '0',
  `COMMENT_STATEMENT` text NOT NULL,
  `CREATION_DATE` date DEFAULT NULL,
  `CREATION_TIME` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- CREATE TABLE `POST_COMMENT_LIKE_DISLIKE` (
--   `COMMENT_ID` varchar(10) NOT NULL,
--   `TOTAL_LIKES` int(11) NOT NULL,
--   `TOTAL_DISLIKE` int(11) NOT NULL,
--   `CREATION_DATE` date NOT NULL,
--   `CREATION_TIME` time NOT NULL
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `POST_COMMENT_MEDIA` (
  `COMMENT_ID` varchar(10) NOT NULL,
  `COMMENT_MEDIA_ID` varchar(10) NOT NULL,
  `COMMENT_MEDIA_TYPE` varchar(200) NOT NULL,
  `COMMENT_MEDIA_NAME` varchar(200) NOT NULL,
  `ALBUM_ID` varchar(10) NOT NULL,
  `CREATION_DATE` date DEFAULT NULL,
  `CREATION_TIME` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `POST_MEDIA` (
  `POST_ID` varchar(10) NOT NULL,
  `POST_MEDIA_ID` varchar(10) NOT NULL,
  `POST_MEDIA_TYPE` varchar(200) NOT NULL,
  `POST_MEDIA_NAME` varchar(2000) NOT NULL,
  `ALBUM_ID` varchar(10) NOT NULL,
  `CREATION_DATE` date DEFAULT NULL,
  `CREATION_TIME` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




