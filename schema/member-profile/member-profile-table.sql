\i /member-profile-hash-table.sql 

-- This table will store user category Ex. Admin/Consumer/Creator/Moderator
CREATE TABLE USER_CATEGORIES (
    CATEGORY_ID             SERIAL,
    CATEGORY_NAME           VARCHAR(400) PRIMARY KEY,
    PARENT_CATEGORY_NAME    VARCHAR(400) DEFAULT NULL,
    IS_DELETED              BOOLEAN NOT NULL,
    CREATION_DATETIME       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PARENT_CATEGORY_NAME) REFERENCES USER_CATEGORIES (CATEGORY_NAME) ON DELETE SET NULL
);

-- This table will store permission list on system Ex. Create Post /Create moderator
CREATE TABLE PERMISSIONS (
    PERMISSION_ID   BIGSERIAL PRIMARY KEY,
    PERMISSION_NAME VARCHAR(400) NOT NULL UNIQUE,
    IS_DELETED      BOOLEAN NOT NULL,
    CREATION_DATETIME TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- This table will map user category and permission  Ex. Creator can create Post
CREATE TABLE ROLE_PERMISSIONS (
    ROLE_NAME                   VARCHAR(400) NOT NULL,
    PERMISSION_ID               BIGINT NOT NULL,
    CREATION_DATETIME           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ROLE_NAME, PERMISSION_ID),
    FOREIGN KEY (ROLE_NAME)     REFERENCES USER_CATEGORIES (CATEGORY_NAME) ON DELETE CASCADE,
    FOREIGN KEY (PERMISSION_ID) REFERENCES PERMISSIONS (PERMISSION_ID) ON DELETE CASCADE
);

-- This table will store user login information
CREATE TABLE USER_LOGIN_INFO (
    PROFILE_ID                VARCHAR(30)  NOT NULL PRIMARY KEY,
    USER_LOGIN_ID             VARCHAR(200) NOT NULL UNIQUE,
    USER_PWD_SALT             VARCHAR(512) NOT NULL,
    USER_PWD                  VARCHAR(1024) NOT NULL,
    USER_STATUS               VARCHAR(100) NOT NULL,
    USER_TYPE                 VARCHAR(400) NOT NULL,
    IS_DELETED                BOOLEAN      NOT NULL DEFAULT FALSE,
    CREATION_DATETIME         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (USER_STATUS) REFERENCES USER_STATUS_HASH_LIST (USER_STATUS),
    FOREIGN KEY (USER_TYPE) REFERENCES USER_CATEGORIES (CATEGORY_NAME) ON DELETE CASCADE ON UPDATE CASCADE
);


-- This table will store user basic information Ex. Name/Gender/Birthday
CREATE TABLE USER_BASIC_INFO (
    PROFILE_ID              VARCHAR(10) NOT NULL,
    USER_FIRST_NAME         VARCHAR(200) NOT NULL,
    USER_LAST_NAME          VARCHAR(200) NOT NULL,
    USER_GENDER_ID          INT DEFAULT NULL,
    USER_BIRTHDAY           DATE DEFAULT NULL,
    CREATION_DATETIME       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (PROFILE_ID),
    FOREIGN KEY (USER_GENDER_ID)             REFERENCES USER_GENDER_HASH_LIST (ID),
    FOREIGN KEY (PROFILE_ID)                 REFERENCES USER_LOGIN_INFO (PROFILE_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- This table will store user depth information
CREATE TABLE USER_BASIC_INFO_INDEPTH (
    PROFILE_ID                  VARCHAR(10) NOT NULL,
    PROFILE_BIO_DESC            TEXT        NULL,
    USER_PROFILE_PRIVACY_ID     INT         NOT NULL,
    USER_MARITAL_STATUS_ID      INT DEFAULT NULL,
    USER_SEXUAL_ORIENTATION_ID  INT DEFAULT NULL,
    USER_OCCUPATION_ID          INT DEFAULT NULL,
    USER_COUNTRY_ID             INT DEFAULT NOT NULL,
    USER_STATE_ID               INT DEFAULT NULL,
    USER_PLACE_ID               INT DEFAULT NOT NULL,
    CREATION_DATETIME           TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (PROFILE_ID),
    FOREIGN KEY (PROFILE_ID)                 REFERENCES USER_LOGIN_INFO (PROFILE_ID)       ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (USER_PROFILE_PRIVACY_ID)    REFERENCES USER_PROFILE_PRIVACY_KEY_LIST (ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (USER_MARITAL_STATUS_ID)     REFERENCES USER_MARITAL_STATUS_HASH_LIST (ID),
    FOREIGN KEY (USER_SEXUAL_ORIENTATION_ID) REFERENCES USER_SEXUAL_ORIENTATION_HASH_LIST (ID),
    FOREIGN KEY (USER_OCCUPATION_ID)         REFERENCES USER_OCCUPATION_HASH_LIST (ID)
);

-- This table will store user contact information Ex Mobile/Social Links
CREATE TABLE USER_CONTACT_INFO (
    CONTACT_ID                    SERIAL PRIMARY KEY,
    PROFILE_ID                    VARCHAR(10) NOT NULL,
    CONTACT_TYPE_ID               INT NOT NULL,
    CONTACT_VALUE                 VARCHAR(200) NOT NULL,
    IS_DELETED                    BOOLEAN NOT NULL,
    FOREIGN KEY (PROFILE_ID)      REFERENCES USER_LOGIN_INFO (PROFILE_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (CONTACT_TYPE_ID) REFERENCES CONTACT_TYPE_LIST (ID)
);

--This table will store user session information

CREATE TABLE USER_SESSION_KEY (
    ID           SERIAL PRIMARY KEY,
    SECRET_KEY   VARCHAR(600) NOT NULL 
);

CREATE TABLE USER_SESSIONS (
    USER_LOGIN_ID   VARCHAR(255)  NOT NULL,                                                  -- User's login ID (can be a username or email)
    SESSION_TOKEN   VARCHAR(400)  NOT NULL,                                                  -- The session token used for authentication
    EXPIRATION_TIME TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP + INTERVAL '1 hour',      -- Default value is 1 hour from the current time
    LOGIN_DATETIME  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,                          -- Default to current timestamp
    LOGOUT_DATETIME TIMESTAMP   DEFAULT NULL,                                                -- Explicitly specify NULL as the default value for logout_datetime
    CONSTRAINT PK_USER_SESSIONS PRIMARY KEY (USER_LOGIN_ID, SESSION_TOKEN, LOGIN_DATETIME),  -- Composite Primary Key
    CONSTRAINT FK_USER_LOGIN_ID FOREIGN KEY (USER_LOGIN_ID) REFERENCES USER_LOGIN_INFO(USER_LOGIN_ID)  -- Foreign Key Constraint
);

