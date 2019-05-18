function bytest_adaptive_game_add_local_SoC
clear workspace
day=1;
n=24*day;
SoC=zeros(1,n);
SoC(1)=0.7;
v=zeros(1,n);
alpha=zeros(1,n);
v(1)=(SoC(1)-0.5)/0.05+56;
Energy=1*25*1000;
b0=0.5;
wa=1-b0;
batterystage=40;
cost=zeros(1,n);
amin=1;
dump1=50;
dump2=15;
daygoal=0.8;
phireal=1;
rate=[1 0.3 0.5 0.2 0.3];
%battreryin time
batteryin=inf;

%new load time
timecheckin=inf;
timecheckout=90;

p0=100;

%rule breaker:dead load 
dump11=90;
dump22=10;
deadload=-500;

adp_int=12;
limitt=3;
sitaguess=[0 0 0 0 0];
ktotal=ones(limitt,1);
E=zeros(limitt,adp_int);
Estar=zeros(limitt,adp_int);
Etotal=zeros(2,limitt,13*24*day);
Estartotal=zeros(2,limitt,13*24*day);
cosst=zeros(1,2);
cheat=0;
guess=zeros(1,limitt);
 for adp=0:1
     phi=[1 1 1 1 1]; 
     operation=zeros(1,limitt);
     operation(1:3)=ones(1,3);
    sitenumber=limitt;
    checkflag=0;
for t0=1:n
    if t0>batteryin&&checkflag==0
        checkflag=1;
        SoC(t0)=SoC(t0)+0.5;
    end
    t=mod(t0,24);
    if adp==0&&t>dump1&&t<dump2&&cheat==1
        phi=[0.5 0.5 0.5 0.5];
    end
    if t0>timecheckin
       operation(4)=1;
    end
    if t0>timecheckout
        operation(3:4)=[0 0];
    end
    [alpha0, alphareal,alphao, kself]=gamesolver_virtual_load_local_SoC(v(t0),t,wa,b0,batterystage,Energy,amin,daygoal,phi,sitenumber,rate,operation,guess,SoC(t0));
    alpha(t0)=alphareal;
    cost(t0)=evaluation(alphareal,t,batterystage,Energy,SoC(t0),b0,daygoal,1-phireal*(t0>=dump1&&t0<=dump2),phi(sitenumber)*(t>timecheckin),deadload*(t0>dump11&&t0<dump22),0);
    SoC(t0+1)=(SoC(t0)*Energy-deadload*(t0>dump11&&t0<dump22)-integral(@(x)load2(x),t,t+1)*alphareal+integral(@(y)solar(y),t,t+1)*(1-phireal*(t0>dump1&&t0<dump2)))/Energy;
    if SoC(t0+1)>=1
        SoC(t0+1)=1;
    end
    v(t0+1)=(SoC(t0+1)-0.5)/0.05+56;
    sita=zeros(1,14);
    
for innercount=1:limitt
        adptempinner=1;
        adptemp=1;         
    for tinterval=t:(1/adp_int):t+1
        E(innercount,adptemp)=load2nojump(tinterval)*rate(innercount)*kself(innercount)+load2nojump(tinterval)*(1-rate(innercount))*alphao(innercount)-solarnojump(tinterval)+p0*sitaguess(innercount);
        Etotal(adp+1,innercount,ktotal(innercount))=E(innercount,adptemp)*operation(innercount);
        Estar(innercount,adptemp)=load2(tinterval)*alpha0-solar(tinterval)*(1-phireal*(t0>dump1&&t0<dump2))+deadload*(t0>dump11&&t0<dump22);
        Estartotal(adp+1,innercount,ktotal(innercount))=Estar(innercount,adptemp)*operation(innercount);
        ktotal(innercount)=ktotal(innercount)+1;
        sita(1)=sitaguess(innercount);
        
        for ininer=tinterval:(1/(adp_int)^2):(tinterval+(1/adp_int))
            int_Estar=alpha0*integral(@(x)load2(x),tinterval,tinterval+(1/adp_int))-integral(@(y)solar(y),tinterval,tinterval+(1/adp_int))*(1-phireal*(t0>dump1&&t0<dump2))+deadload*(t0>dump11&&t0<dump22)*1/adp_int;
            int_Ep=(integral(@(x)load2nojump(x),tinterval,tinterval+(1/adp_int))*(kself(innercount)*rate(innercount)+alphao(innercount)*(1-rate(innercount)))-integral(@(y)solarnojump(y),tinterval,tinterval+(1/adp_int))+(1/adp_int)*sitaguess(innercount)*(p0));
            e0=int_Ep-int_Estar;
            sita(adptempinner+1)=sita(adptempinner)-0.5e-4*(e0*p0+1);
            adptempinner=adptempinner+1;
        end
        
        if adp==1
            sitaguess(innercount)=sita(adptempinner);
        else
            sitaguess(innercount)=0;
        end        
        adptemp=adptemp+1;
    end
%     figure
%     stem(1:adp_int+1,Estartotal(innercount,ktotal-12:ktotal));
%     phi(innercount)=sitaguess(innercount);
end
    guess=sitaguess;
end
%     figure
%     scatter(t0:(1/adp_int):t0+1,E(innercount,:),'MarkerFaceColor','r');
%     hold on
%     scatter(t0:(1/adp_int):t0+1,Estar(innercount,:),'MarkerFaceColor','b');
% %     scatter(t0:(1/156):t0+1,Etrace,'MarkerFaceColor','y');
%     hold off

      
     figure('Name','Game solution')
     
     z=plotyy(1:n,SoC(1:n),1:n,alpha);
     tail1(adp+1)=sum(SoC)/n;
     tail2(adp+1)=sum(alpha)/n;
%      stem(1:n,cost)
     legend('SoC','\sigma')
     xlabel('Time (Hr)')
     ylabel(z(1),'SoC') % left y-axis
     ylabel(z(2),'Traffic Shaping factor \sigma','Fontsize',20)   
     title(['adp=',num2str(adp)])
    ktotal=ones(limitt,1);
    cosst(adp+1)=sum(cost);
 end
    figure
    
    for hu=1:sitenumber
     subplot(sitenumber,1,hu)
     for i=1:13*24*day
         temp1(i)=Etotal(1,hu,i);
         temp2(i)=Estartotal(1,hu,i);
     end
     plot(0:1/13:24*day-1/13,temp1,'MarkerFaceColor','r');
     hold on
     plot(0:1/13:24*day-1/13,temp2,'MarkerFaceColor','b');
     legend('estimated power consumtion','real power consumption','location','southeast');
     xlabel('Time (Hour)');
     ylabel('Power (W)');
     grid on
%      scatter(t0:(1/156):t0+1,Etrace,'MarkerFaceColor','y');
     hold off
    end
%     title('Reference model with no adaptive updation');
    
    figure
    for hu=1:sitenumber
        for i=1:13*24*day
            temp1(i)=Etotal(2,hu,i);
            temp2(i)=Estartotal(2,hu,i);
        end
     subplot(sitenumber,1,hu)
     plot(0:1/13:24*day-1/13,temp1,'MarkerFaceColor','r');
     hold on
     plot(0:1/13:24*day-1/13,temp2,'MarkerFaceColor','b');
     legend('estimated power consumtion','real power consumption','location','southeast');
     xlabel('Time (Hour)');
     ylabel('Power (W)');
     grid on
%      scatter(t0:(1/156):t0+1,Etrace,'MarkerFaceColor','y');
     hold off
    end
%      title('Reference model with adaptive updation');
     cosst(2)/day
     cosst(1)/day
%      plot(1:312,Etotal,'MarkerFaceColor','r');
%      hold on
%      plot(1:312,Estartotal,'MarkerFaceColor','b');
% %      scatter(t0:(1/156):t0+1,Etrace,'MarkerFaceColor','y');
%      hold off
end

function Pload=load2(t)
pl1 =    0.000839 ;
pl2 =       1.205  ;
pl3 =      -12.02 ;
pl4 =       34.29  ;
ql1 =      -6.495  ;
ql2 =       43.45  ;
Pload =(500* (pl1*(t).^3 + pl2*(t).^2 + pl3*(t) + pl4) ./((t).^2 + ql1*(t) + ql2)+500)*(1+(0.2*rand-0.2*rand)*1);
end

function Psolar=solar(ti)
t=ti*5;
p1 =      -327.4 ;
p2 =   4.435e+04;
p3 =  -7.078e+05;
q1 =      -143.6 ;
q2 =        5928 ;
Psolar = ((p1*t.^2 + p2*t + p3) ./ (t.^2 + q1*t + q2)+80)*(1+(0.5*rand-0.5*rand)*1);
end

function Pload=load2nojump(t)
pl1 =    0.000839 ;
pl2 =       1.205  ;
pl3 =      -12.02 ;
pl4 =       34.29  ;
ql1 =      -6.495  ;
ql2 =       43.45  ;
Pload =(500* (pl1*(t).^3 + pl2*(t).^2 + pl3*(t) + pl4) ./((t).^2 + ql1*(t) + ql2)+500)*(1+(0.2*rand-0.2*rand)*0);
end

function Psolar=solarnojump(ti)
t=ti*5;
p1 =      -327.4 ;
p2 =   4.435e+04;
p3 =  -7.078e+05;
q1 =      -143.6 ;
q2 =        5928 ;
Psolar = ((p1*t.^2 + p2*t + p3) ./ (t.^2 + q1*t + q2)+80)*(1+(0.5*rand-0.5*rand)*0);
end