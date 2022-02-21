CREATE OR REPLACE FUNCTION GET_MIN_PRICE(HID IN NUMBER)
RETURN NUMBER IS 
    MIN_PRICE NUMBER;
BEGIN
    SELECT MIN(NVL(PRICE, 0)) INTO MIN_PRICE
    FROM ROOMS
    WHERE HOUSE_ID = HID;
    
    RETURN MIN_PRICE;
END;
    
CREATE OR REPLACE FUNCTION GET_MAX_PRICE(HID IN NUMBER)
RETURN NUMBER IS 
    MAX_PRICE NUMBER;
BEGIN
    SELECT MAX(NVL(PRICE, 0)) INTO MAX_PRICE
    FROM ROOMS
    WHERE HOUSE_ID = HID;
    
    RETURN MAX_PRICE;
END;

CREATE OR REPLACE FUNCTION INSERT_HOUSE_RETURN_HOUSE_ID(USRID IN NUMBER, AID IN NUMBER, HNAME IN VARCHAR2, 
HNO IN VARCHAR2, DESCR IN VARCHAR2)
RETURN NUMBER IS
		HID NUMBER;
BEGIN
    INSERT INTO HOUSES(USER_ID,ADDRESS_ID,HOUSE_NAME,HOUSE_NO,DESCRIPTION) 
    VALUES(USRID, AID, HNAME, HNO, DESCR) RETURNING HOUSE_ID INTO HID;
		
	RETURN HID;
END;

CREATE OR REPLACE FUNCTION INSERT_ADDRESS_RETURN_ADDRESS_ID(STR IN VARCHAR2, PC IN VARCHAR2, CID IN NUMBER)
RETURN NUMBER IS
		AID NUMBER;
BEGIN
    INSERT INTO ADDRESSES(STREET, POST_CODE, CITY_ID) 
    VALUES(STR, PC, CID) RETURNING ADDRESS_ID INTO AID;
		
	RETURN AID;
END;

CREATE OR REPLACE TRIGGER UPDATE_DEPOSITS
FOR INSERT
ON RENTS
COMPOUND TRIGGER
    UID NUMBER;
    USER_BANK_ACC_NO VARCHAR2(35);

    BEFORE EACH ROW IS
    BEGIN
        SELECT BANK_ACC_NO INTO USER_BANK_ACC_NO
        FROM USERS WHERE USER_ID = :NEW.USER_ID;
        
        IF USER_BANK_ACC_NO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Transaction cant be completed. Owner doesnt have bank account no');
        END IF;
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        SELECT USER_ID INTO UID
        FROM HOUSES WHERE HOUSE_ID = :NEW.HOUSE_ID;
        
        INSERT INTO DEPOSITS
        VALUES(UID, :NEW.TRANSACTION_ID, USER_BANK_ACC_NO);
    END AFTER EACH ROW;
END;

CREATE OR REPLACE TRIGGER MAKE_HOST
AFTER INSERT
ON HOUSES
FOR EACH ROW
DECLARE
    ISHOST NUMBER(1);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Make host triggered ' || :NEW.USER_ID);
    UPDATE USERS
    SET IS_HOST = 1
    WHERE USER_ID = :NEW.USER_ID;
    DBMS_OUTPUT.PUT_LINE('Host ADDED');
END;

CREATE OR REPLACE TRIGGER REMOVE_HOST
AFTER DELETE
ON HOUSES
FOR EACH ROW
DECLARE
	NO_OF_HOUSES NUMBER;
	HID NUMBER := 0;
	PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	DBMS_OUTPUT.PUT_LINE('Remove host triggered');
	SELECT COUNT(HOUSE_ID) INTO NO_OF_HOUSES
	FROM HOUSES
	WHERE USER_ID = :OLD.USER_ID;
	
	IF NO_OF_HOUSES = 1 THEN
		SELECT HOUSE_ID INTO HID
		FROM HOUSES
		WHERE USER_ID = :OLD.USER_ID;
	END IF;
	
	IF NO_OF_HOUSES = 1 AND HID = :OLD.HOUSE_ID THEN
		UPDATE USERS
		SET IS_HOST = 0
		WHERE USER_ID = :OLD.USER_ID;
		DBMS_OUTPUT.PUT_LINE('Host removed');
	END IF;
	COMMIT;
END;