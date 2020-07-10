$ontext
This is a simple multi period Ecenomic Dispatch problem.
There are 4 gnerators
'a','b','c' are quadratic cost coefficient
Pmin  Pmax are generator limit.
RU RD are ramp up and ramp down limit
$offtext

sets t /t1*t24/
     i /g1*g4/;

table gendata(i,*)
   a    b     c   Pmin Pmax RU  RD
g1 0.12 14.80 89  28   200  40  40
g2 0.17 16.57 83  20   290  30  30
g3 0.15 15.55 100 30   190  30  30
g4 0.19 16.21 70  20   260  50  50;

*24 hours demand data
parameter demand(t)
/ t1 510
t2 530
t3 516
t4 510
t5 515
t6 544
t7 646
t8 686
t9 741
t10 734
t11 748
t12 760
t13 754
t14 700
t15 686
t16 720
t17 714
t18 761
t19 727
t20 714
t21 618
t22 584
t23 578
t24 544 /;

variables OF, p(i,t);

equations eq1, eq2, eq3, eq4;

*Objective function
eq1.. OF =e= sum((i,t),gendata(i,'a')*power(p(i,t),2)+gendata(i,'b')*p(i,t)+gendata(i,'c'));
*system generation load balance constraint
eq2(t).. sum(i,p(i,t)) =g= demand(t);
*Ramp up constraint
eq3(i,t)..   p(i,t+1)-p(i,t) =l= gendata(i,'RU');
*Ramp down constraint
eq4(i,t)..   p(i,t-1)-p(i,t) =l= gendata(i,'RD');

p.up(i,t) = gendata(i,'pmax');
p.lo(i,t) = gendata(i,'pmin');

model MultiPeriodED /all/;
solve MultiPeriodED using qcp minimizing OF;

display p.l,OF.l
