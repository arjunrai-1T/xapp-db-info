
INSERT INTO POST_TYPES_HASH_LIST (POST_TYPES) 
VALUES 
    ('Post_Profile'),
    ('Post_Community'),
    ('Post_Channel'),
    ('Post_Page');

INSERT INTO POST_STATUS_HASH_LIST (POST_STATUS) 
VALUES 
    ('Active'),
    ('Inactive'),
    ('Blocked'),
    ('Deleted');

INSERT INTO NAS_SERVERS (NAS_SERVER_ID, NAS_SERVER_IP, NAS_SERVER_PATH_PREFIX, NAS_SERVER_NAME)
VALUES 
    ('NAS_1', 'https://192.168.1.10', '/nas1/fliktape', 'First NAS Server'),
    ('NAS_2', 'https://192.168.1.11', '/nas2/fliktape', 'Second NAS Server');

	INSERT INTO USER_NAS_MAPPING (USER_PROFILE_ID, NAS_SERVER_ID, BASE_URL_PATH)
VALUES 
    ('PF9aba3442553a03d5142f27ba3892', 'NAS_1', '/video'),
    ('PF9aba3442553a03d5142f27ba3892', 'NAS_2', '/short');