CREATE TABLE NAS_SERVERS (
    NAS_SERVER_ID VARCHAR(60) PRIMARY KEY,  -- Custom identifier for each NAS server (e.g., "NAS_1")
    NAS_SERVER_IP INET NOT NULL,             -- Store the IP address of the NAS server (IPv4 or IPv6)
    NAS_SERVER_PATH_PREFIX VARCHAR(255),    -- Common path prefix for all files on the NAS server (optional)
    NAS_SERVER_NAME VARCHAR(100)            -- Name or identifier for the NAS server
);

CREATE TABLE USER_NAS_MAPPING (
    USER_PROFILE_ID VARCHAR(60) PRIMARY KEY,  -- Reference to the user profile
    NAS_SERVER_ID   VARCHAR(60) NOT NULL,     -- Reference to the NAS server
    BASE_URL_PATH   VARCHAR(255) NOT NULL,    -- Base URL path for accessing the media on the NAS
    -- Foreign key constraints
    CONSTRAINT fk_user_profile FOREIGN KEY (USER_PROFILE_ID) REFERENCES USER_LOGIN_INFO (PROFILE_ID) ON DELETE CASCADE,  -- Assuming USER_LOGIN_INFO holds the profile data
    CONSTRAINT fk_nas_server FOREIGN KEY (NAS_SERVER_ID) REFERENCES NAS_SERVERS (NAS_SERVER_ID) ON DELETE CASCADE   -- Reference to NAS server
);