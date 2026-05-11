@echo off
echo Inserting test data with correct encoding...
set NLS_LANG=AMERICAN_AMERICA.AL32UTF8
sqlplus jw_admin/oracle123@localhost:1521/TEACHING @"%~dp0sql\08_test_data.sql"
echo Done!
pause
