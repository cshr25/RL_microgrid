function Pload=load2(t,loadrate)
pl1 =    0.000839 ;
pl2 =       1.205  ;
pl3 =      -12.02 ;
pl4 =       34.29  ;
ql1 =      -6.495  ;
ql2 =       43.45  ;
Pload =max(loadrate*(500* (pl1*(t)^3 + pl2*(t)^2 + pl3*(t) + pl4) /((t)^2 + ql1*(t) + ql2)+500)*(1+(0.5*rand-0.5*rand)*0),0);
end