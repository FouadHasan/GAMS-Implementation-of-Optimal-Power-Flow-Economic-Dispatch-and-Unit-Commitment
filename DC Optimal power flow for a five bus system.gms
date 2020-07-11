$ontext
This is DC optimal power flow implementation of 5 bus test system.
This is taken from Soroudi, Alireza. Power System Optimization Modeling in GAMS. Springer, 2017.
Chapter 6 (Gcode6.3)
$offtext

Set
   bus        / b1*b5   /
   slack(bus) / b1     /
   Gen        / g1*g5 /;

Scalar Sbase / 100 /;

Alias (bus,node);

Table GenData(Gen,*) 'generating units characteristics'
       b   pmin  pmax
   g1  14  0     40
   g2  15  0     170
   g3  30  0     520
   g4  40  0     200
   g5  10  0     600 ;
* -----------------------------------------------------

Set GenBusconnect(bus,Gen) 'connectivity index of each generating unit to each bus'
/
   b1.g1
   b1.g2
   b3.g3
   b4.g4
   b5.g5
/;
****************************************************

Table BusData(bus,*) 'demands of each bus in MW'
      Pd
   b2  300
   b3  300
   b4  400;
****************************************************

Set BusCon 'bus connectivity matrix'
/
   b1.b2
   b2.b3
   b3.b4
   b4.b1
   b4.b5
   b5.b1
/;
* -----------------------------------------------------
BusCon(bus,node)$(BusCon(node,bus)) = 1;

Table BranchData(bus,node,*) 'network technical characteristics'
          x       Limit
   b1.b2  0.0281  400
   b1.b4  0.0304  400
   b1.b5  0.0064  400
   b2.b3  0.0108  400
   b3.b4  0.0297  400
   b4.b5  0.0297  240;

BranchData(bus,node,'x')$(BranchData(bus,node,'x')=0)         =   BranchData(node,bus,'x');
BranchData(bus,node,'Limit')$(BranchData(bus,node,'Limit')=0) =   BranchData(node,bus,'Limit');
*Forming the impedance column
BranchData(bus,node,'bij')$BusCon(bus,node)                = 1/BranchData(bus,node,'x');
*****************************************************

Variable OF, Pij(bus,node), Pg(Gen), delta(bus);
Equation eq1, eq2, eq3;
*********************************************

eq1(bus,node)$(BusCon(bus,node))..
   Pij(bus,node) =e= BranchData(bus,node,'bij')*(delta(bus) - delta(node));

eq2(bus)..
   sum(Gen$GenBusconnect(bus,Gen), Pg(Gen)) - BusData(bus,'pd')/Sbase =e= sum(node$BusCon(node,bus), Pij(bus,node));

eq3..
   OF =g= sum(Gen, Pg(Gen)*GenData(Gen,'b')*Sbase);

Model OPF / all /;

Pg.lo(Gen) = GenData(Gen,'Pmin')/Sbase;
Pg.up(Gen) = GenData(Gen,'Pmax')/Sbase;
delta.up(bus)   = pi;
delta.lo(bus)   =-pi;
delta.fx(slack) = 0;
Pij.up(bus,node)$((BusCon(bus,node)))= 1*BranchData(bus,node,'Limit')/Sbase;
Pij.lo(bus,node)$((BusCon(bus,node)))=-1*BranchData(bus,node,'Limit')/Sbase;

solve OPF minimizing OF using lp;

display OF.l
