set term ^;

EXECUTE BLOCK
AS
  -- замените на параметры вашей копии БД безопасности
  DECLARE SRC_SEC_DB     VARCHAR(255) = 'f:\fbdata\4.0\SECURITY30.FDB';
  DECLARE SRC_SEC_USER   VARCHAR(63) = 'SYSDBA';
  ---------------------------------------------------
  DECLARE PLG$USER_NAME  SEC$USER_NAME;
  DECLARE PLG$VERIFIER   VARCHAR(128) CHARACTER SET OCTETS;
  DECLARE PLG$SALT       VARCHAR(32) CHARACTER SET OCTETS;
  DECLARE PLG$COMMENT    BLOB SUB_TYPE TEXT CHARACTER SET UTF8;
  DECLARE PLG$FIRST      SEC$NAME_PART;
  DECLARE PLG$MIDDLE     SEC$NAME_PART;
  DECLARE PLG$LAST       SEC$NAME_PART;
  DECLARE PLG$ATTRIBUTES BLOB SUB_TYPE TEXT CHARACTER SET UTF8;
  DECLARE PLG$ACTIVE     BOOLEAN;
  DECLARE PLG$GROUP_NAME SEC$USER_NAME;
  DECLARE PLG$UID        PLG$ID;
  DECLARE PLG$GID        PLG$ID;
  DECLARE PLG$PASSWD     PLG$PASSWD;
BEGIN
  -- перемещаем пользователей из плагина SRP
  FOR EXECUTE STATEMENT Q'!
      SELECT
          PLG$USER_NAME,
          PLG$VERIFIER,
          PLG$SALT,
          PLG$COMMENT,
          PLG$FIRST,
          PLG$MIDDLE,
          PLG$LAST,
          PLG$ATTRIBUTES,
          PLG$ACTIVE
      FROM PLG$SRP
      WHERE PLG$USER_NAME <> 'SYSDBA'
!'
          ON EXTERNAL :SRC_SEC_DB
          AS USER :SRC_SEC_USER
          INTO :PLG$USER_NAME,
               :PLG$VERIFIER,
               :PLG$SALT,
               :PLG$COMMENT,
               :PLG$FIRST,
               :PLG$MIDDLE,
               :PLG$LAST,
               :PLG$ATTRIBUTES,
               :PLG$ACTIVE
  DO
  BEGIN
    INSERT INTO PLG$SRP (
        PLG$USER_NAME,
        PLG$VERIFIER,
        PLG$SALT,
        PLG$COMMENT,
        PLG$FIRST,
        PLG$MIDDLE,
        PLG$LAST,
        PLG$ATTRIBUTES,
        PLG$ACTIVE)
    VALUES (
        :PLG$USER_NAME,
        :PLG$VERIFIER,
        :PLG$SALT,
        :PLG$COMMENT,
        :PLG$FIRST,
        :PLG$MIDDLE,
        :PLG$LAST,
        :PLG$ATTRIBUTES,
        :PLG$ACTIVE);
  END
  -- перемещаем пользователей из плагина Legacy_UserManager
  FOR EXECUTE STATEMENT Q'!
      SELECT
          PLG$USER_NAME,
          PLG$GROUP_NAME,
          PLG$UID,
          PLG$GID,
          PLG$PASSWD,
          PLG$COMMENT,
          PLG$FIRST_NAME,
          PLG$MIDDLE_NAME,
          PLG$LAST_NAME
      FROM PLG$USERS
      WHERE PLG$USER_NAME <> 'SYSDBA'
!'
          ON EXTERNAL :SRC_SEC_DB
          AS USER :SRC_SEC_USER
          INTO :PLG$USER_NAME,
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
