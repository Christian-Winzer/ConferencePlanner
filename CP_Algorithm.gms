$ontext
Conference scheduling using GAMS

2019/02/14 cw, jab
$offtext


*########################################################################
*@                           SETTINGS
*########################################################################
$if not set inputdata $set inputdata "./CP_Input.xlsx"
$if not set maxSlots $set maxSlots 100

* choose solver
option mip=CBC
*########################################################################
*@                     DATA
*########################################################################

*------------------------------------------------------------------------
*@@                 DEFINITIONS SETS, PARAMETERS
*------------------------------------------------------------------------
set
    p         participants
    t         topics
    s_all     all time slots
    /s1*s%maxSlots%/
    s(s_all)  available time slots
;
alias(t, tt);

parameter
    votes(p,t)     one if participant p wishes to see topic t
    max_rooms       maximum number of rooms = max number of parallel time slots
    up_settings(*) upload of setting parameters
;

*------------------------------------------------------------------------
*@@                              LOAD DATA
*------------------------------------------------------------------------
$call "gdxxrw %inputdata% o=inputs.gdx Index=index!A1"
$gdxin inputs.gdx
$loaddc p t up_settings votes
$gdxin inputs.gdx

*------------------------------------------------------------------------
*@@                      ASSIGNEMENT
*------------------------------------------------------------------------
* set maximum number of slots
s(s_all) = no;
s(s_all)$(ord(s_all) <= up_settings("Slots")) = yes;

* maximum number of rooms
max_rooms = up_settings("Rooms");

* votes
* alread loaded from gdx



*########################################################################
*@                            MODEL
*########################################################################

*------------------------------------------------------------------------
*@@                     VARIABLE AND EQUATION DEFINITIONS
*------------------------------------------------------------------------
Free variable
    OBJ              objective value
;

Binary Variable
    HOSTS(s_all,t)    one if slot s hosts topic t
    SEEN(p,s_all,t)   one if participant p seen topic t in session s
;

equations
    def_obj                        definition: objective value
    res_rooms(s_all)               restriction: not to assign more topics than rooms available
    res_topics_offered(p,s_all, t)  restriction: p can only choose topics t offered in slot s
    res_topics_one(p,s_all)        restriction: p can only chooseone topic per slot s
    res_visit_once(p,t)            restriction: p visits topic t only once
;

*------------------------------------------------------------------------
*@@                     EQUATION ASSIGNMENT
*------------------------------------------------------------------------
def_obj..
    obj         =E=  sum((s,t,p), votes(p,t)*SEEN(p,s,t))
;

* cannot offer more topics than rooms availabe per slot
res_rooms(s)..
    max_rooms   =G= sum(t, HOSTS(s,t))
;

* can only choose topics available in slot s
res_topics_offered(p,s,t)..
    HOSTS(s,t)  =G= SEEN(p,s,t)
;

* can only choose one topic per time slot
res_topics_one(p,s)..
    1           =G= sum(t, SEEN(p,s,t))
;

* can only visit topic once per conference_schedule
res_visit_once(p,t)..
    1           =G= sum(s, SEEN(p,s,t))
;

*------------------------------------------------------------------------
*@@                     MODEL ASSIGNMENT
*------------------------------------------------------------------------
model conference_schedule
      /def_obj, res_rooms,
       res_topics_offered ,res_topics_one,
       res_visit_once/;

*########################################################################
*@                          SIMULATION
*########################################################################

*------------------------------------------------------------------------
*@@                     MODEL SOLVING
*------------------------------------------------------------------------
*X.L(s,t) = 1;
solve conference_schedule using MIP maximizing obj;

*########################################################################
*@                          REPORTING
*########################################################################
*------------------------------------------------------------------------
*@@                       ASSIGN REPORT PARAMETERS
*------------------------------------------------------------------------
parameter
    r_seen(p,s_all, t)  p watched topic t in slot s
    r_hosts(s_all, t)   s hosts topic t
    r_count_topics(t)  count how often topic t is hosted
;

r_seen(p,s,t) = SEEN.L(p,s,t);
r_hosts(s,t) = HOSTS.L(s,t);
r_count_topics(t) =  sum(s,r_hosts(s,t));

display r_seen, r_hosts, r_count_topics;

*------------------------------------------------------------------------
*@@                         EXPORTING
*------------------------------------------------------------------------
* save to gdx
execute_unload "schedule.gdx";

$onecho > temp.tmp
o=CP_Output.xlsx
par=r_hosts    rng=schedule!A1   cdim=1 rdim=1
par=r_seen     rng=visits!A1     cdim=1 rdim=2
$offecho

* export to excel
execute "gdxxrw i=schedule.gdx @temp.tmp";

* clean up a bit
execute "rm temp.tmp";
execute "rm inputs.gdx";



















