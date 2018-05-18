# PL-SQL
--PROCEDURE VORLAGE (mit cursor)
CREATE OR REPLACE PROCEDURE proc_name (name_in IN Dtyp, name_out OUT Dtyp)
AS

		v_    tab.spalte%TYPE;

		cursor cur_n is 
			

BEGIN 
		open cur_n;
		LOOP
			Fetch cur_n into v_  ;
			exit when cur_n%NOTFOUND;
			DBMS_OUTPUT.PUT_LINE(     );
		END LOOP;
		close cur_n;

EXCEPTION
	WHEN no_data_found THEN
		RAISE_APPLICATION_ERROR (-20050, '.... nicht vorhanden' ); 
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20060,'Problem: '||'Fehlermeldung: '|| substr(SQLERRM,1,80));
END;
/

DECLARE
	name_out number(20,2); --out parameter mit Datentyp
BEGIN
	proc_name(name_in, v_ok);
END;
/


--Procedure, die bei Eingabe von Fachnr und Studiengangnr das Angebot einträgt
CREATE OR REPLACE PROCEDURE Angebot_ein (fachnr_in IN NUMBER, studiengangnr_in IN NUMBER)
AS

BEGIN 
Insert into angebot(studiengangnr, fachnr)
values(fachnr_in, studiengangnr_in);

EXCEPTION
	WHEN no_data_found THEN
		RAISE_APPLICATION_ERROR (-20050, 'Datei nicht gefunden' ); 
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20060,'Problem:'||'Fehler: '|| substr(SQLERRM,1,80));

END;
/




--ermittelt, ob der eingeloggte user existiert, angemeldet ist. Falls ja 1 falls nein 0 als ausgabe

CREATE OR REPLACE PROCEDURE name (eingabe IN number,
    ausgabe OUT number)
AS
 v_matrikelnr studentische_person.matrikelnr%TYPE;
 v_klausurnr anmeldung.klausurnr%TYPE;

BEGIN
	BEGIN
		SELECT matrikelnr INTO v_matrikelnr
		FROM studentische_person
		WHERE unix_name = USER;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20008,'Es gibt keinen 
				Studierenden mit der Kennung '||USER||'!');
	END;

	BEGIN
		SELECT klausurnr INTO v_klausurnr
		FROM anmeldung
		WHERE matrikelnr=v_matrikelnr 
			AND klausurnr=in_klausur_nr;

		out_angemeldet:=1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		out_angemeldet:=0;
	END;

EXCEPTION
 WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20010,'proc'||
   'get_klausur_angemeldet: '|| substr(SQLERRM,1,80));
END;
/


--Prozedur, die alle Zahlen zw. 1-100 auf der Konsole ausgibt egal ob gerade oder ungerade

create or replace procedure gerade_ungerade 
is   
begin
    for i in 1..100 loop
        if mod(i, 2) = 0 then
            dbms_output.put_line('gerade:   ' || i);
        else
            dbms_output.put_line('ungerade: ' || i);
        end if;    
    end loop;

exception
    when others then
        raise_application_error(-20020, 'Error: ' || substr(1, 80, sqlerrm));
end;
/

exec gerade_ungerade;





--Prozedure,die den Namen und Job des Mitarbeiters mit der No 7782 aus der Tabelle EMP ausliest die als Parameter eine 
--EMPNO erwartet und den zugehörigen Namen und Job auf der Konsole ausgibt. 

create or replace procedure show_emp(empno_in in number) 
is
    v_name emp.ename%type;
    v_job emp.job%type;
begin
    select ename, job into v_name, v_job
    from emp
    where empno = empno_in;

    dbms_output.put_line('Name: ' || v_name);    
    dbms_output.put_line('Job: ' || v_job);    
exception
    when no_data_found then
        raise_application_error(-20010, 'Mitarbeiter nicht gefunden!');
    when others then
        raise_application_error(-20020, 'Error: ' || substr(1, 80, sqlerrm));
end;
/
exec show_emp(7782);





--Schreiben Sie eine Stored Procedure die als Parameter eine DepartmentNo erwartet und alle zugehörigen 
--Mitarbeiter (EMPNO, ENAME, JOB), absteigend nach EMPNO, auf der Konsole ausgibt.
CREATE OR REPLACE PROCEDURE dep_mitarbeiter (deptno_in IN NUMBER)
AS
v_empno emp.empno%TYPE;
v_ename emp.ename%TYPE;
v_job emp.job%TYPE;

		cursor cur_dep is 
			select empno, ename, job 
			from emp
			where deptno=deptno_in;

BEGIN 
		open cur_dep;
		LOOP 
			Fetch cur_dep into v_empno, v_ename, v_job;
			exit when cur_dep%notfound;
			Dbms_output.put_line('Im Department ' || deptno_in ||' arbeiten ' || v_empno||' ' || v_ename || ' ' || v_job);
		END LOOP;
		close cur_dep;
				

EXCEPTION
	WHEN no_data_found THEN
		RAISE_APPLICATION_ERROR (-20050, '.... nicht vorhanden' ); 
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20060,'Problem:'||'....: '|| substr(SQLERRM,1,80));
END;
/

exec dep_mitarbeiter(30);


--als IN Parameter eine EMPNO erwartet und über einen OUT Parameter die Anzahl aller Mitarbeiter mit dem gleichen Job zurück gibt.
create or replace procedure emp_job_count(empno_in in number, jobcount_out out number) 
is
begin
    select count(*) into jobcount_out
    from emp
    where job = (select job
                from emp
                where empno = empno_in);    
  
exception
    when no_data_found then
        raise_application_error(-20010, 'Mitarbeiter nicht gefunden!');
    when others then
        raise_application_error(-20020, 'Error: ' || substr(1, 80, sqlerrm));
end;
/

DECLARE
	v_ok number;
BEGIN
	emp_job_count(7900, v_ok);
	DBMS_OUTPUT.PUT_LINE(v_ok);
END;
/


--bei eingabe von studiengangnr, matrikelnr ausgeben
CREATE OR REPLACE PROCEDURE studi_report (studiengangnr_in IN number)
as 

begin 

for rec_report in (select matrikelnr 
					from studentische_person
					where studiengangnr=studiengangnr_in) loop 
dbms_output.put_line('Studierende: ' ||rec_report.matrikelnr);
end loop;


EXCEPTION
WHEN no_data_found THEN
raise_application_error (-20009, 'Keine Exemplare vorhanden' ); 
 WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20010,'proc:'||
   'ausleihv: '|| substr(SQLERRM,1,80));
END;
/


exec studi_report (904);





--Erstelle eine Prozedur, die das anlegen von Benutzern durch übergabe von Parametern ermöglicht.
CREATE OR REPLACE PROCEDURE benutzer (in_surname IN VARCHAR2, in_forename IN VARCHAR2, in_email IN VARCHAR2)
AS

BEGIN
  INSERT INTO account
  VALUES (
    (SELECT MAX(account_id) + 1 FROM account),
    in_surname,
    in_forename,
    in_email,
    SYSDATE,
    SYSDATE
  );
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE ('Folgender unerwarteter Fehler ist aufgetreten: ');
    RAISE;
END;
/

exec benutzer('Aylin', 'Yildirim', 'blabla@live.de');




-- Schreiben Sie eine stored procedure, die bei Eingabe einer Matrikelnummer die Ausgabe FACHBEZEICHNUNG, 
--NOTE erzeugt zu allen Einträgen, die zu dieser Matrikelnummer in der Tabelle leistungsschein vorliegen.

CREATE OR REPLACE PROCEDURE p_leistung (matrikelnr_in IN number,
    fachb_out OUT number, note_out OUT number)
AS
 v_bezeichnung fach.bezeichnung%TYPE;
 v_note leistungsschein.note%TYPE;

 cursor cur_name is
 select bezeichnung, note
 from leistungsschein
 inner join fach on leistungsschein.fachnr=fach.fachnr
 where matrikelnr=matrikelnr_in;
 
BEGIN

open cur_name;
loop
	fetch cur_name into v_bezeichnung, v_note;
	exit when cur_name%notfound;
	dbms_output.put_line('Leistung von :' || matrikelnr_in || ' '|| v_bezeichnung ||' '|| v_note  );
end loop;
close cur_name;

EXCEPTION
 WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20010,'keine Leistung vorhanden'|| substr(SQLERRM,1,80));
END;
/


--AUSGABE
DECLARE
	v_ok Varchar2(200);
	v_ol Number;
BEGIN
	p_leistung (123456, v_ok, v_ol);
	dbms_output.put_line(v_ok ||  v_ol  );
END;
/





--Bei eingabe von Name -> Falls note besser als 2, dann sehr gut - wenn schlechter trotzdem gut ausgeben
Create or Replace Procedure P_Test (name_in IN Varchar2)
AS
	v_name studentische_person.name%TYPE;
	v_note anmeldung.note%TYPE;
	
	Cursor cur_note is
		select name, note
		from studentische_person
		inner join anmeldung on studentische_person.matrikelnr=anmeldung.matrikelnr
		where klausurnr=3 and name=name_in;

BEGIN
	Open cur_note;
	LOOP
		fetch cur_note into v_name, v_note;
		Exit when cur_note%NOTFOUND;
		if v_note < '2' THEN
		DBMS_Output.Put_Line('Sehr gut! '|| ' ' ||'Name: ' || v_name || ' ' || 'Note: ' || v_note);
		else
		DBMS_Output.Put_Line('Trotzdem gut! ' || ' ' ||'Name: ' || v_name || ' ' || 'Note: ' || v_note);
		end if;
	END LOOP;
	Close cur_note;
	
	
EXCEPTION
	When others THEN
	DBMS_Output.Put_Line('Folgender Fehler ist aufgetreten: ' );
	RAISE;
END;
/

exec P_Test('Nicole Mueller')


--Bei Eingabe von Buch_ID wird die Kategorie ausgegeben
CREATE OR REPLACE PROCEDURE get_cat_namen(in_book_id IN NUMBER, out_cat_name OUT VARCHAR2 ) 
AS  

BEGIN  
	SELECT cat_name INTO out_cat_name
	FROM lib_book b   
	INNER JOIN lib_category c ON (b.cat_id = c.cat_id)  
	WHERE book_id = in_book_id; 
 
 
EXCEPTION  
	WHEN NO_DATA_FOUND THEN   
	RAISE_APPLICATION_ERROR(-20009,'Buch nicht vorhanden');  
	WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20010,'proc:get_cat_name: '|| substr(SQLERRM,1,80)); 
	
END;
/

DECLARE
	out_cat_name VARCHAR2(30);
BEGIN
	get_cat_namen(4, out_cat_name);
	DBMS_OUTPUT.PUT_LINE(out_cat_name);
END;
/

--Prozedur, die bei Eingabe einer lend_id das aktuellste Ausleihdatum für diesen Kunden zurückgibt. 
--Rufe die Prozedur auf und lasse dir das aktuellste Ausleihdatum für den Kunden mit der lend_id 3 ausgeben 
CREATE OR REPLACE PROCEDURE ausleihe_pro (lend_id_in IN Number, lend_out OUT DATE)
AS
	
BEGIN 

	select max(lend) into lend_out
	from lib_rental
	where l_id=lend_id_in;
	
	
	DBMS_OUTPUT.PUT_LINE('Kunde mit der Nr: ' || lend_id_in || ' Ausleihdatum: ' || lend_out);
	
		
EXCEPTION
	WHEN no_data_found THEN
		RAISE_APPLICATION_ERROR (-20050, '.... nicht vorhanden' ); 
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20060,'Problem:'||'....: '|| substr(SQLERRM,1,80));

END;
/

DECLARE
	lend_out DATE;
BEGIN
	ausleihe_p(3, lend_out);
END;
/


--Gebe ein Studiengang mit den jeweiligen Studenten aus
Create or Replace Procedure p_student (studiengangnr_in in Number, Name_out out Varchar2)
as

	Cursor cur_student is
		select name
		from studentische_person
		where studiengangnr=studiengangnr_in;

BEGIN
		DBMS_OUTPUT.PUT_LINE('Studiengangnr: '|| studiengangnr_in );
					
		FOR REC_CUR IN CUR_STUDENT LOOP
			name_out := rec_cur.name;
			DBMS_OUTPUT.PUT_LINE('Studiert: '|| name_out);
		END LOOP;		
END;
/

DECLARE
	v_ok varchar2(200);
BEGIN
	p_student(904, v_ok);	
END;
/

		

--Schreiben Sie eine STORED PROCEDURE mit geeigneter Fehlerbehandlung, die als Parameter eine Bestellnummer erwartet und den Gesamtwert über alle Bestellpositionen der Bestellung ausgibt. 
--Die Einzelpreise befinden sich in der Tabelle PESCHM.ARTIKEL oder ihrem zuvor angelegtem Synonym.
CREATE OR REPLACE PROCEDURE proc_gesamtwert (bestellnr_in IN NUMBER, gesamtwert_out OUT NUMBER)
AS	
	
	cursor cur_wert is
		select sum(menge*preis) as gesamtwert 
		from bestell_position bp
		inner join artikel a on bp.artikelnr=a.artikelnr
		where bestellnr=bestellnr_in;

BEGIN 
	open cur_wert;
	LOOP
		FETCH cur_wert into gesamtwert_out;
		exit when cur_wert%notfound;
		DBMS_OUTPUT.PUT_LINE('Bestellnr: '|| bestellnr_in || ' hat folgenden Gesamtwert: ' || gesamtwert_out );
	END LOOP;
	close cur_wert;

EXCEPTION
	WHEN no_data_found THEN
		RAISE_APPLICATION_ERROR (-20050, '.... nicht vorhanden' ); 
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20060,'Problem:'||'....: '|| substr(SQLERRM,1,80));
END;
/

DECLARE
	v_ok NUMBER(20,4);
BEGIN
	proc_gesamtwert(6, v_ok);
	
END;
/
