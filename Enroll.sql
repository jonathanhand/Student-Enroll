--start 'C:\Users\handj\Desktop\Spring 2019 Work\IS480\final\enroll.sql'
spool 'C:\Users\handj\Desktop\Spring 2019 Work\IS480\final\enroll.sql'
set serveroutput on
set echo on

--Jonathan Hand
--IS 480
--Final Project
create or replace Package Enroll as
--just addme and drop me in spec
--procedure DropMe

    procedure AddMe
        (p_snum students.snum%type,
        p_CallNum schClasses.callnum%type);

end Enroll;
/
show errors;
create or replace Package body Enroll as
    procedure check_snum
        (p_snum students.snum%type,
        p_answer OUT varchar2) as --out keyword to let know being passed out of procedure
        v_count number;

    begin
        select count(snum) into v_count
        from students
        where snum = p_snum;
        if v_count = 0 then
            p_answer:= p_answer || 'Invalid Student Number, ';

        end if;
    end;

    PROCEDURE check_CALLNUM
        (p_callnum schclasses.callnum%type,
        p_answer OUT varchar2) as
        v_count number;

    begin
        select count(*) into v_count
        from schclasses
        where callnum = p_callnum;
        if v_count = 0 then
            p_answer := p_answer || 'Invalid Call Number, ';
        end if;
    end;
    

    procedure check_capacity
        (p_snum students.snum%type,
        p_callnum schClasses.callnum%type,
        p_answer OUT varchar2) AS
        v_capacity number(3);
        v_reserved number(3);

    begin
        select sch.capacity into v_capacity 
        from schClasses sch 
        where p_callnum = sch.callnum;
        
        select count(e.callnum) into v_reserved
        from enrollments e, schClasses sch
        where sch.callnum = e.callnum and e.callnum = p_callnum;

        if (v_capacity <= v_reserved) then
            p_answer := p_answer || 'Class too full, ';
        end if;
    end;
    

    procedure check_15hr
        (p_snum varchar2, p_callNum varchar2, p_answer OUT varchar2) as 
        v_stuStanding number;
        v_courseStanding number;
        v_creditEnrolled number;
        v_creditWant number;
    begin
        select standing into v_stuStanding
        from students
        where sNum = p_snum;

        select standing into v_courseStanding
        from schclasses s, courses c
        where p_callNum = s.callnum and c.dept=s.dept and c.cnum = s.cnum;

        select nvl(sum(c.CRHR), 0) into v_creditEnrolled
        from courses c, enrollments e, schclasses s
        where c.dept=s.dept and c.cnum = s.cnum and e.callnum = s.callnum and e.snum = p_snum;

        select c.crhr into v_creditWant
        from courses c, schclasses s 
        where p_callnum = s.callnum and c.dept=s.dept and c.cnum = s.cnum;

        if (v_creditEnrolled + v_creditWant) > 15 then
            p_answer := p_answer || 'Too many units to register, ';
        end if;
    end;

    procedure AddMe
    (p_snum students.snum%type,
    p_CallNum schClasses.callnum%type) as
    v_snumValid varchar2(20);
    v_callValid varchar2(20);
    v_errors varchar2(1000);

    begin
        check_snum(p_snum, v_errors);
        check_callnum(p_CallNum, v_errors);
        --num 1
        if (v_errors is null) then
            check_capacity(p_snum, p_callnum, v_errors);
            check_15hr(p_snum, p_callNum, v_errors);
            if (v_errors is null) then
                insert into enrollments (snum, callnum) values (p_snum, p_callnum);
                dbms_output.put_line('Successfully Enrolled!');
                commit;
            else
                dbms_output.put_line(v_errors);
            end if;
        else
            dbms_output.put_line(v_errors);
        end if;
        exception
        when DUP_VAL_ON_INDEX
        then dbms_output.put_line('Already Enrolled!');
    end;
    
end enroll;
/
show errors;

begin
    Enroll.addme(101, 10110);
    Enroll.addme(105, 10160);
    Enroll.addme(104, 12222);
    Enroll.addme(103, 10140);
    Enroll.addme(106, 10160);
end;
/

spool off;