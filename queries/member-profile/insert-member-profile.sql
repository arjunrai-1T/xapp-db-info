-- Insert user categories
INSERT INTO USER_CATEGORIES (CATEGORY_NAME,PARENT_CATEGORY_NAME,IS_DELETED , CREATION_DATETIME) 
VALUES 
('End User',        NULL,'N',CURRENT_TIMESTAMP),
('Content Creator', NULL,'N', CURRENT_TIMESTAMP),
('Admin',          NULL,'N',CURRENT_TIMESTAMP),
('Ad Manager',      NULL,'N', CURRENT_TIMESTAMP),
('Advertisers',     NULL,'N',CURRENT_TIMESTAMP);


INSERT INTO USER_CATEGORIES (CATEGORY_NAME,PARENT_CATEGORY_NAME,IS_DELETED , CREATION_DATETIME) 
VALUES 
('Super Admin','Admin','N',CURRENT_TIMESTAMP),
('Community Admin','Admin','N', CURRENT_TIMESTAMP),
('Content Moderator','Admin','N', CURRENT_TIMESTAMP),
('Account Admin','Admin','N', CURRENT_TIMESTAMP),
('Security Admin','Admin','N', CURRENT_TIMESTAMP),
('Editorial Admin','Admin','N', CURRENT_TIMESTAMP),
('Technical Admin','Admin','N', CURRENT_TIMESTAMP),
('Analytics Admin','Admin','N', CURRENT_TIMESTAMP),
('Brand/Corporate','Advertisers','N', CURRENT_TIMESTAMP),
('Online Retailers','Advertisers','N', CURRENT_TIMESTAMP),
('Small and Medium Enterprises','Advertisers','N', CURRENT_TIMESTAMP),
('Creator Business/InInfluencer','Advertisers','N', CURRENT_TIMESTAMP),
('Agencies','Advertisers','N', CURRENT_TIMESTAMP),
('Event Promoters','Advertisers','N', CURRENT_TIMESTAMP),
('Freelancers and Service Providers','Advertisers','N', CURRENT_TIMESTAMP),
('Real Estate Agents and Property Developers','Advertisers','N', CURRENT_TIMESTAMP),
('Non-profits and Social Organizations','Advertisers','N', CURRENT_TIMESTAMP),
('Educational Institutions and Online Courses','Advertisers','N', CURRENT_TIMESTAMP);

-- Insert User login list
INSERT INTO USER_LOGIN_INFO (
    PROFILE_ID,
    USER_LOGIN_ID,
    USER_PWD,
    USER_STATUS,
    USER_TYPE,
    IS_DELETED,
    CREATION_DATETIME
)
VALUES (
    'P12345',                             -- PROFILE_ID (VARCHAR(10))
    '9903688797',                         -- USER_LOGIN_ID (VARCHAR(200))
    'hashedpassword1234567890',           -- USER_PWD (VARCHAR(512))
    'Active',                             -- USER_STATUS (VARCHAR(100)), 
    'End User',                           -- USER_TYPE (VARCHAR(400)), referencing CATEGORY_NAME from USER_CATEGORIES
    FALSE,                                -- IS_DELETED (BOOLEAN), setting to FALSE means the user is active
    CURRENT_TIMESTAMP                     -- CREATION_DATETIME (TIMESTAMP), using current timestamp
);


-- Insert permission list
INSERT INTO PERMISSIONS (PERMISSION_NAME, IS_DELETED, CREATION_DATETIME)
VALUES 
('CREATE_POST', FALSE, CURRENT_TIMESTAMP),
('EDIT_POST', FALSE, CURRENT_TIMESTAMP),
('DELETE_POST', FALSE, CURRENT_TIMESTAMP),
('BAN_USER', FALSE, CURRENT_TIMESTAMP),
('VIEW_REPORTS', FALSE, CURRENT_TIMESTAMP);


-- Insert user category with permission mapping list
INSERT INTO ROLE_PERMISSIONS (ROLE_ID, PERMISSION_ID, CREATION_DATETIME)
VALUES 
(1, 1, CURRENT_TIMESTAMP),  -- Consumer User can CREATE_POST
(1, 2, CURRENT_TIMESTAMP),  -- Consumer User can EDIT_POST

(2, 1, CURRENT_TIMESTAMP),  -- Content Creator can CREATE_POST
(2, 2, CURRENT_TIMESTAMP),  -- Content Creator can EDIT_POST
(2, 3, CURRENT_TIMESTAMP),  -- Content Creator can DELETE_POST

(3, 1, CURRENT_TIMESTAMP),  -- Moderator can CREATE_POST
(3, 2, CURRENT_TIMESTAMP),  -- Moderator can EDIT_POST
(3, 3, CURRENT_TIMESTAMP),  -- Moderator can DELETE_POST
(3, 4, CURRENT_TIMESTAMP),  -- Moderator can BAN_USER

(4, 1, CURRENT_TIMESTAMP),  -- Administrator can CREATE_POST
(4, 2, CURRENT_TIMESTAMP),  -- Administrator can EDIT_POST
(4, 3, CURRENT_TIMESTAMP),  -- Administrator can DELETE_POST
(4, 4, CURRENT_TIMESTAMP),  -- Administrator can BAN_USER
(4, 5, CURRENT_TIMESTAMP);  -- Administrator can VIEW_REPORTS


-- Hash Tables for user 
INSERT INTO USER_STATUS_HASH_LIST (USER_STATUS) VALUES
        ('Active'),
        ('Inactive'),
        ('Blocked'),
        ('Deleted'),
        ('Suspended');

INSERT INTO USER_MARITAL_STATUS_HASH_LIST (USER_MARITAL_STATUS_KEY) VALUES
        ('Single'),
        ('Married'),
        ('Divorced');

INSERT INTO USER_OCCUPATION_HASH_LIST (USER_OCCUPATION_KEY) VALUES
        ('Engineer'),
        ('Doctor'),
        ('Artist');

INSERT INTO USER_PROFILE_PRIVACY_KEY_LIST (USER_PROFILE_PRIVACY_KEY) VALUES
        ('Public'),
        ('Private');

INSERT INTO USER_SEXUAL_ORIENTATION_HASH_LIST (USER_SEXUAL_ORIENTATION_KEY) VALUES
        ('Heterosexual'),
        ('Homosexual'),
        ('Gay'),
        ('Asexual'),
        ('Pansexual'),
        ('Lesbian'),
        ('Demisexual'),
        ('Bisexual');

INSERT INTO CONTACT_TYPE_LIST (CONTACT_TYPE) VALUES
        ('Email'),
        ('Phone'),
        ('Instagram'),
        ('Youtube'),
        ('x'),
        ('Snapchat'),
        ('Facebook');

INSERT INTO USER_GENDER_HASH_LIST (GENDER) VALUES
        ('Male'),
        ('Female'),
        ('Non-binary');

