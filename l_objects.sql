DEFINE SCHEMA=&1
@initspool l_objects_&SCHEMA
COLUMN object_name FORMAT A30
PROMPT Objects in schema &SCHEMA created within last minute
SELECT object_type, object_name, status
  FROM user_objects
 WHERE created > SYSDATE - 1 / 24 / 60
ORDER BY 1, 2
/
@endspool
exit