$ontext
This is a simple Ecenomic Dispatch problem.
There are 5 gnerators
'a','b','c' are quadratic cost coefficient
Pmin  Pmax are generator limit.
$offtext


set gen /g1*g5/;
scalar load /400/;

table gendata(gen,*)
*column names must be indented with columns. They may or may not have inverted comma.
    a    b     c      pmin  pmax
g1  3    20    100    28    206
g2  4.05 18.07 98.87  90    284
g3  4.05 15.55 104.26 68    189
g4  3.99 19.21 107.21 76    266
g5  3.88 26.18 95.31  19    53;

variable p(gen),OF;
equations eq1, eq2;

eq1.. OF =e= sum(gen,gendata(gen,'a')*p(gen)*p(gen)+gendata(gen,'b')*p(gen)+
                gendata(gen,'c'));

eq2.. sum(gen,p(gen)) =g= load;

p.lo(gen)=gendata(gen,'pmin');
p.up(gen)=gendata(gen,'pmax');

model EcenomicDispatch /all/;

solve EcenomicDispatch using qcp minimizing OF