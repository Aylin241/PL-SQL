--Trigger-Sequence Vorlage
CREATE SEQUENCE sq_artikelnr
START WITH 4711
INCREMENT BY 2;

CREATE OR REPLACE TRIGGER T_artkelnr
BEFORE INSERT OR UPDATE OF artikelnr ON artikel
FOR EACH ROW
DECLARE

BEGIN
    :NEW.artikelnr := sq_artikelnr.NEXTVAL;
END;
/



--Trigger VORLAGE
CREATE OR REPLACE TRIGGER name
BEFORE INSERT OR UPDATE OF spalte ON tabelle
FOR EACH ROW

DECLARE
    v_spalte spalte.tabelle%TYPE;
BEGIN
  SELECT DISTINCT spalte INTO v_spalte
  FROM tabelle
  WHERE spalte=:NEW.spalte;
  
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20100,'...nicht vorhanden');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20020,' Trigger FEHLGESCHLAGEN: '|| SUBSTR(SQLERRM,1,80) );
END;
/


--INSERT, UPDATE
CREATE OR REPLACE TRIGGER trigger_name  
	BEFORE INSERT OR UPDATE OF Spalte1, Spalte2 ON Tabelle  
	-- FOR EACH ROW 
BEGIN  
	CASE   
		WHEN INSERTING THEN    
			DBMS_OUTPUT.PUT_LINE('Inserting ' || :NEW.Spalte1)   
		WHEN UPDATING (Spalte1) THEN    
			DBMS_OUTPUT.PUT_LINE('Updating Spalte1')   
		WHEN UPDATING (Spalte2) THEN    
			DBMS_OUTPUT.PUT_LINE('Updating Spalte2')  
		WHEN DELETING THEN    
			DBMS_OUTPUT.PUT_LINE('Deleting ' || :OLD.Spalte1)    
			RAISE_APPLICATION_ERROR (-20501, 'Verboten!');  
	END CASE; 
END;
/



---------------------------------------------------------------------------
		
		
--Verhindern Sie, dass die Fachbereichnummer bestehender Datensätze NICHT GEÄNDERT WERDEN DARF.
create or replace trigger fachb_u 
before update of fachbereichnr on fachbereich
for each row
begin
    RAISE_APPLICATION_ERROR(-20000, 'Ändern der Fachbereichnur nicht zulaessig.');    
end;
/



--die Spalte "Alter" soll AUTOMATISCH GEFÜLLT werden, sobald ein neuer Datensatz hinzugefügt oder ein bestehender geändert wird. 
create or replace trigger person_i
before insert or update of alter_number on person_i
for each row
begin
if : new.geburtsdatum is not null then
        :new.alter_ := trunc(months_between(sysdate, :new.geburtsdatum)/12);
    end if;
end;


--Erzeugen Sie einen Trigger der sicherstellt, dass beim anlegen/andern eines Departments zuerst ein Mitarbeiter in diesem Department erfasst sein muss.
create or replace trigger dept_i
before insert or update of deptno on dept
for each row
declare
    v_deptno emp.deptno%type;
begin
    select distinct deptno into v_deptno
    from emp
    where deptno = :new.deptno;
    
exception
    when no_data_found then
        raise_application_error(-20010, 'Anlegen nicht moeglich! Es befindet sich kein Mitarbeiter in dem Department.');
    when others then
        raise_application_error(-20020, 'Error: ' || substr(1, 80, sqlerrm));
end;
/

--Stellen Sie sicher, dass das AUSLEIH_DATUM beim Einfügen einer Ausleihe immer das aktuelle Tagesdatum enthält. 
Create or Replace Trigger Tr_datum
Before insert on ausleihe
for each row
DECLARE
BEGIN
 :new.ausleih_datum := sysdate;
END;
/



--Erzeugen Sie eine Trigger der das Einfügen neuer Datensätze in die Tabelle EMP PROTOKOLLIERT. 
--Protokoliiert werden soll die EMPNO, das Datum mit Uhrzeit sowie der Nutzer.
create or replace trigger emp_i
before insert on emp
for each row
begin
    insert into emp_log 
	values (:new.empno, sysdate, user);
    
exception
    when others then
        raise_application_error(-20020, 'Error: ' || substr(1, 80, sqlerrm));
end;
/


--Bevor Isbn geändert wird, wenn die Neue ISBN NR ungleich dem Alten ist, wird Fehler ausgegeben
CREATE OR REPLACE TRIGGER lib_book_isbn_u 
BEFORE UPDATE of ISBN ON lib_book 
FOR EACH ROW 

DECLARE  
 
BEGIN  
	IF :NEW.ISBN != :OLD.ISBN THEN 
	RAISE_APPLICATION_ERROR(-20001, ‘ISBN darf nachträglich nicht geändert werden‘);  
	END IF;  
 
EXCEPTION  
	WHEN OTHERS THEN 
	RAISE_APPLICATION_ERROR(-20010,'Trigger lib_book_isbn_u' || substr(SQLERRM,1,80)); 
END; 
/



-----------------------------------------------------------------------------------
--SEQUENZ -TRIGGER

--Sequence erstellen, verhindern dass geändert wird - nur hinzufügen erlauben
CREATE SEQUENCE seq_account_id
 START WITH 1000
 INCREMENT BY 1
 MAXVALUE 99999999
 CYCLE / NOCYLE
 CACHE / NOCACHE 20;

CREATE OR REPLACE TRIGGER BIU_ACCOUNT
BEFORE INSERT OR UPDATE OF account_id ON account
FOR EACH ROW
DECLARE

BEGIN
  IF UPDATING('account_id') THEN
    RAISE_APPLICATION_ERROR(-20001, 'Die Account-ID darf nicht verändert oder frei gewählt werden!');
  END IF;

  IF INSERTING THEN
    :NEW.account_id := seq_account_id.NEXTVAL;
  END IF;
END;
/





--sicherstellen, dass vor dem Einfügen die Nummer aus einer SEQUENZ genommen wird
create or replace trigger trig_doz_i
before insert on dozent
for each row
begin
:new.dozentennummer:=doz_seq.nextval;
end;
/
	

--Schreibe einen Trigger, der sicherstellt, dass beim Einfügen in lib_category als Kategorie-ID eine 
--fortlaufende Nummer AUS EINER SEQUENZ vergeben wird. Diese Nummer soll bei 5 beginnen. 
CREATE SEQUENCE seq_cat
START WITH 5
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER T_cat
BEFORE INSERT OR UPDATE OF cat_id ON lib_category
FOR EACH ROW
DECLARE

BEGIN
    :NEW.cat_id := seq_cat.NEXTVAL;
END;
/

--Stellen Sie sicher, dass beim Einfügen einer neuen Kundin der 
--Wert für „KNr“ immer aus der Sequence „kunde_seq“ mit dem Startwert 10 genommen wird. 
CREATE SEQUENCE kunde_seq
START WITH 10;

CREATE OR REPLACE TRIGGER T_kunde
BEFORE INSERT ON kunde
FOR EACH ROW
DECLARE
BEGIN
    if lower(:new.geschlecht) = 'w' THEN
        :NEW.knr := kunde_seq.NEXTVAL;
    end if;
END;
/



CREATE OR REPLACE TRIGGER klausur_i
BEFORE INSERT OR UPDATE OF klausurnr ON klausur
FOR EACH ROW
DECLARE
  v_klausurnr klausur.klausurnr%TYPE;
  v_klausurnr 
BEGIN
  SELECT DISTINCT klausurnr INTO v_klausurnr
  FROM klaus_bezie_angebo
  WHERE klausurnr=:NEW.klausurnr;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20100,'Klausur ist noch keinem Angebot 
      zugeordnet');
  WHEN OTHERS THEN
    v_err_msg:='Trigger: klausur_i: '||SUBSTR(SQLERRM,1,80);
    RAISE_APPLICATION_ERROR(-20020,v_err_msg);
END;
/


--Sicherstellen, dass beim einfügen einer neuen Klausur vorher in der Tabelle 
--kba eine Zuordnung zu dieser klausur erfolgen muss.
CREATE OR REPLACE TRIGGER klausur_i
BEFORE INSERT ON klausur
FOR EACH ROW
DECLARE
  v_klausurnr klausur.klausurnr%TYPE;

BEGIN
  SELECT DISTINCT klausurnr INTO v_klausurnr
  FROM klaus_bezie_angebo
  WHERE klausurnr=:NEW.klausurnr;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20100,'Klausur ist noch keinem Angebot 
      zugeordnet');
END;
/











