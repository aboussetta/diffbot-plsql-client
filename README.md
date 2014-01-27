#Oracle PL/SQL package for working with Diffbot API

##Preface

Purpose of this package is to create routines to work with [Diffbot API](http://diffbot.com/) from Oracle PL/SQL code.
It uses [PL/JSON project](http://sourceforge.net/projects/pljson/) code which implements a lot of useful methods to to work with JSON.
This package could be installed in Oracle 11g and 12c.
In this version have been implemented [Diffbot automatic API](http://diffbot.com/products/automatic/) + analyze command. All calls use GET method.

##Installation

Create or choose Oracle user for workinkg with Diffbot API. He must have grants to create TYPES, PROCEDURES, SYNONYMS. Also, grant execution of UTL_HTTP. For this Readme I use local Sqlplus connection to Oracle from SYS account. You can use any account with SYSDBA role and any Oracle client you like.

```
sqlplus /nolog

SQL*Plus: Release 12.1.0.1.0 Production on Sun Jan 12 07:12:20 2014

Copyright (c) 1982, 2013, Oracle.  All rights reserved.

SQL> conn / as sysdba
Connected.
SQL>
```

If you are using Oracle 12c, you have set the container to the correct database before creating the user

```
SQL> alter session set container=PDBORCL;

Session altered.
```

If you are using Oracle 11g, skip previous step.

```
SQL> CREATE USER dfb IDENTIFIED BY dfb ;
GRANT "RESOURCE" TO dfb ;
GRANT "CONNECT" TO dfb ;
GRANT CREATE PROCEDURE TO dfb ;
GRANT CREATE TYPE TO dfb ;
GRANT CREATE PUBLIC SYNONYM TO dfb ;
GRANT UNLIMITED TABLESPACE TO dfb ;
GRANT EXECUTE on utl_http to dfb;

User created.

SQL> 
Grant succeeded.

SQL> 
Grant succeeded.

SQL> 
Grant succeeded.

SQL> 
Grant succeeded.

SQL> 
Grant succeeded.

SQL>
Grant succeeded. 
```

Logout.

Download [PL/JSON package](http://sourceforge.net/projects/pljson/). If you are unable to download, use archive supplied with Diffbot package archive.
Unzip archive PL/JSON package to any directory accessible to user used for sqlplus invoke. For this Readme I use /opt/ora/pljson.
Connect with user you have created earlier for Diffbot package:

```
sqlplus dfb/dfb@pdborcl

SQL*Plus: Release 12.1.0.1.0 Production on Sun Jan 12 07:34:07 2014

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 12c Enterprise Edition Release 12.1.0.1.0 - 64bit Production
With the Partitioning, OLAP, Advanced Analytics and Real Application Testing options

SQL>
```

Execute install SQL:

```
SQL> @/opt/ora/pljson/install.sql
```

If you are planning to call JSON routines globaly - execute script grantsandsynonyms.sql.
If not - skip this step.

```
SQL> @/opt/ora/pljson/grantsandsynonyms.sql
```

Logout.


Connect with SYSDBA account again:

```
sqlplus /nolog

SQL*Plus: Release 12.1.0.1.0 Production on Sun Jan 12 07:12:20 2014

Copyright (c) 1982, 2013, Oracle.  All rights reserved.

SQL> conn / as sysdba
Connected.
SQL>
```

Create ACL policy for UTL_HTTP call. (For this Readme, I name ACL www.xml and allow connect to any site. You can change this for your needs)

```SQL
begin
DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(acl         => 'www.xml', -- name for ACL
                                    description => 'WWW ACL', -- description of ALC
                                    principal   => 'DIFBOT', -- User from p.2.1
                                    is_grant    => true,
                                    privilege   => 'connect');
DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(acl       => 'www.xml', -- name for ACL
                                       principal => 'DIFBOT', -- User from p.2.1
                                       is_grant  => true,
                                       privilege => 'resolve');
DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(acl  => 'www.xml', -- name for ACL
                                    host => '*'); -- here you could put any hostname or simply live '*' for all sites
end;
/
commit;
/
```

Logout.

Unzip DIFFBOT API PL/SQL package to any directory accessible to user used for sqlplus invoke. For this Readme I use /opt/ora/diffbot.
Connect with user you have created earlier for Diffbot package:

```
sqlplus dfb/dfb@pdborcl

SQL*Plus: Release 12.1.0.1.0 Production on Sun Jan 12 07:34:07 2014

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 12c Enterprise Edition Release 12.1.0.1.0 - 64bit Production
With the Partitioning, OLAP, Advanced Analytics and Real Application Testing options

SQL>
```

Execute install SQL:

```
SQL> @/opt/ora/diffbot/install.sql
```

##Configuration
Get your Token from http://diffbot.com/pricing/. Now, we are ready to use PL/SQL package for Diffbot API.

##Usage

Function 
```SQL 
DIFFBOT_PKG.diffbot(p_api,p_url,p_token,p_fields)``` 
returns JSON object. Possible methods of returned json object you can find in documentation supplied with PL/JSON package.
If call was successful, DIFFBOT_PKG.error_code will contain 'DIFFBOT - OK', and function response will contains json response from Diffbot site.
If there was error in Diffbot function call, DIFFBOT_PKG.error_code will contain short error code, and function respone
will contain error desciption in json format. You can use DIFFBOT_PKG.error_code contens for flow control when diffbot
function is called from your routines, if you like.
Also, you could use 'help' as p_api parameter - in that case function would return simple help in json format.
JSON_PRINTER.ascii_output control output of strings with non latin characters. Setting it to false will convert them
according to session NLS setting. Otherwise, characters will be encoded like this "title" : "\u0424.\u0418.\u041E."
By default, it is set to true.
Parameters:
*p_api* number, Api version by default 2
*p_url* varchar2, Requested URL eg. 'http://www.de'
*p_token* varchar2,  Actual Tocken for diffbod, e.g. 'aaa111dd'
*p_fields* varchar2, fields list in form 'meta,images(*)'. By default, null

###Article API

For this example, we just print response to output buffer.

```SQL
set scan off
set serveroutput on format wrapped
declare
obj json;

begin
  JSON_PRINTER.ascii_output:=false;
  DIFFBOT_PKG.error_code:=null;
  obj:=DIFFBOT_PKG.diffbot(p_api=>'article'
      ,p_url=>'http://www.de'
      ,p_token=>'aaa222ddd'
      ,p_fields=>'');
  obj.print;
  
end;
/
```

Script output will be like this:

```JSON
{
  "title" : "www.de",
  "text" : "",
  "date_created" : "Sun, 12 Jan 2014 05:22:01 PST",
  "categories" : {
    "entertainment_culture" : 0.03023809523809524,
    "hospitality_recreation" : 0.05354788260903279,
    "other" : 0.002857142857142857,
    "business_finance" : 0.0175561639408383,
    "technology_internet" : 0.045476190476190476,
    "socialissues" : 0.04626548130985797,
    "sports" : 0.10008983000797159,
    "humaninterest" : 0.30809523809523803,
    "religion_belief" : 0.05380952380952381,
    "war_conflict" : 0.016666666666666666,
    "education" : 0.004285714285714286,
    "health_medical_pharma" : 0.043404426790298795,
    "labor" : 0.03085164433812626,
    "law_crime" : 0.07023809523809524,
    "politics" : 0.024636242562393086,
    "environment" : 0.06408087715133634,
    "weather" : 0.0698055465282401,
    "disaster_accident" : 0.018095238095238095
  },
  "html" : "<div></div>",
  "type" : "article",
  "cid" : -1,
  "resolved_url" : "http://www.de//?gtnjs=1",
  "url" : "http://www.de"
}
```

###Analyze API

For this example, we just print response to output buffer.

```SQL
set scan off
set serveroutput on format wrapped
declare
obj json;

begin
  JSON_PRINTER.ascii_output:=false;
  DIFFBOT_PKG.error_code:=null;
  obj:=DIFFBOT_PKG.diffbot(p_api=>'analyze'
      ,p_url=>'http://www.de'
      ,p_token=>'aaa333vvv'
      ,p_fields=>'');
  obj.print;
  
end;
/
```
Script output will be like this:

```JSON
{
  "title" : "www.de - www Resources and Information. This website is for sale!",
  "images" : [],
  "type" : "image",
  "resolved_url" : "http://www.de/",
  "human_language" : "en",
  "url" : "http://www.de"
}
```

##Error handling
DIFFBOT_PKG.error_code will contain error code after call. By default, null.

List of error codes:
*DIFFBOT - HELP* - help command or empty command was given
*DIFFBOT - TOKEN* - empty token given
*DIFFBOT - API* - unimplemented api command given
*DIFFBOT - HTTP* - error during HTTP request
*DIFFBOT - OK* - successfull call

For example:

```SQL
set scan off
set serveroutput on format wrapped
declare
obj json;

begin
  DIFFBOT_PKG.error_code:=null;
  obj:=DIFFBOT_PKG.diffbot(p_api=>'analyze'
      ,p_url=>'http://www.de'
      ,p_token=>'aaa333ddd'
      ,p_fields=>'');
  if DIFFBOT_PKG.error_code='DIFFBOT - OK' then
    dbms_output.put_line('Call succsess');
  else
    dbms_output.put_line('Call error: '||DIFFBOT_PKG.error_code);
  end if;
  
end;
/
```


In case of error, response will contain error explanation in json format.

For example:

```SQL
set scan off
set serveroutput on format wrapped
declare
obj json;

begin
  DIFFBOT_PKG.error_code:=null;
  obj:=DIFFBOT_PKG.diffbot(p_api=>'analyze'
      ,p_url=>'http://www.de'
      ,p_token=>''
      ,p_fields=>'');
  obj.print;  
end;
/
```

Output will be:

```JSON
{
  "Error" : "Token is empty",
  "Help" : "Enter valid token"
}
```

