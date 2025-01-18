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

