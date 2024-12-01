-- This table will store hashs for profile gender Ex. Male/Female/Other
CREATE TABLE USER_GENDER_HASH_LIST (
    ID     SERIAL,
    GENDER VARCHAR(50) NOT NULL PRIMARY KEY
);

-- This table will store hashs for profile martial status Ex. Married/Unmarried
CREATE TABLE USER_MARITAL_STATUS_HASH_LIST (
    ID                      SERIAL ,
    USER_MARITAL_STATUS VARCHAR(100) NOT NULL PRIMARY KEY
);

-- This table will store hashs for profile sexual orientation Ex. heterosexual/Homosexual
CREATE TABLE USER_SEXUAL_ORIENTATION_HASH_LIST (
    ID                          SERIAL PRIMARY KEY,
    USER_SEXUAL_ORIENTATION_KEY VARCHAR(100) NOT NULL
);

-- This table will store hashs for profile occupation Ex. student/professional/teacher/doctor
CREATE TABLE USER_OCCUPATION_HASH_LIST (
    ID                  SERIAL,
    USER_OCCUPATION VARCHAR(200) NOT NULL PRIMARY KEY
);

-- This table will store hashs for profile status Ex. active/inactive/deleted
CREATE TABLE USER_STATUS_HASH_LIST (
    ID              SERIAL,
    USER_STATUS     VARCHAR(100) NOT NULL PRIMARY KEY
);

-- This table will store hashs for profile status Ex. Private or Public
CREATE TABLE USER_PROFILE_PRIVACY_KEY_LIST (
    ID                       SERIAL,
    USER_PROFILE_PRIVACY VARCHAR(200) NOT NULL PRIMARY KEY
);

-- This table will store hashs for contatact type Ex. Mobile/Email/Social Links
CREATE TABLE CONTACT_TYPE_LIST (
    ID           SERIAL,
    CONTACT_TYPE VARCHAR(50) NOT NULL PRIMARY KEY
);


