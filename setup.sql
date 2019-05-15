--start 'C:\Users\handj\Desktop\Spring 2019 Work\IS480\final\setup.sql'
spool 'C:\Users\handj\Desktop\Spring 2019 Work\IS480\final\setup.txt'
set echo on
set serveroutput on
--Jonathan Hand
--IS 480
--Final Project

/* ---------------
   Create table structure for IS 480 project
   --------------- */

drop table enrollments;
drop table prereq;
drop table waitlist;
drop table schclasses;
drop table courses;
drop table students;
drop table majors;


-----
-----


create table MAJORS
	(major varchar2(3) Primary key,
	mdesc varchar2(30));
insert into majors values ('ACC','Accounting');
insert into majors values ('FIN','Finance');
insert into majors values ('IS','Information Systems');
insert into majors values ('MKT','Marketing');

create table STUDENTS 
	(snum varchar2(3) primary key,
	sname varchar2(10),
	standing number(1),
	major varchar2(3) constraint fk_students_major references majors(major),
	gpa number(2,1),
	major_gpa number(2,1));

insert into students values ('101','Andy',3,'IS',2.8,3.2);
insert into students values ('102','Betty',2,null,3.2,null);
insert into students values ('103','Cindy',3,'IS',2.5,3.5);
insert into students values ('104','David',2,'FIN',3.3,3.0);
insert into students values ('105','Ellen',1,null,2.8,null);
insert into students values ('106','Frank',3,'MKT',3.1,2.9);
insert into students values ('107','Cindy',3,'IS',2.5,3.5);
insert into students values ('108','Frank',3,'IS',2.5,3.5);
insert into students values ('109','Betty',3,'MKT',2.5,3.5);
insert into students values ('110','Cindy',3,'IS',2.5,3.5);
insert into students values ('111','Frank',3,null,2.5,3.5);
insert into students values ('112','Cindy',3,'FIN',2.5,3.5);
insert into students values ('113','Frank',3,'IS',2.5,3.5);
insert into students values ('114','David',3,null,2.5,3.5);
insert into students values ('115','David',3,'IS',2.5,3.5);

create table COURSES
	(dept varchar2(3) constraint fk_courses_dept references majors(major),
	cnum varchar2(3),
	ctitle varchar2(30),
	crhr number(3),
	standing number(1),
	primary key (dept,cnum));

insert into courses values ('IS','300','Intro to MIS',3,2);
insert into courses values ('IS','301','Business Communicatons',3,2);
insert into courses values ('IS','310','Statistics',3,2);
insert into courses values ('IS','340','Programming',3,3);
insert into courses values ('IS','380','Database',3,3);
insert into courses values ('IS','385','Systems',3,3);
insert into courses values ('IS','480','Adv Database',3,4);

create table SCHCLASSES (
	callnum number(5) primary key,
	year number(4),
	semester varchar2(3),
	dept varchar2(3),
	cnum varchar2(3),
	section number(2),
	capacity number(3));

alter table schclasses 
	add constraint fk_schclasses_dept_cnum foreign key 
	(dept, cnum) references courses (dept,cnum);

insert into schclasses values (10110,2014,'Fa','IS','300',1,5);
insert into schclasses values (10115,2014,'Fa','IS','300',2,118);
insert into schclasses values (10120,2014,'Fa','IS','300',3,5);
insert into schclasses values (10125,2014,'Fa','IS','301',1,35);
insert into schclasses values (10130,2014,'Fa','IS','301',2,35);
insert into schclasses values (10135,2014,'Fa','IS','310',1,35);
insert into schclasses values (10140,2014,'Fa','IS','310',2,35);
insert into schclasses values (10145,2014,'Fa','IS','340',1,30);
insert into schclasses values (10150,2014,'Fa','IS','380',1,33);
insert into schclasses values (10155,2014,'Fa','IS','385',1,35);
insert into schclasses values (10160,2014,'Fa','IS','480',1,35);

create table PREREQ
	(dept varchar2(3),
	cnum varchar2(3),
	pdept varchar2(3),
	pcnum varchar2(3),
	primary key (dept, cnum, pdept, pcnum));
alter table Prereq 
	add constraint fk_prereq_dept_cnum foreign key 
	(dept, cnum) references courses (dept,cnum);
alter table Prereq 
	add constraint fk_prereq_pdept_pcnum foreign key 
	(pdept, pcnum) references courses (dept,cnum);

insert into prereq values ('IS','380','IS','300');
insert into prereq values ('IS','380','IS','301');
insert into prereq values ('IS','380','IS','310');
insert into prereq values ('IS','385','IS','310');
insert into prereq values ('IS','340','IS','300');
insert into prereq values ('IS','480','IS','380');

create table ENROLLMENTS (
	snum varchar2(3) constraint fk_enrollments_snum references students(snum),
	callnum number(5) constraint fk_enrollments_callnum references schclasses(callnum),
	grade varchar2(2),
	primary key (snum, callnum));

insert into enrollments values (101,10110,'A');
insert into enrollments values (102,10125,null);
insert into enrollments values (103,10120,'A');
insert into enrollments values (101,10125,null);
insert into enrollments values (102,10130,null);
insert into enrollments values (104,10110,null);
insert into enrollments values (105,10110,null);
insert into enrollments values (106,10110,'B');
insert into enrollments values (107,10110,null);
insert into enrollments values (108,10110,'W');
insert into enrollments values (103,10125,null);
insert into enrollments values (104,10125,null);
insert into enrollments values (105,10130,null);
insert into enrollments values (104,10120,null);
insert into enrollments values (106,10120,null);
insert into enrollments values (107,10120,'B');
insert into enrollments values (108,10120,'C');

create table WAITLIST (
	snum varchar2(3) constraint fk_waitlist_snum references students(snum),
	callnum number(5) constraint fk_waitlist_callnum references schclasses(callnum),
	waitlistTime timestamp,
	primary key (snum, callnum));
insert into WAITLIST values (109, 10110, '14-MAY-19 06.08.52.332000 PM');
insert into WAITLIST values (102, 10110, '14-MAY-19 07.15.27.830000 PM');
insert into WAITLIST values (110, 10110, '14-MAY-19 06.24.17.298000 PM');

commit;

------------------------ENROLL PACKAGE------------------------------------------------------
create or replace Package Enroll as
--addme and dropme in spec

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
	--checks to make sure snum is valid
        (p_snum students.snum%type,
        p_answer OUT varchar2) as 
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
	--checks to make sure callnum is valid
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
	--checks to make sure student will not exceed 15 crhr
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
	--makes sure not enrolled in another section already
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
	--makes sure not enrolled in same callnum already
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

    procedure standingRequirement
	--checks standing, makes sure high enough standing to take course
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
	--checks to see if major is undeclared. If standing 3+ then cannot enroll as undeclared
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
	--checks to see if class is full
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
        if (v_reserved >= v_capacity) then
            p_answer := p_answer || 'Class is full, ';
            p_full := true;
        end if;
    end;
    
    procedure checkWaitlist
	--checks to see if snum is already waitlisted for that callnum
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
	--adds student to waitlist
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
            --num3
            doubleEnrollment(p_snum, p_callNum, v_errors);
            --num4
            check_15hr(p_snum, p_callNum, v_errors);
            --num5
            standingRequirement(p_snum, p_callNum, v_errors);
            --num6
            undeclaredMajor(p_snum, p_callNum, v_errors);
            if (v_errors is null) then
			--num7
            check_capacity(p_snum, p_callnum, v_errors, v_full); --if no errors can enroll, so check if class full
                if(v_full = true) then --if class is full
                    --num8
                    checkWaitlist(p_snum, p_callnum, v_errors, v_waitlisted); --check if already waitlisted
                    if (v_waitlisted = false) then --if not already waitlisted for class then
                        addToWaitList(p_snum, p_callNum);
                    end if;
                else --if not full, then can enroll student
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

spool off;