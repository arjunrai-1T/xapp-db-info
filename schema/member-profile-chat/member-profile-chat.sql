\i /member-profile/member-profile-table.sql 

-- Also we have to add Audit Trail ,Index ,Trigger ,Function for each schema

-- This table will store chat message type Ex Text,File,Audio & Video
CREATE TABLE CHAT_MESSAGE_TYPE (
    ID                SERIAL PRIMARY KEY,                       -- Unique ID for each record
    MESSAGE_TYPE      VARCHAR(100) NOT NULL,                    -- Status value (e.g., "TEXT", "FILE", "AUDIO","VIDEO")
    CREATION_DATETIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,      -- Timestamp for creation
    UPDATED_AT        TIMESTAMP DEFAULT CURRENT_TIMESTAMP       -- Timestamp for last update
);

CREATE TABLE CHAT_STATUS_TYPE (
    ID                SERIAL PRIMARY KEY,                       -- Unique ID for each record
    STATUS_VALUE      VARCHAR(200) NOT NULL,                    -- Status value (e.g., "SEEN", "NOT SEEN","SENT","NOT SENT" or "DELIVERED","NOT DELIVERED","DOWNLOADED")
    CREATION_DATETIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,      -- Timestamp for creation
    UPDATED_AT        TIMESTAMP DEFAULT CURRENT_TIMESTAMP       -- Timestamp for last update
);

-- This table will store user all chat
CREATE TABLE USER_CHAT (
    CHAT_ID                 VARCHAR(20)  NOT NULL,                                  -- Unique ID for each record
    SENDER_PROFILE_ID       VARCHAR(20)  NOT NULL,                                  -- Sender Profile ID
    RECEIVER_PROFILE_ID     VARCHAR(20)  NOT NULL,                                  -- Receiver Profile ID
    CHAT_MESSAGE_TYPE_ID    INT NOT NULL,                                           -- Fixed typo from 'CHAT_MESSAGE_TYPE' Ex. Text ,File, Audio,Video
    CREATION_DATETIME       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,           -- Timestamp for creation
    PRIMARY KEY (CHAT_ID),
    FOREIGN KEY (SENDER_PROFILE_ID)     REFERENCES USER_LOGIN_INFO(PROFILE_ID) ON DELETE CASCADE,
    FOREIGN KEY (RECEIVER_PROFILE_ID)   REFERENCES USER_LOGIN_INFO(PROFILE_ID) ON DELETE CASCADE,
    FOREIGN KEY (CHAT_MESSAGE_TYPE_ID)  REFERENCES CHAT_MESSAGE_TYPE (ID) ON DELETE CASCADE
);

-- This table will store user all text and emoji chat
CREATE TABLE USER_CHAT_TEXT (
    CHAT_ID                 VARCHAR(20) NOT NULL,                                   -- Unique ID for each record
    MESSAGE_CONTENT         TEXT        NOT NULL,                                   -- Message Content
    CREATION_DATETIME       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CHAT_ID)   REFERENCES USER_CHAT (CHAT_ID) ON DELETE CASCADE
);

-- This table will store user all file chat
CREATE TABLE USER_CHAT_FILE (
    CHAT_ID                    VARCHAR(20)  NOT NULL,
    FILE_NAME                  TEXT NOT NULL,
    FILE_TYPE                  VARCHAR(200) NOT NULL,
    FILE_SIZE                  TEXT NOT NULL,
    NAS_FILE_PATH              TEXT NOT NULL,                                    
    LOGICAL_FILE_PATH          TEXT NOT NULL,                   
    CREATION_DATETIME          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CHAT_ID)      REFERENCES USER_CHAT (CHAT_ID) ON DELETE CASCADE
);

-- Chat status table to handle statuses (Seen, Sent, Delivered, Downloaded)
CREATE TABLE USER_CHAT_STATUS (
    CHAT_ID           VARCHAR(20) NOT NULL,        -- Reference to the chat
    STATUS_TYPE_ID    INT NOT NULL,                -- Reference to CHAT_STATUS_TYPE (e.g., SENT, DELIVERED)
    STATUS_TIMESTAMP  TIMESTAMP NOT NULL,          -- Timestamp for when the status occurred
    PRIMARY KEY (CHAT_ID, STATUS_TYPE_ID),
    FOREIGN KEY (CHAT_ID)           REFERENCES USER_CHAT (CHAT_ID) ON DELETE CASCADE,
    FOREIGN KEY (STATUS_TYPE_ID)    REFERENCES CHAT_STATUS_TYPE (ID) ON DELETE CASCADE
);

-- Functions
CREATE OR REPLACE FUNCTION update_timestamp() 
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER update_user_chat_timestamp
BEFORE UPDATE ON USER_CHAT
FOR EACH ROW EXECUTE FUNCTION update_timestamp();


-- Index for faster query

-- Index on SENDER_PROFILE_ID and RECEIVER_PROFILE_ID to speed up searches for messages from or to specific users.
CREATE INDEX idx_user_chat_sender_profile_id   ON USER_CHAT (SENDER_PROFILE_ID);
CREATE INDEX idx_user_chat_receiver_profile_id ON USER_CHAT (RECEIVER_PROFILE_ID);
CREATE INDEX idx_user_chat_message_type_id     ON USER_CHAT (CHAT_MESSAGE_TYPE_ID);

--If you anticipate filtering by STATUS_TIMESTAMP as well (e.g., finding when a certain status was applied), consider indexing STATUS_TIMESTAMP.
CREATE INDEX idx_user_chat_status_timestamp       ON USER_CHAT_STATUS (STATUS_TIMESTAMP);

-- If your application frequently queries chats or messages by their creation date (e.g., "latest chats" or "chats within a time range"), indexing the CREATION_DATETIME column can help.
CREATE INDEX idx_user_chat_creation_datetime      ON USER_CHAT (CREATION_DATETIME);

-- If users often query for chat content based on creation time, indexing CREATION_DATETIME in both these tables could be beneficial.
CREATE INDEX idx_user_chat_text_creation_datetime ON USER_CHAT_TEXT (CREATION_DATETIME);
CREATE INDEX idx_user_chat_file_creation_datetime ON USER_CHAT_FILE (CREATION_DATETIME);

-- If you frequently search for specific message types (e.g., TEXT, FILE, AUDIO, VIDEO), adding an index on the MESSAGE_TYPE column will optimize those queries.
CREATE INDEX idx_chat_message_type                ON CHAT_MESSAGE_TYPE (MESSAGE_TYPE);

--If you anticipate needing full-text searches on message contents (like searching for specific keywords within chat messages), you can create a full-text index on the MESSAGE_CONTENT column in the USER_CHAT_TEXT table.
CREATE INDEX idx_user_chat_text_fulltext          ON USER_CHAT_TEXT USING gin(to_tsvector('english', MESSAGE_CONTENT));





