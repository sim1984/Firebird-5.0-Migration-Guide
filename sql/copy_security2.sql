set term ^;

EXECUTE BLOCK
AS
  -- замените на параметры вашей копии БД безопасности
  DECLARE SRC_SEC_DB     VARCHAR(255) = 'd:\fbdata\4.0\security2.fdb';
  DECLARE SRC_SEC_USER   VARCHAR(63) = 'SYSDBA';
  ---------------------------------------------------
  DECLARE PLG$USER_NAME  SEC$USER_NAME;
  DECLARE PLG$COMMENT    BLOB SUB_TYPE TEXT CHARACTER SET UTF8;
  DECLARE PLG$FIRST      SEC$NAME_PART;
  DECLARE PLG$MIDDLE     SEC$NAME_PART;
  DECLARE PLG$LAST       SEC$NAME_PART;
  DECLARE PLG$GROUP_NAME SEC$USER_NAME;
  DECLARE PLG$UID        INT;
  DECLARE PLG$GID        INT;
  DECLARE PLG$PASSWD     VARBINARY(64);
BEGIN
  FOR EXECUTE STATEMENT q'!
      SELECT
          RDB$USER_NAME,
          RDB$GROUP_NAME,
          RDB$UID,
          RDB$GID,
          RDB$PASSWD,
          RDB$COMMENT,
          RDB$FIRST_NAME,
          RDB$MIDDLE_NAME,
          RDB$LAST_NAME
      FROM RDB$USERS
      WHERE RDB$USER_NAME <> 'SYSDBA'
!'
      ON EXTERNAL :SRC_SEC_DB
      AS USER :SRC_SEC_USER
      INTO
          :PLG$USER_NAME,
          :PLG$GROUP_NAME,
          :PLG$UID,
          :PLG$GID,
          :PLG$PASSWD,
          :PLG$COMMENT,
          :PLG$FIRST,
          :PLG$MIDDLE,
          :PLG$LAST
  DO
  BEGIN
    INSERT INTO PLG$USERS (
        PLG$USER_NAME,
        PLG$GROUP_NAME,
        PLG$UID,
        PLG$GID,
        PLG$PASSWD,
        PLG$COMMENT,
        PLG$FIRST_NAME,
        PLG$MIDDLE_NAME,
        PLG$LAST_NAME)
    VALUES (
        :PLG$USER_NAME,
        :PLG$GROUP_NAME,
        :PLG$UID,
        :PLG$GID,
        :PLG$PASSWD,
        :PLG$COMMENT,
        :PLG$FIRST,
        :PLG$MIDDLE,
        :PLG$LAST);
  END
END^

set term ;^

commit;

exit;

