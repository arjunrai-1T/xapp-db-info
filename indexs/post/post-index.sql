-- Adding indexes for commonly queried columns
CREATE INDEX idx_post_author ON POST_BASIC (POST_AUTHOR);
CREATE INDEX idx_post_status ON POST_BASIC (POST_STATUS);
CREATE INDEX idx_creation_datetime ON POST_BASIC (CREATION_DATE, CREATION_TIME);

-- Optional: Indexes for better performance
CREATE INDEX idx_post_ratings_post_id ON POST_RATINGS (POST_ID);
CREATE INDEX idx_post_ratings_profile_id ON POST_RATINGS (PROFILE_ID);

-- Trigger to call the function after inserting or updating a rating
CREATE TRIGGER trigger_update_post_rating_aggregate
AFTER INSERT OR UPDATE ON POST_RATINGS
FOR EACH ROW EXECUTE FUNCTION update_post_rating_aggregate();


-- Index for parent-child relationship (important for threaded comments)
CREATE INDEX idx_comment_parent ON POST_COMMENT (COMMENT_PARENT);
-- Index for fetching comments for a specific post
CREATE INDEX idx_post_comments ON POST_COMMENT (POST_ID);
-- Index for sorting comments by creation date (e.g., for displaying comments in order)
CREATE INDEX idx_creation_datetime ON POST_COMMENT (CREATION_DATETIME);

-- Trigger to execute after an insert into POST_LIKE_DISLIKE_DETAILS
CREATE TRIGGER trigger_update_post_like_dislike_summary
AFTER INSERT ON POST_LIKE_DISLIKE_DETAILS
FOR EACH ROW
EXECUTE FUNCTION update_post_like_dislike_summary();