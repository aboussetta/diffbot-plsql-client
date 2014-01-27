CREATE OR REPLACE package diffbot_pkg as 

  /* 
  Simple package for using Diffbot API (http://diffbot.com) from PL/SQL
  ver.0.1
  
  (c) Anton Kolyada, 2014
  anton.kolyada at gmail.com
  
  Simple call (here, 'frontpage' api command used, response contents will be printed to output buffer)

  set scan off
  set serveroutput on format wrapped
  declare
  obj json;

begin
  JSON_PRINTER.ascii_output:=false;
  DIFFBOT_PKG.error_code:=null;
  obj:=DIFFBOT_PKG.diffbot(p_api=>'frontpage'
      ,p_url=>'http://www.ru'
      ,p_token=>'aaaaaaa'
      ,p_fields=>'');
  obj.print;
  
end;

  Parameters
   p_api IN varchar2 - Diffbot API command
   p_url IN varchar2 - URL
   p_token IN varchar2 - your token for Diffbot usage
   p_version IN number - Diffbot API version number, default 2
   p_fields IN varchar2 - fields list in form 'meta,images(*)'. By default, null

 Error codes (DIFFBOT_PKG.error_code variable)
	 By default, null
	'DIFFBOT - HELP' - help command or empty command was given
	'DIFFBOT - TOKEN' - empty token given
	'DIFFBOT - API' - unimplemented api command given
	'DIFFBOT - HTTP' - error during HTTP request
	'DIFFBOT - OK' - successfull call
  
  */
  error_code varchar2(50);
  function diffbot(p_api varchar2,p_url varchar2,p_token varchar2
  ,p_version number default 2,p_fields varchar2 default null) return json;

end diffbot_pkg;
/


CREATE OR REPLACE package body diffbot_pkg as

function diffbot(p_api varchar2,p_url varchar2,p_token varchar2
,p_version number default 2,p_fields varchar2 default null) return json as
  resp clob;
  v_url varchar2(32000);
  is_error BOOLEAN:=false;
  begin
    if nvl(upper(p_api),'HELP')='HELP' then
      is_error:=true;
      error_code:='DIFFBOT - HELP';
      resp:='{"Error": "API command is empty or help command entered", "Help": "Commands are article,analyze,product,image,frontpage"}';
    else
      case
        when p_token is null then
          is_error:=true;
          error_code:='DIFFBOT - TOKEN';
          resp:='{"Error": "Token is empty", "Help": "Enter valid token"}';
        when p_api='article' then
          v_url:='api.diffbot.com/v'||p_version||'/'||p_api||'?token='||p_token||'&url='||p_url||'&fields='||p_fields;
        when p_api='analyze' then
          v_url:='api.diffbot.com/v'||p_version||'/'||p_api||'?token='||p_token||'&url='||p_url||'&fields='||p_fields;
        when p_api='product' then
          v_url:='api.diffbot.com/v'||p_version||'/'||p_api||'?token='||p_token||'&url='||p_url||'&fields='||p_fields;
        when p_api='image' then
          v_url:='api.diffbot.com/v'||p_version||'/'||p_api||'?token='||p_token||'&url='||p_url||'&fields='||p_fields;
        when p_api='frontpage' then
          v_url:='api.diffbot.com/v'||p_version||'/'||p_api||'?token='||p_token||'&url='||p_url||'&fields='||p_fields;
        else
          is_error:=true;
          error_code:='DIFFBOT - API';
          resp:='{"Error": "API command is wrong", "Help": "To show help use help as API command"}';
      end case;
      if not is_error then
        begin
          select httpuritype(v_url).getclob() into resp from dual;
          error_code:='DIFFBOT - OK';
        exception
        when others then
          is_error:=true;
          error_code:='DIFFBOT - HTTP';
          resp:='{"Error": "HTTP call error", "Reason": "'||UTL_HTTP.GET_DETAILED_SQLERRM||'",
          "URL": "'||v_url||'"}';
        end;
      end if;
    end if;
    return json(resp);
    
  exception 
  when others then
    is_error:=true;
    error_code:='DIFFBOT - GENERAL';
    resp:='{"Error": "General error", "Reason": "'||SQLERRM||'"}';
    return json(resp);
end diffbot;

end diffbot_pkg;
/
sho err
