
function Psolar=solar(ti,loadrate)
t=ti*5;
p1 =      -327.4 ;
p2 =   4.435e+04;
p3 =  -7.078e+05;
q1 =      -143.6 ;
q2 =        5928 ;
Psolar =max(loadrate*2*(p1*t^2 + p2*t + p3) / (t^2 + q1*t + q2)*(1+(0.2*rand-0.2*rand)*0),0);
end