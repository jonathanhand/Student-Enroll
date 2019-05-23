# Student-Enroll
PL/SQL Package that has an Enroll and Drop Function. Contains several checks to make sure student can add and drop.
The package contains the "addMe" and "dropMe" procedures, which can both be called from the Enroll package
Before adding, the procedure checks that:
stuNum is valid,
callnum is calid,
the student is not enrolled in the same callnum already,
the student is not enrolled in a different section of the same course,
the student will not be enrolled in more the 15 units after enrollment,
the student's standing is high enough to take that level course,
if student standing is 2 or 3, they must have declared a major to enroll,
the course capacity must not be full,
if all checks are valid, but course is full, the student will be added to waitlist,
the package also checks to make sure the student is not already on the waitlist for that course.

Before dropping, the procedure checks that:
stuNum and callNum are valid,
the student is enrolled in callnum,
the student has not received a grade in the course yet,
if all of this is met, then student is dropped from course.
The package then attempts to add a student from the waitlist to the course.
Once a student is added to the course from the waitlist, they are removed from the waitlist.
