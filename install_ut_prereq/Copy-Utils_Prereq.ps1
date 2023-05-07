Copy-Item ..\..\oracle_plsql_utils\endspool.sql .
Copy-Item ..\..\oracle_plsql_utils\initspool.sql .

Copy-Item ..\..\trapit_oracle_tester\lib\grant_trapit_to_app.sql .\lib
Copy-Item ..\..\trapit_oracle_tester\lib\install_trapit.sql .\lib
Copy-Item ..\..\trapit_oracle_tester\lib\trapit.pkb .\lib
Copy-Item ..\..\trapit_oracle_tester\lib\trapit.pks .\lib
Copy-Item ..\..\trapit_oracle_tester\lib\trapit_run.pkb .\lib
Copy-Item ..\..\trapit_oracle_tester\lib\trapit_run.pks .\lib
Copy-Item ..\..\trapit_oracle_tester\lib\lib.bat .\lib

Copy-Item ..\..\trapit_oracle_tester\app\app.bat .\app
Copy-Item ..\..\trapit_oracle_tester\app\c_trapit_syns.sql .\app