$ontext
This is a simple 2 bus system. BUs 2 has load 400mw.
Both bus has generator. One line connecting 2 buses.


$offtext
sets
   gen /g1*g2/
   bus /b1*b2/;

scalars
   load_b2 /400/
   x12     /0.2/
   sbase   /100/
   p12_max /150/;

table gendata(gen,*)
   a    b     c     Pmin Pmax
G1 3    20    100   28   206
G2 4.05 18.07 98.87 90   284;

variables OF, p(gen), delta(bus), p12;
equations eq1, eq2, eq3, eq4;

eq1.. OF =e= sum(gen,gendata(gen,'a')*p(gen)*p(gen) + gendata(gen,'b')*p(gen) + gendata(gen,'c'));

eq2.. p('g1') =l= p12;
eq3.. p('g1') + p('g2') =g= load_b2/sbase;
eq4.. p12 =e= (delta('b1')- delta('b2'))/x12;

p.lo(gen)=gendata(gen,'pmin')/sbase;
p.up(gen)=gendata(gen,'pmax')/sbase;

p12.lo= -p12_max/sbase;
p12.up= p12_max/sbase;

*p12.lo= -p12_max;
*p12.up=  p12_max;

delta.fx('b1')=0;

model OPF /all/;
solve OPF using qcp minimizing OF;

display OF.l, p.l

