@echo off
chcp 936 >nul
echo ============================================
echo   Oracle Database Init Script
echo   E-Commerce Order Management System
echo ============================================
echo.

set DB_USER=jw_admin
set DB_PASS=oracle123
set DB_CONN=localhost:1521/TEACHING
set SQL_DIR=%~dp0sql
set NLS_LANG=AMERICAN_AMERICA.AL32UTF8

echo DB User: %DB_USER%
echo DB Connection: %DB_CONN%
echo SQL Dir: %SQL_DIR%
echo.

REM Check if sqlplus is available
where sqlplus >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] sqlplus command not found!
    echo.
    echo Please add Oracle bin directory to PATH, for example:
    echo   C:\oraclexe\app\oracle\product\11.2.0\server\bin
    echo.
    echo Or find your Oracle installation and add the bin folder to PATH.
    echo.
    pause
    exit /b 1
)

echo [0/9] NOTE: Run 00_create_user.sql as SYSTEM user first if user doesn't exist
echo.

echo [1/9] Running 01_init.sql ...
sqlplus %DB_USER%/%DB_PASS%@%DB_CONN% @"%SQL_DIR%\01_init.sql"
if %errorlevel% neq 0 (
    echo [ERROR] 01_init.sql failed!
    pause
    exit /b 1
)
echo [OK] 01_init.sql done
echo.

echo [2/9] Running 02_sequences.sql ...
sqlplus %DB_USER%/%DB_PASS%@%DB_CONN% @"%SQL_DIR%\02_sequences.sql"
if %errorlevel% neq 0 (
    echo [ERROR] 02_sequences.sql failed!
    pause
    exit /b 1
)
echo [OK] 02_sequences.sql done
echo.

echo [3/9] Running 03_triggers.sql ...
sqlplus %DB_USER%/%DB_PASS%@%DB_CONN% @"%SQL_DIR%\03_triggers.sql"
if %errorlevel% neq 0 (
    echo [ERROR] 03_triggers.sql failed!
    pause
    exit /b 1
)
echo [OK] 03_triggers.sql done
echo.

echo [4/9] Running 04_packages.sql ...
sqlplus %DB_USER%/%DB_PASS%@%DB_CONN% @"%SQL_DIR%\04_packages.sql"
if %errorlevel% neq 0 (
    echo [ERROR] 04_packages.sql failed!
    pause
    exit /b 1
)
echo [OK] 04_packages.sql done
echo.

echo [5/9] Running 05_materialized_views.sql ...
sqlplus %DB_USER%/%DB_PASS%@%DB_CONN% @"%SQL_DIR%\05_materialized_views.sql"
if %errorlevel% neq 0 (
    echo [ERROR] 05_materialized_views.sql failed!
    pause
    exit /b 1
)
echo [OK] 05_materialized_views.sql done
echo.

echo [6/9] Running 06_aq_setup.sql ...
sqlplus %DB_USER%/%DB_PASS%@%DB_CONN% @"%SQL_DIR%\06_aq_setup.sql"
if %errorlevel% neq 0 (
    echo [ERROR] 06_aq_setup.sql failed! May need DBA grant:
    echo   GRANT EXECUTE ON DBMS_AQADM TO %DB_USER%;
    pause
    exit /b 1
)
echo [OK] 06_aq_setup.sql done
echo.

echo [7/9] Running 07_rls_setup.sql ...
sqlplus %DB_USER%/%DB_PASS%@%DB_CONN% @"%SQL_DIR%\07_rls_setup.sql"
if %errorlevel% neq 0 (
    echo [ERROR] 07_rls_setup.sql failed! May need DBA grants:
    echo   GRANT EXECUTE ON DBMS_RLS TO %DB_USER%;
    echo   GRANT CREATE ANY CONTEXT TO %DB_USER%;
    echo   GRANT EXECUTE ON DBMS_SESSION TO %DB_USER%;
    pause
    exit /b 1
)
echo [OK] 07_rls_setup.sql done
echo.

echo [8/9] Running 08_test_data.sql ...
sqlplus %DB_USER%/%DB_PASS%@%DB_CONN% @"%SQL_DIR%\08_test_data.sql"
if %errorlevel% neq 0 (
    echo [ERROR] 08_test_data.sql failed!
    pause
    exit /b 1
)
echo [OK] 08_test_data.sql done
echo.

echo [9/9] Running 09_admin_user_en.sql ...
sqlplus %DB_USER%/%DB_PASS%@%DB_CONN% @"%SQL_DIR%\09_admin_user_en.sql"
if %errorlevel% neq 0 (
    echo [ERROR] 09_admin_user_en.sql failed!
    pause
    exit /b 1
)
echo [OK] 09_admin_user_en.sql done
echo.

echo ============================================
echo   Database init complete!
echo ============================================
echo.
echo Press any key to exit...
pause >nul
