function bytest_RL_TRYING_time_8_29_tuning
day=1000;
n=24;
record=zeros(day,24);
SoC=zeros(1,n);
soc1=0.7;
SoC(1)=soc1;
v=zeros(1,n);
alpha=zeros(1,n);
v(1)=(SoC(1)-0.5)/0.05+56;
vpre=v(1);
Energy=1*25*1000;
b0=0.2;
batterystage=20;
cost=zeros(1,n);
dump1=inf;
dump2=15;
daygoal=0.8;
phireal=1;
%battreryin time
batteryin=inf;
%new load time
timecheckin=inf;
timecheckout=90;
%rule breaker:dead load 
dump11=90;
dump22=10;
deadload=-500;
limitt=3;

     phi=[1 1 1 1 1]; 
     operation=zeros(1,limitt);
     operation(1:3)=ones(1,3);
    sitenumber=limitt;
    checkflag=0;
    
% learning rate and gamma setting
aupdate=0.5;
gamma=0.7;

nstrategy=5;
batterysnumber=10;
time_zone=3;
Qvalue=0.2*ones(time_zone,batterysnumber,nstrategy);
alphaset=zeros(1,nstrategy);
for i=1:nstrategy
    alphaset(i)=1/nstrategy*i;
end
show=zeros(1,24);
cost_record=zeros(1,n*day);
kpp=1;
for t0=1:n*day
    daymark=floor(t0/24)+1;
    if t0>batteryin&&checkflag==0
        checkflag=1;
        SoC(t0)=SoC(t0)+0.5;
    end
    t=mod(t0,24)+(mod(t0,24)==0)*24;
    
    if t~=24
        tz=floor(t/8)+1;
    else
        tz=1;
    end
    
    if t>dump1&&t<dump2&&cheat==1
        phi=[0.5 0.5 0.5 0.5];
    end
    if t0>timecheckin
       operation(4)=1;
    end
    if t0>timecheckout
        operation(3:4)=[0 0];
    end
%state verifying
    v(t)=vpre;
    SoC(t)=(v(t)-56)*0.05+0.5;
state=floor(SoC(t)/(1/batterysnumber));

%%%Reinforcement learning trying%%%
    sumQall=0;
    sumQvalue=zeros(1,nstrategy);
    for inner=1:nstrategy
        if mod(t0,24)~=0
        sumQvalue(inner)=(Qvalue(tz,state,inner));
        sumQall= sumQall+sumQvalue(inner);
        else
        sumQvalue(inner)=(Qvalue(tz,state,inner));
        sumQall= sumQall+sumQvalue(inner);
        end
    end
    for inner=1:nstrategy
        sumQall;
        chance(inner)=sumQvalue(inner)/sumQall;
    end
    
    
        if mod(t0,24)~=0
        [vv, idx]=max(chance);
        show(t)=alphaset(idx);
        else
        [vv, idx]=max(chance);
        show(24)=alphaset(idx);
        end
    r=rand;
    l=0;
    for i=1:nstrategy       
      l=l+chance(i);
      if l>r
     %       idx = i;
            break
      end
    end
    [vv, idx]=max(chance);
    alphareal=alphaset(idx);
    record(daymark,t)=idx;
%%%end trying%%%

alpha(t)=alphareal;
    cost(t)=evaluation(alphareal,t,batterystage,Energy,SoC(t),b0,daygoal,1-phireal*(t0>=dump1&&t0<=dump2),phi(sitenumber)*(t>timecheckin),deadload*(t0>dump11&&t0<dump22),0);
    SoC(t+1)=(SoC(t)*Energy-deadload*(t0>dump11&&t0<dump22)-integral(@(x)load2(x),t,t+1)*alphareal+integral(@(y)solar(y),t,t+1)*(1-phireal*(t0>dump1&&t0<dump2)))/Energy;
    if SoC(t+1)>=1
        SoC(t+1)=1;
    elseif SoC(t+1)<=0.15
        SoC(t+1)=0.15;
    end
    
    if mod(t0,24)==0
        SoC(t+1)=rand;
        if SoC(t+1)<=0.1
            SoC(t+1)=0.2;
        end
        % record cost sum of one day
        cost_record(kpp)=sum(cost);
        kpp=kpp+1;
    end
    v(t+1)=(SoC(t+1)-0.5)/0.05+56;
    vpre=v(t+1);
%%%Reinforcement learning updating%%%
%new state
newstate=floor(SoC(t+1)/0.1);
%reward function
if t~=24
    r=5*(SoC(t+1)-SoC(t))+alphareal*5+(SoC(t+1)<0.5)*(-5);
elseif SoC(t+1)>=0.8
        r=20;
elseif SoC(t+1)<0.8 && SoC(t+1)>=0.5
        r=0;
elseif SoC(t+1)<0.5 && SoC(t+1)>=0.2
        r=-10;
elseif SoC(t+1)<0.2
        r=-100;
else
        r=SoC(t+1)-SoC(t);
end

%updating law
candidate=zeros(1,nstrategy);

    for inner=1:nstrategy        
        if tz==time_zone
        candidate(inner)=Qvalue(1,newstate,inner);
        else
        candidate(inner)=Qvalue(tz+1,newstate,inner);
        end
    end

% Q value iteration
Qvalue(tz,state,idx)=Qvalue(tz,state,idx)+aupdate/t0*(r+gamma*max(candidate)-Qvalue(tz,state,idx));

%%%Reinforcement learning end%%%

end


     figure('Name','Game solution')
     
      z=plotyy(1:n,SoC(1:n),1:n,alpha);
%     tail1=sum(SoC)/n;
%     tail2=sum(alpha)/n;
%       stem(1:n,cost)
     legend('SoC','\sigma')
     xlabel('Time (Hr)')
     ylabel(z(1),'SoC') % left y-axis
     ylabel(z(2),'Traffic Shaping factor \sigma','Fontsize',20)   
    ktotal=ones(limitt,1);
    cosst=sum(cost)
    i=1:day;
    figure
    plot(i,cost_record(i))
    chance;
    Qvalue;
    assignin('base', 'Q_table', Qvalue)

% for    d=1:1:day+1
%     y=1:1:24;
%     d2=d*ones(24);
%     plot3(d2,y,record(d,:),'color','blue')
%     hold on
% end
% figure
% [d,y]=meshgrid(1:1:24,1:1:day+1);
% surf(d,y,record)
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