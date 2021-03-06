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
        p_CallNum schClasses.callnum%type,
        p_errorMsg OUT varchar2);
    procedure DropMe
        (p_snum students.snum%type,
        p_CallNum schClasses.callnum%type);

end Enroll;
/
show errors;
create or replace Package body Enroll as
-----------------------------------ADD ME PROCEDURES--------------------------------
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

    procedure check_15hr
        (p_snum students.snum%type,
        p_CallNum schClasses.callnum%type, p_answer IN OUT varchar2) as 
        v_stuStanding number;
        v_courseStanding number;
        v_creditEnrolled number;
        v_creditWant number;
    begin

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

    procedure check_capacity
        (p_snum students.snum%type,
        p_callnum schClasses.callnum%type,
        p_answer IN OUT varchar2,
        p_full IN OUT boolean) AS
        v_capacity number(3);
        v_reservedG number(3);
        v_reservedN number(3);
        v_reserved number(3);

    begin
        select sch.capacity into v_capacity 
        from schClasses sch 
        where p_callnum = sch.callnum;
        
        select count(e.callnum) into v_reservedG
        from enrollments e, schClasses sch
        where sch.callnum = e.callnum and e.callnum = p_callnum and e.grade != 'W';

        select count(e.callnum) into v_reservedN
        from enrollments e, schClasses sch
        where sch.callnum = e.callnum and e.callnum = p_callnum and e.grade is null;

        v_reserved := v_reservedG + v_reservedN;
        dbms_output.put_line('RESERVED IS: ' || v_reserved);
        if (v_reserved >= v_capacity) then
            p_answer := p_answer || 'Class is full, ';
            p_full := true;
        end if;
    end;
    
    procedure checkWaitlist
        (p_snum students.snum%type,
        p_callnum schClasses.callnum%type,
        p_answer IN OUT varchar2,
        p_waitlisted IN OUT boolean) as
        v_onWaitList number(1);

    begin
        p_waitListed := false;
        select count(snum) into v_onWaitList
        from waitlist
        where snum = p_snum and callnum = p_callnum;

        if (v_onWaitList > 0) then
            p_waitlisted := true;
            dbms_output.put_line('Already on the waitlist for course number ' || p_callNum || '.');
        end if;
    end;

    procedure addToWaitList
        (p_snum students.snum%type,
        p_callnum schClasses.callnum%type) as
    begin
        insert into waitlist values (p_snum, p_callnum, (select current_timestamp from dual));
        dbms_output.put_line('Student number ' || p_snum || ' is now on the waiting list for class number ' || p_callNum || '.');
    end;


---------------------------ADD ME MAIN---------------------------------------------------
    procedure AddMe
    (p_snum students.snum%type,
    p_CallNum schClasses.callnum%type,
    p_errorMsg OUT varchar2) as
    v_errors varchar2(1000);
    v_full boolean;
    v_waitlisted boolean;

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
            --num7
            --if (v_errors is null) then
            
 
            --TODO: num8

                        --check if stunum on waitlist table
                        --num9
                            --if not on waitlist with that call num then
                                --insert into waitlist table
                                --print stu num is now on wait list
                            --else
                                --print you're already waitlisted for that 

            --end if;
           -- if (v_errors is not null) then
                --checkWaitlist 
           
            if (v_errors is null) then
            check_capacity(p_snum, p_callnum, v_errors, v_full);
                if(v_full = true) then
                    --num8
                    checkWaitlist(p_snum, p_callnum, v_errors, v_waitlisted);
                    if (v_waitlisted = false) then
                        addToWaitList(p_snum, p_callNum);
                    end if;
                else
                    insert into enrollments (snum, callnum) values (p_snum, p_callnum);
                    dbms_output.put_line('Successfully Enrolled ' || p_snum || ' in course number ' || p_callnum || '.');
                    commit;
                end if;
            else
                dbms_output.put_line(v_errors);
            end if;
        else --num1: if snum and/or callnum invalid, skip to here
            dbms_output.put_line(v_errors); --skip rest of program and print errors
        end if;
    end;
----------------------DROP ME PROCEDURES-----------------------------------------------------------
    procedure notEnrolled
        (p_snum students.snum%type,
        p_callnum schClasses.callnum%type,
        p_errors IN OUT varchar2) as 
        v_enrollmentCount number(1);
    begin
        select count(snum) into v_enrollmentCount
        from enrollments
        where snum = p_snum and callNum = p_callNum; --add to not count 'W', because means dropped, so they can retake

        if (v_enrollmentCount != 1) then
            p_errors := p_errors || 'Not currently enrolled in that course, ';
        end if;
    end;

    procedure alreadyGraded
        (p_snum students.snum%type,
        p_callnum schClasses.callnum%type,
        p_errors IN OUT varchar2) as 
        v_grade varchar(1);

    begin
        select grade into v_grade
        from enrollments
        where snum = p_snum and callnum = p_callnum;

        if (v_grade is not null) then
        p_errors := p_errors || 'Grade already inputted cannot drop, ';
        end if;
    end;

    procedure dropCourse
        (p_snum students.snum%type,
        p_callnum schClasses.callnum%type,
        p_errors IN OUT varchar2) as 
        v_waitListNum number(3);
        v_addError varchar2(1000);

            cursor cur_waitlist is
            select w.snum, w.callnum, waitlistTime
            from waitlist w
            where w.callnum = p_callnum
            order by waitlistTime asc;

    begin
        update enrollments
        set grade = 'W'
        where snum = p_snum and callnum = p_callnum;
        dbms_output.put_line('Student ' || p_snum || ' has been dropped from course ' || p_callnum || '.');
        commit;

        select count(snum) into v_waitlistNum
        from waitlist
        where callnum = p_callnum;

        if (v_waitlistNum > 0) then
            for student in cur_waitList loop
                v_addError := null;
                dbms_output.put_line('Trying to add ' || student.snum || ' in course ' || student.callnum || '...');
                addme(student.snum,student.callnum, v_addError);
                if (v_addError is null) then
                    delete 
                    from waitlist
                    where snum = student.snum and callnum = student.callnum;
                    dbms_output.put_line('They have been removed from the waitlist.');
                  exit; 
                end if;
            end loop;
        end if;
    end;
---------------------------DROP ME MAIN--------------------------------------------
    procedure DropMe
        (p_snum students.snum%type,
        p_CallNum schClasses.callnum%type) as
        v_errors varchar2(1000);
    
    begin
        --num1
        check_snum(p_snum, v_errors); --check valid student number
        check_callnum(p_CallNum, v_errors); --check valid call number
        if (v_errors is null) then
        --num2
            notEnrolled(p_snum, p_callNum, v_errors);
            if (v_errors is null) then --checks to make sure was actually enrolled in course
                --num3
                alreadyGraded(p_snum, p_callnum, v_errors);
                if (v_errors is null) then
                    dropCourse(p_snum, p_callnum, v_errors);
                else
                    dbms_output.put_line(v_errors);
                end if;
            else
                dbms_output.put_line(v_errors);
            end if;
        else
            dbms_output.put_line(v_errors);
        end if;
    end;
    
end enroll;
/
show errors;

begin
    Enroll.addme(107, 10110, null);
end;
/

spool off;
/*
start 'C:\Users\handj\Desktop\Spring 2019 Work\IS480\final\setup.sql'
update enrollments set grade = null where snum = 107 and callnum = 10110;
commit;
start 'C:\Users\handj\Desktop\Spring 2019 Work\IS480\final\enroll.sql'
*/