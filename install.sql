PROMPT -- Setting optimize level --

/*
11g
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
ALTER SESSION SET plsql_code_type = 'NATIVE';
*/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 2;

/* (c) 2014 Anton Kolyada   */

PROMPT -----------------------------------;
PROMPT -- Compiling objects for Diffbot --;
PROMPT -----------------------------------;

@@DIFFBOT_PKG.sql
