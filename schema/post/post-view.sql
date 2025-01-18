/*
    Unique views per user: A user can view the video multiple times, but only the first view from that user counts towards the total.

    View threshold: A view is only counted after the video has been watched for a certain duration (e.g., 30 seconds or more).

    Excluding views from bots: YouTube filters out views that are considered to be spam or from non-human sources (e.g., bot traffic).

    View counting window: For a single session, a view may be counted if the user watches the video for a substantial amount of time 
    within a certain time window (e.g., in a 24-hour window).

    High-Level Approach:

    Track Views by User: Each time a user watches a video, check if the user has already watched it within a recent 
    timeframe or met the required duration for counting the view.

    Track View Duration: You could use timestamps to determine how long the user watched the video. A video view is only counted if it exceeds 
    a certain duration threshold (e.g., 30 seconds).

    Prevent Spammy or Bot Views: This would involve filtering views based on certain parameters like IP addresses, user behavior, 
    or using CAPTCHA to prevent bot views.

    Unique Views Per User: Only count a view once per user within a certain time window (e.g., within a 24-hour period).
*/
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
