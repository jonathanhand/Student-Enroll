--start 'C:\Users\handj\Desktop\Spring 2019 Work\IS480\final\enroll.sql'
spool 'C:\Users\handj\Desktop\Spring 2019 Work\IS480\final\enroll.txt'

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
        p_answer IN OUT varchar2) as --out keyword to let know being passed out of procedure
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
        p_answer IN OUT varchar2) as
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
        p_answer IN OUT varchar2) AS
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
            p_answer := p_answer || 'Class is full, ';
        end if;
    end;
    

    procedure check_15hr
        (p_snum students.snum%type,
        p_CallNum schClasses.callnum%type, p_answer IN OUT varchar2) as 
        v_stuStanding number;
        v_courseStanding number;
        v_creditEnrolled number;
        v_creditWant number;
    begin
    /*
    --this is for comparing standing TODO: Take out later
        select standing into v_stuStanding
        from students
        where sNum = p_snum;

        select standing into v_courseStanding
        from schclasses s, courses c
        where p_callNum = s.callnum and c.dept=s.dept and c.cnum = s.cnum;
*/
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

    procedure doubleEnrollment
        (p_snum students.snum%type,
        p_CallNum schClasses.callnum%type, p_error IN OUT varchar2) as
        v_enrDept varchar2(10);
        v_enrCnum varchar2(10);

        cursor cur_class is
            select s.callNum, s.dept, s.cnum, s.section
            from schClasses s, enrollments e
            where e.snum = p_snum and s.callnum = e.callnum;
        
    begin
        select dept into v_enrDept
        from schClasses
        where callnum = p_callNum;

        select Cnum into v_enrCnum
        from schClasses
        where callnum = p_callNum;


        for eachClass in cur_class loop
            if (v_enrDept = eachClass.dept and v_enrCnum = eachClass.Cnum) then
                p_error := p_error || 'Enrolled in another section already, ';
                exit;
            end if;
        end loop;
    end;

    procedure repeatEnrollment
        (p_snum students.snum%type,
        p_CallNum schClasses.callnum%type, p_error IN OUT varchar2) as
        
        cursor cur_enr is
            select s.callNum, e.snum
            from schClasses s, enrollments e
            where e.snum = p_snum and s.callnum = e.callNum;

    begin
        for eachEnr in cur_enr loop
            if (eachEnr.callNum = p_callNum) then
                p_error := p_error || 'Repeat Enrollment, ';
                exit;
            end if;
        end loop;
    end;

    --select standing from students, compare to course want to enroll standing 
    --(join courses and schclasses)
    procedure standingRequirement
        (p_snum students.snum%type,
        p_CallNum schClasses.callnum%type, p_error IN OUT varchar2) as
        v_stuStanding number(1);
        v_courseStanding number(1);

    begin
        select standing into v_stuStanding 
        from students
        where students.snum = p_snum;

        select c.standing into v_courseStanding
        from courses c, schClasses sch
        where sch.callnum = p_callNum and sch.Dept = c.Dept and sch.Cnum = c.cNum;

        if v_stuStanding < v_courseStanding then
            p_error := p_error || 'Student standing too low, ';
        end if;
    end;

    procedure undeclaredMajor
        (p_snum students.snum%type,
        p_CallNum schClasses.callnum%type, p_error IN OUT varchar2) as
        v_stuStanding number(1);
        v_stuMajor students.Major%type;

    begin
        select standing into v_stuStanding 
        from students
        where students.snum = p_snum;

        select major into v_stuMajor
        from students
        where students.snum = p_snum;

        if (v_stuStanding >= 3) then
            if (v_stuMajor is null) then
                p_error := p_error || 'Need to declare major to enroll, ';
            end if;
        end if;

    end;

    procedure AddMe
    (p_snum students.snum%type,
    p_CallNum schClasses.callnum%type) as
    v_errors varchar2(1000);

    begin
        --num1
        check_snum(p_snum, v_errors); --check valid student number
        check_callnum(p_CallNum, v_errors); --check valid call number
        if (v_errors is null) then
            --num2
            repeatEnrollment(p_snum, p_callnum, v_errors);
                --check enrollments if snum already enrolled in callnum (past or present)
            --num3
            doubleEnrollment(p_snum, p_callNum, v_errors);
                --cursor to loop through all of enrollments where snum = student.snum
                --for each record:
                    --check schclasses.dept and cnum does not match p_callnum dept and cnum
                    --if matches, add to v_error message
            --num4
            check_15hr(p_snum, p_callNum, v_errors); --check enrolling will not exceed 15 credits for student
            --num5
                --select standing from students, compare to course want to enroll standing (join courses and schclasses)
            standingRequirement(p_snum, p_callNum, v_errors);
            --num6
            undeclaredMajor(p_snum, p_callNum, v_errors);
                --select standing from students
                --if standing 3 or 4 then
                    --check students.major not null
                    --if major null
                        --error
            --TODO: num7
            check_capacity(p_snum, p_callnum, v_errors);
            --TODO: num8
                --if v_errors is null then
                    --if class capacity full
                        --check if stunum on waitlist table
                        --num9
                            --if not on waitlist with that call num then
                                --insert into waitlist table
                                --print stu num is now on wait list
                            --else
                                --print you're already waitlisted for that 
            if (v_errors is null) then
                insert into enrollments (snum, callnum) values (p_snum, p_callnum);
                dbms_output.put_line('Successfully Enrolled!');
                commit;
            else
                dbms_output.put_line(v_errors);
            end if;
        else --num1: if snum and/or callnum invalid, skip to here
            dbms_output.put_line(v_errors); --skip rest of program and print errors
        end if;
    end;
    
end enroll;
/
show errors;

begin
    Enroll.addme(110, 10110);
    Enroll.addme(106, 10115);

end;
/

spool off;