
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