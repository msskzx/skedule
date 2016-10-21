% Schedule = [ slot(WeekNumber,Day,SlotNumber,Event) ].
% Schedule = [slot(1, tuesday,1,event_in_course(csen403, quiz1, quiz)),slot(1,thursday,1,event_in_course(csen403,assignment1,assignment))].
% when using predicates seprately make sure the schedule is sorted


precede(G,Schedule):-
  precedeHalp(G,Schedule).

precedeHalp(_,[]).
precedeHalp(_,[_]).

% if same course,studying, same type then call should_precede (quiz,quiz)
% knowing that the schedule is sorted then it is enough to call the method on the second slot
% and the tail
precedeHalp(G,[slot(_,_,_,event_in_course(CC,Name1,Type)),slot(Wn2,D2,Sn2,event_in_course(CC,Name2,Type))|T]):-
  studying(CC,G),
  should_precede(CC,Name1,Name2),
  precedeHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC,Name2,Type))|T]).

% if no constraints
% same course but different type of event ( quiz - assignment)
precedeHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC,Name1,Type1)),slot(Wn2,D2,Sn2,event_in_course(CC,Name2,Type2))|T]):-
  studying(CC,G),
  \+should_precede(CC,Name1,Name2),
  \+should_precede(CC,Name2,Name1),
  precedeHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC,Name1,Type1))|T]),
  precedeHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC,Name2,Type2))|T]).

% different courses, studying both
precedeHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,Type1)),slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]):-
  CC1 \= CC2,
  studying(CC1,G),
  studying(CC2,G),
  precedeHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,Type1))|T]),
  precedeHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]).

% studying only first
precedeHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,Type1)),slot(_Wn2,_D2,_Sn2,event_in_course(CC2,_Name2,_Type2))|T]):-
  studying(CC1,G),
  \+studying(CC2,G),
  precedeHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,Type1))|T]).

% studying only second
precedeHalp(G,[slot(_,_,_,event_in_course(CC1,_,_)),slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]):-
  \+studying(CC1,G),
  studying(CC2,G),
  precedeHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]).

% not studying both
precedeHalp(G,[slot(_,_,_,event_in_course(CC1,_,_)),slot(_,_,_,event_in_course(CC2,_,_))|T]):-
  \+studying(CC1,G),
  \+studying(CC2,G),
  precedeHalp(G,T).



valid_slots_schedule(G,Schedule):-
  valid_slots_scheduleHalp(G,Schedule).

valid_slots_scheduleHalp(_,[]).
valid_slots_scheduleHalp(_,[_]).

% every event_in_course should have a unique (week,day,slot) form
% studying both, diff weeks
% call on the second only because the schedule is sorted
valid_slots_scheduleHalp(G,[slot(Wn1,_,_,event_in_course(CC1,_,_)),slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]):-
  studying(CC1,G),
  studying(CC2,G),
  Wn1 \= Wn2,
  valid_slots_scheduleHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]).

% studying both, diff days
valid_slots_scheduleHalp(G,[slot(_,D1,_,event_in_course(CC1,_,_)),slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]):-
  studying(CC1,G),
  studying(CC2,G),
  D1 \= D2,
  valid_slots_scheduleHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]).

% studying both , diff slots
valid_slots_scheduleHalp(G,[slot(_,_,Sn1,event_in_course(CC1,_,_)),slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]):-
  studying(CC1,G),
  studying(CC2,G),
  Sn1 \= Sn2,
  valid_slots_scheduleHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]).

% studying the first
valid_slots_scheduleHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,Type1)),slot(_,_,_,event_in_course(CC2,_,_))|T]):-
  studying(CC1,G),
  \+studying(CC2,G),
  valid_slots_scheduleHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,Type1))|T]).

% studying the second
valid_slots_scheduleHalp(G,[slot(_,_,_,event_in_course(CC1,_,_)),slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]):-
  \+studying(CC1,G),
  studying(CC2,G),
  valid_slots_scheduleHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]).

% studying nothing
valid_slots_scheduleHalp(G,[slot(_,_,_,event_in_course(CC1,_,_)),slot(_,_,_,event_in_course(CC2,_,_))|T]):-
  \+studying(CC1,G),
  \+studying(CC2,G),
  valid_slots_scheduleHalp(G,T).


% a list of quizslot for that group to get the timings
% quizslot(G,D,Sn) is used to get -> slot(Week,D,Sn,Event)
available_timings(G,L):-
  setof(quizslot(G,D,Sn),quizslot(G,D,Sn),L).



group_events(G,Events):-
  setof(event_in_course(CC,Name,Type),(studying(CC,G),event_in_course(CC,Name,Type)),Events).



no_consec_quizzes(G,Schedule):-
  no_consec_quizzesHalp(G,Schedule).

no_consec_quizzesHalp(_,[]).
no_consec_quizzesHalp(_,[_]).

% same course, studying, both quizez
no_consec_quizzesHalp(G,[slot(Wn1,_,_,event_in_course(CC,_,quiz)),slot(Wn2,D2,Sn2,event_in_course(CC,Name2,quiz))|T]):-
  studying(CC,G),
  W1 = Wn1+1,
  W1<Wn2,
  no_consec_quizzesHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC,Name2,quiz))|T]).

% same course, studying, only the first is a quiz
no_consec_quizzesHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC,Name1,quiz)),slot(_,_,_,event_in_course(CC,_,Type2))|T]):-
  studying(CC,G),
  Type2 \= quiz,
  no_consec_quizzesHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC,Name1,quiz))|T]).

% same course, studying, only the second is a quiz
no_consec_quizzesHalp(G,[slot(_,_,_,event_in_course(CC,_,Type1)),slot(Wn2,D2,Sn2,event_in_course(CC,Name2,quiz))|T]):-
  studying(CC,G),
  Type1 \= quiz,
  no_consec_quizzesHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC,Name2,quiz))|T]).

% same course, studying, none is a quiz
no_consec_quizzesHalp(G,[slot(_,_,_,event_in_course(CC,_,Type1)),slot(_,_,_,event_in_course(CC,_,Type2))|T]):-
  studying(CC,G),
  Type1 \= quiz,
  Type2 \= quiz,
  no_consec_quizzesHalp(G,[T]).

% diff courses, studying both (do not care about the type for now)
no_consec_quizzesHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,Type1)),slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]):-
  CC1 \= CC2,
  studying(CC1,G),
  studying(CC2,G),
  no_consec_quizzesHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,Type1))|T]),
  no_consec_quizzesHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]).

% studying only the first
no_consec_quizzesHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,Type1)),slot(_,_,_,event_in_course(CC2,_,_))|T]):-
  studying(CC1,G),
  \+studying(CC2,G),
  no_consec_quizzesHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,Type1))|T]).

% studying only the second
no_consec_quizzesHalp(G,[slot(_,_,_,event_in_course(CC1,_,_)),slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]):-
  \+studying(CC1,G),
  studying(CC2,G),
  no_consec_quizzesHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]).

% studying nothing
no_consec_quizzesHalp(G,[slot(_,_,_,event_in_course(CC1,_,_)),slot(_,_,_,event_in_course(CC2,_,_))|T]):-
  \+studying(CC1,G),
  \+studying(CC2,G),
  no_consec_quizzesHalp(G,[T]).



no_same_day_quiz(G,Schedule):-
  no_same_day_quizHalp(G,Schedule).

no_same_day_quizHalp(_,[]).
no_same_day_quizHalp(_,[_]).

% studying both, both quizez, same week
no_same_day_quizHalp(G,[slot(Wn,D1,_,event_in_course(CC1,_,quiz)),slot(Wn,D2,Sn2,event_in_course(CC2,Name2,quiz))|T]):-
  studying(CC1,G),
  studying(CC2,G),
  D1\=D2,
  no_same_day_quizHalp(G,[slot(Wn,D2,Sn2,event_in_course(CC2,Name2,quiz))|T]).

% studying both, both quizez, diff weeks
no_same_day_quizHalp(G,[slot(Wn1,_,_,event_in_course(CC1,_,quiz)),slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,quiz))|T]):-
  studying(CC1,G),
  studying(CC2,G),
  Wn1\=Wn2,
  no_same_day_quizHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,quiz))|T]).

% studying both, only the second is a quiz
no_same_day_quizHalp(G,[slot(_,_,_,event_in_course(CC1,_,Type1)),slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,quiz))|T]):-
  studying(CC1,G),
  studying(CC2,G),
  Type1\=quiz,
  no_same_day_quizHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,quiz))|T]).

% studying both, only the first is quiz
no_same_day_quizHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,quiz)),slot(_,_,_,event_in_course(CC2,_,Type2))|T]):-
  studying(CC1,G),
  studying(CC2,G),
  Type2\=quiz,
  no_same_day_quizHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,quiz))|T]).

% studying both, no quizzes
no_same_day_quizHalp(G,[slot(_,_,_,event_in_course(CC1,_,Type1)),slot(_,_,_,event_in_course(CC2,_,Type2))|T]):-
  studying(CC1,G),
  studying(CC2,G),
  Type1 \= quiz,
  Type2\=quiz,
  no_same_day_quizHalp(G,[T]).

% studying second
no_same_day_quizHalp(G,[slot(_,_,_,event_in_course(CC1,_,_)),slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]):-
  \+studying(CC1,G),
  studying(CC2,G),
  no_same_day_quizHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]).

% studying first
no_same_day_quizHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,Type1)),slot(_,_,_,event_in_course(CC2,_,_))|T]):-
  studying(CC1,G),
  \+studying(CC2,G),
  no_same_day_quizHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,Type1))|T]).

% studying nothing
no_same_day_quizHalp(G,[slot(_,_,_,event_in_course(CC1,_,_)),slot(_,_,_,event_in_course(CC2,_,_))|T]):-
  \+studying(CC1,G),
  \+studying(CC2,G),
  no_same_day_quizHalp(G,[T]).



no_same_day_assignment(G,Schedule):-
  no_same_day_assignmentHalp(G,Schedule).

no_same_day_assignmentHalp(_,[]).
no_same_day_assignmentHalp(_,[_]).

% same like no_same_day_quiz
no_same_day_assignmentHalp(G,[slot(Wn,D1,_,event_in_course(CC1,_,assignment)),slot(Wn,D2,Sn2,event_in_course(CC2,Name2,assignment))|T]):-
  studying(CC1,G),
  studying(CC2,G),
  D1\=D2,
  no_same_day_assignmentHalp(G,[slot(Wn,D2,Sn2,event_in_course(CC2,Name2,assignment))|T]).

no_same_day_assignmentHalp(G,[slot(Wn1,_,_,event_in_course(CC1,_,assignment)),slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,assignment))|T]):-
  studying(CC1,G),
  studying(CC2,G),
  Wn1\=Wn2,
  no_same_day_assignmentHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,assignment))|T]).

no_same_day_assignmentHalp(G,[slot(_,_,_,event_in_course(CC1,_,Type1)),slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,assignment))|T]):-
  studying(CC1,G),
  studying(CC2,G),
  Type1\= assignment,
  no_same_day_assignmentHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,assignment))|T]).

no_same_day_assignmentHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,assignment)),slot(_,_,_,event_in_course(CC2,_,Type2))|T]):-
  studying(CC1,G),
  studying(CC2,G),
  Type2\= assignment,
  no_same_day_assignmentHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,assignment))|T]).

no_same_day_assignmentHalp(G,[slot(_,_,_,event_in_course(CC1,_,Type1)),slot(_,_,_,event_in_course(CC2,_,Type2))|T]):-
  studying(CC1,G),
  studying(CC2,G),
  Type1\= assignment,
  Type2\= assignment,
  no_same_day_assignmentHalp(G,[T]).

no_same_day_assignmentHalp(G,[slot(_,_,_,event_in_course(CC1,_,_)),slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]):-
  \+studying(CC1,G),
  studying(CC2,G),
  no_same_day_assignmentHalp(G,[slot(Wn2,D2,Sn2,event_in_course(CC2,Name2,Type2))|T]).

no_same_day_assignmentHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,Type1)),slot(_,_,_,event_in_course(CC2,_,_))|T]):-
  studying(CC1,G),
  \+studying(CC2,G),
  no_same_day_assignmentHalp(G,[slot(Wn1,D1,Sn1,event_in_course(CC1,Name1,Type1))|T]).

no_same_day_assignmentHalp(G,[slot(_,_,_,event_in_course(CC1,_,_)),slot(_,_,_,event_in_course(CC2,_,_))|T]):-
  \+studying(CC1,G),
  \+studying(CC2,G),
  no_same_day_assignmentHalp(G,[T]).



no_holidays(_,[]).

% studying the course, the date is not a holiday
no_holidays(G,[slot(Wn,D,_,event_in_course(CC,_,_))|T]):-
  studying(CC,G),
  \+holiday(Wn,D),
  no_holidays(G,T).

% not studying the course -> skip
no_holidays(G,[slot(_,_,_,event_in_course(CC,_,_))|T]):-
  \+studying(CC,G),
  no_holidays(G,T).



schedule(Week_number,Schedule):-
  groups(Groups),
  genAllGroupsSchedule(Week_number,Groups,[],Schedule).


% generate a schedule for all the groups
% by generating a schedule for every group then appending them together
genAllGroupsSchedule(_,[],A,A).

genAllGroupsSchedule(Wn,[G|T],A,Schedule):-
  available_timings(G,Timings),
  group_events(G,Events),
  genGroupSchedule(G,1,Wn,Timings,Events,[],Sc),
  append(Sc,A,X),
  genAllGroupsSchedule(Wn,T,X,Schedule).


% generate a schedule for a group
% C is a counter for weeks
% Wn is the limit week number
% events list is empty
genGroupSchedule(_,C,Wn,_,[],A,A):-
  C=<Wn.

% timings list is empty... no more available timings for this week... increment the week counter
genGroupSchedule(G,C,Wn,[],[Ev|T],A,S):-
  C=<Wn,
  available_timings(G,L),
  W is C+1,
  genGroupSchedule(G,W,Wn,L,[Ev|T],A,S).

genGroupSchedule(G,C,Wn,Timings,Events,A,S):-
  C=<Wn,
  member(quizslot(G,D,Sn),Timings),
  member(Ev,Events),
  check(G,[slot(C,D,Sn,Ev)|A]),
  delete(Timings,quizslot(G,D,Sn),Tnew),
  delete(Events,Ev,Enew),
  genGroupSchedule(G,C,Wn,Tnew,Enew,[slot(C,D,Sn,Ev)|A],S).

% the group cannot have more events in this week... even if the timings list is not empty
genGroupSchedule(G,C,Wn,[_],[Ev|T],A,S):-
  C<Wn,
  available_timings(G,L),
  W is C+1,
  genGroupSchedule(G,W,Wn,L,[Ev|T],A,S).



% checking constraints
% sort then check
check([],_).

check(G,Schedule):-
  insert_sort(Schedule,L),
  precede(G,L),
  valid_slots_schedule(G,L),
  no_consec_quizzes(G,L),
  no_same_day_quiz(G,L),
  no_same_day_assignment(G,L),
  no_holidays(G,L).



% a list of groups
groups(L):-
  setof(G,(X^studying(X,G)),L).



% sorting a list of slots
insert_sort(List,Sorted):-
  i_sort(List,[],Sorted).

i_sort([],Acc,Acc).

i_sort([H|T],Acc,Sorted):-insert(H,Acc,NAcc),i_sort(T,NAcc,Sorted).

insert(slot(Wn1,D1,Sn1,E1),[slot(Wn2,D2,Sn2,E2)|T],[slot(Wn2,D2,Sn2,E2)|NT]):-
  Wn1>Wn2,insert(slot(Wn1,D1,Sn1,E1),T,NT).

insert(slot(Wn1,D1,Sn1,E1),[slot(Wn2,D2,Sn2,E2)|T],[slot(Wn2,D2,Sn2,E2)|NT]):-
  Wn1=Wn2,
  day2n(D1,X1),
  day2n(D2,X2),
  X1>X2,
  insert(slot(Wn1,D1,Sn1,E1),T,NT).

insert(slot(Wn1,D1,Sn1,E1),[slot(Wn2,D2,Sn2,E2)|T],[slot(Wn2,D2,Sn2,E2)|NT]):-
  Wn1=Wn2, D1=D2, Sn1>Sn2,
  insert(slot(Wn1,D1,Sn1,E1),T,NT).

insert(slot(Wn1,D1,Sn1,E1),[slot(Wn2,D2,Sn2,E2)|T],[slot(Wn1,D1,Sn1,E1),slot(Wn2,D2,Sn2,E2)|T]):-
  Wn1<Wn2.

insert(slot(Wn1,D1,Sn1,E1),[slot(Wn2,D2,Sn2,E2)|T],[slot(Wn1,D1,Sn1,E1),slot(Wn2,D2,Sn2,E2)|T]):-
  Wn1=Wn2,
  day2n(D1,X1),
  day2n(D2,X2),
  X1<X2.

insert(slot(Wn1,D1,Sn1,E1),[slot(Wn2,D2,Sn2,E2)|T],[slot(Wn1,D1,Sn1,E1),slot(Wn2,D2,Sn2,E2)|T]):-
  Wn1=Wn2,D1=D2,Sn1=<Sn2.

insert(X,[],[X]).



% converting days into numbers to compare
day2n(saturday,1).
day2n(sunday,2).
day2n(monday,3).
day2n(tuesday,4).
day2n(wednesday,5).
day2n(thursday,6).
day2n(friday,7).



event_in_course(csen403, labquiz1, assignment).
event_in_course(csen403, labquiz2, assignment).
event_in_course(csen403, project1, evaluation).
event_in_course(csen403, project2, evaluation).
event_in_course(csen403, quiz1, quiz).
event_in_course(csen403, quiz2, quiz).
event_in_course(csen403, quiz3, quiz).

event_in_course(csen401, quiz1, quiz).
event_in_course(csen401, quiz2, quiz).
event_in_course(csen401, quiz3, quiz).
event_in_course(csen401, milestone1, evaluation).
event_in_course(csen401, milestone2, evaluation).
event_in_course(csen401, milestone3, evaluation).

event_in_course(csen402, quiz1, quiz).
event_in_course(csen402, quiz2, quiz).
event_in_course(csen402, quiz3, quiz).

event_in_course(math401, quiz1, quiz).
event_in_course(math401, quiz2, quiz).
event_in_course(math401, quiz3, quiz).

event_in_course(elct401, quiz1, quiz).
event_in_course(elct401, quiz2, quiz).
event_in_course(elct401, quiz3, quiz).
event_in_course(elct401, assignment1, assignment).
event_in_course(elct401, assignment2, assignment).

event_in_course(csen601, quiz1, quiz).
event_in_course(csen601, quiz2, quiz).
event_in_course(csen601, quiz3, quiz).
event_in_course(csen601, project, evaluation).
event_in_course(csen603, quiz1, quiz).
event_in_course(csen603, quiz2, quiz).
event_in_course(csen603, quiz3, quiz).

event_in_course(csen602, quiz1, quiz).
event_in_course(csen602, quiz2, quiz).
event_in_course(csen602, quiz3, quiz).

event_in_course(csen604, quiz1, quiz).
event_in_course(csen604, quiz2, quiz).
event_in_course(csen604, quiz3, quiz).
event_in_course(csen604, project1, evaluation).
event_in_course(csen604, project2, evaluation).


holiday(3,monday).
holiday(5,tuesday).
holiday(10,sunday).


studying(csen403, group4MET).
studying(csen401, group4MET).
studying(csen402, group4MET).
studying(csen402, group4MET).

studying(csen601, group6MET).
studying(csen602, group6MET).
studying(csen603, group6MET).
studying(csen604, group6MET).

should_precede(csen403,project1,project2).
should_precede(csen403,quiz1,quiz2).
should_precede(csen403,quiz2,quiz3).

quizslot(group4MET, tuesday, 1).
quizslot(group4MET, thursday, 1).
quizslot(group6MET, saturday, 5).
