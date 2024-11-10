
-- This table will store hashs for profile gender Ex. Male/Female/Other
CREATE TABLE USER_GENDER_HASH_LIST (
    ID     SERIAL PRIMARY KEY,
    GENDER VARCHAR(50) NOT NULL
);

-- This table will store hashs for profile martial status Ex. Married/Unmarried
CREATE TABLE USER_MARITAL_STATUS_HASH_LIST (
    ID                      SERIAL PRIMARY KEY,
    USER_MARITAL_STATUS_KEY VARCHAR(100) NOT NULL
);

-- This table will store hashs for profile sexual orientation Ex. heterosexual/Homosexual
CREATE TABLE USER_SEXUAL_ORIENTATION_HASH_LIST (
    ID                          SERIAL PRIMARY KEY,
    USER_SEXUAL_ORIENTATION_KEY VARCHAR(100) NOT NULL
);

-- This table will store hashs for profile occupation Ex. student/professional/teacher/doctor
CREATE TABLE USER_OCCUPATION_HASH_LIST (
    ID                  SERIAL PRIMARY KEY,
    USER_OCCUPATION_KEY VARCHAR(200) NOT NULL
);

-- This table will store hashs for profile status Ex. active/inactive/deleted
CREATE TABLE USER_STATUS_HASH_LIST (
    ID              SERIAL PRIMARY KEY,
    USER_STATUS_KEY VARCHAR(100) NOT NULL
);

-- This table will store hashs for profile status Ex. Private or Public
CREATE TABLE USER_PROFILE_PRIVACY_KEY_LIST (
    ID                       SERIAL PRIMARY KEY,
    USER_PROFILE_PRIVACY_KEY VARCHAR(200) NOT NULL
);

-- This table will store hashs for contatact type Ex. Mobile/Email/Social Links
CREATE TABLE CONTACT_TYPE_LIST (
    ID           SERIAL PRIMARY KEY,
    CONTACT_TYPE VARCHAR(50) NOT NULL
);


