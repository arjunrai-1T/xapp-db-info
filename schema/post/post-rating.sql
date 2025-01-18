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