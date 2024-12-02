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
-- CREATE TABLE USER_LOGIN_INFO (
--     PROFILE_ID                VARCHAR(10)  NOT NULL PRIMARY KEY,
--     USER_LOGIN_ID             VARCHAR(200) NOT NULL UNIQUE,
--     USER_PWD                  VARCHAR(512) NOT NULL,
--     USER_STATUS               VARCHAR(100) NOT NULL,
--     USER_TYPE                 VARCHAR(400) NOT NULL,
--     IS_DELETED                BOOLEAN      NOT NULL,
--     CREATION_DATETIME         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     FOREIGN KEY (USER_STATUS) REFERENCES USER_STATUS_HASH_LIST (ID),
--     FOREIGN KEY (USER_TYPE) REFERENCES USER_CATEGORIES (CATEGORY_NAME) ON DELETE CASCADE ON UPDATE CASCADE,
--     CONSTRAINT check_user_login_id_email_or_mobile 
--     CHECK (
--         USER_LOGIN_ID ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'  -- Email pattern
--         OR
--         USER_LOGIN_ID ~ '^\d{10}$'  -- 10-digit mobile number pattern
--     )
-- );

CREATE TABLE USER_LOGIN_INFO (
    PROFILE_ID                VARCHAR(30)  NOT NULL PRIMARY KEY,
    USER_LOGIN_ID             VARCHAR(200) NOT NULL UNIQUE,
    USER_PWD                  VARCHAR(512) NOT NULL,
    USER_STATUS               VARCHAR(100) NOT NULL,
    USER_TYPE                 VARCHAR(400) NOT NULL,
    IS_DELETED                BOOLEAN      NOT NULL DEFAULT FALSE,
    CREATION_DATETIME         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (USER_STATUS) REFERENCES USER_STATUS_HASH_LIST (USER_STATUS),
    FOREIGN KEY (USER_TYPE) REFERENCES USER_CATEGORIES (CATEGORY_NAME) ON DELETE CASCADE ON UPDATE CASCADE
);

--Trigger for valid login id length / already Exist / valid data
CREATE OR REPLACE FUNCTION validate_and_check_user_login_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if USER_LOGIN_ID is either a valid email or a 10-digit mobile number
    IF NOT (
        NEW.USER_LOGIN_ID ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'  -- Valid email pattern
        OR
        (NEW.USER_LOGIN_ID ~ '^\d{10}$')  -- Valid 10-digit mobile number pattern
    ) THEN
        -- Raise an exception if USER_LOGIN_ID is neither a valid email nor a 10-digit mobile number
        RAISE EXCEPTION 'USER_LOGIN_ID "%" must be a valid email or a 10-digit mobile number', NEW.USER_LOGIN_ID;
    END IF;
    
    -- Check if USER_LOGIN_ID already exists in the table
    IF EXISTS (SELECT 1 FROM USER_LOGIN_INFO WHERE USER_LOGIN_ID = NEW.USER_LOGIN_ID) THEN
        -- Raise an exception if the USER_LOGIN_ID already exists
        RAISE EXCEPTION 'USER_LOGIN_ID "%" already exists', NEW.USER_LOGIN_ID;
    END IF;

    -- Allow the insert operation to continue if both checks pass
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Register the trigger for it
CREATE TRIGGER before_insert_user_login_id_check
BEFORE INSERT ON USER_LOGIN_INFO
FOR EACH ROW
EXECUTE FUNCTION validate_and_check_user_login_id();

--Trigger for USER_LOGIN_INFO status & is deleted default value
CREATE OR REPLACE FUNCTION set_default_values_user_login_info()
RETURNS TRIGGER AS $$
BEGIN
    -- Set default values if not provided
    IF NEW.USER_STATUS IS NULL THEN
        NEW.USER_STATUS := 'Active';
    END IF;

    -- Return the new row with default values set
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Register Trigger
CREATE TRIGGER set_default_values_before_insert
BEFORE INSERT ON USER_LOGIN_INFO
FOR EACH ROW
EXECUTE FUNCTION set_default_values_user_login_info()



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