--VORLAGE
CREATE OR REPLACE FUNCTION function_name ( var_in_1 IN NUMBER, var_in_2 IN NUMBER) 
RETURN NUMBER 
AS 
	select_value NUMBER(11,2), 
	return_value NUMBER(11,2) 
BEGIN  
	
	
EXCEPTION
	WHEN NO_DATA_FOUND THEN   
	RAISE_APPLICATION_ERROR(-20009,'.... nicht vorhanden');
    when others then
    RAISE_APPLICATION_ERROR(-20020, 'Error: ' || substr(1, 80, sqlerrm));
END; 
/



--die als Parameter eine EMPNO erwartet und ermittelt, ob der Mitarbeiter in einer leitenden Position arbeitet. 
create or replace function is_emp_mgr(empno_in in number) 
return varchar2
is   
    v_mgr emp.mgr%type;
begin
    select distinct mgr into v_mgr
    from emp
    where mgr = empno_in;
    
    return 'YES';
    
exception
    when no_data_found then
        return 'NO';
    when others then
        raise_application_error(-20020, 'Error: ' || substr(1, 80, sqlerrm));
end;
/
select is_emp_mgr(7566), is_emp_mgr(7369)
from dual;


--die als Parameter einen Job erwartet und zu diesem das größte Gehalt zurück gibt. Dabei soll der Job in Klein- und/oder Großbuchstaben übergeben werden können.
--Wird zum übergebenen Job kein Gehalt gefunden, soll 0 zurück gegeben werden.
create or replace function get_job_maxsal(job_in in varchar2) 
return number
is   
    v_sal emp.sal%type;
begin
    select max(sal) into v_sal
    from emp
    where job = upper(job_in);
    
    if v_sal is null then
        return 0;
    else
        return v_sal;
    end if;
    
exception
    when others then
        raise_application_error(-20020, 'Error: ' || substr(1, 80, sqlerrm));
end;
/

select get_job_maxsal('analyst')
from dual;

--bei Eingabe von pub_id wird dazu die Stadt ausgegeben
CREATE OR REPLACE FUNCTION get_c_name(in_pub_id IN NUMBER)  
RETURN varchar2 
AS  
	v_c_name lib_city.name%TYPE; 
 
BEGIN  
	SELECT c.name INTO v_c_name  
	FROM lib_city c   
	INNER JOIN lib_publisher p ON (c.c_id = p.c_id)  
	WHERE pub_id = in_pub_id; 
 
	RETURN v_c_name; 
 
EXCEPTION  
	WHEN NO_DATA_FOUND THEN   
	RAISE_APPLICATION_ERROR(-20009,'Publisher nicht vorhanden');  
	WHEN OTHERS THEN     RAISE_APPLICATION_ERROR(-20010,'proc'||    'get_cat_name: '|| substr(SQLERRM,1,80)); 
END; 
/

select get_c_name(4)
from dual;

--Bei Eingabe von Autor ID wird die insgesamt geschriebenen Seiten ausgegeben
CREATE OR REPLACE FUNCTION function_name (autor_id_in IN NUMBER)
RETURN NUMBER 
AS 
	v_pages lib_book.pages%TYPE;
BEGIN  
		select sum(pages) into v_pages
		from lib_book b
		inner join lib_did_write dw on b.book_id=dw.book_id
		inner join lib_author a on dw.auth_id=a.auth_id
		where a.auth_id=autor_id_in
		group by autor_id_in;
		
		RETURN v_pages;
		
EXCEPTION
		WHEN NO_DATA_FOUND THEN   
		RAISE_APPLICATION_ERROR(-20009,'Autor nicht gefunden');  
		WHEN OTHERS THEN     
		RAISE_APPLICATION_ERROR(-20010,'ERROR: '|| substr(SQLERRM,1,80)); 

END; 
/

select function_name(18)
from dual;













