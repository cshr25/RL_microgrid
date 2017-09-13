function bytest_RL_TRYING_notime
global random_switch
random_switch=0;
day=60;
n=24;
record=zeros(day,24);
SoC=zeros(1,n);
soc1=0.70;
SoC(1)=soc1;
v=zeros(1,n);
alpha=zeros(1,n);
v(1)=(SoC(1)-0.5)/0.05+56;
vpre=v(1);
Energy=1*25*1000;
b0=0.2;
batterystage=40;
cost=zeros(1,n);
dump1=inf;
dump2=15;
daygoal=0.8;
phireal=1;
cost_record=zeros(1,day);
kpp=1;
%battreryin time
batteryin=inf;
%new load time
timecheckin=inf;
timecheckout=90;
%rule breaker:dead load 
dump11=90;
dump22=10;
deadload=-500;
limitt=1;

     phi=[1 1 1 1 1]; 
     operation=zeros(1,limitt);
     operation(1:3)=ones(1,3);
    sitenumber=limitt;
    checkflag=0;
    

aupdate=0.5;
gamma=0.5;
nstrategy=20;
batterysnumber=20;
Qvalue=ones(batterysnumber+1,nstrategy);
for i=1:batterysnumber
    for j=1:nstrategy
        Qvalue(i,j)=rand;
    end
end
alphaset=zeros(1,nstrategy);
for i=1:nstrategy
    alphaset(i)=1/nstrategy*i;
end
show=zeros(1,24);
for t0=1:n*day
    daymark=floor(t0/24)+1;
    if t0>batteryin&&checkflag==0
        checkflag=1;
        SoC(t0)=SoC(t0)+0.5;
    end

    t=mod(t0,24)+(mod(t0,24)==0)*24;
    
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
state=floor(SoC(t)/(1/batterysnumber))+1;

%%%Reinforcement learning trying%%%
    sumQall=0;
    sumQvalue=zeros(1,nstrategy);
    for inner=1:nstrategy
        if mod(t0,24)~=0
        sumQvalue(inner)=(Qvalue(state,inner));
        sumQall= sumQall+sumQvalue(inner);
        else
        sumQvalue(inner)=(Qvalue(state,inner));
        sumQall= sumQall+sumQvalue(inner);
        end
    end
%     for inner=1:nstrategy
%         chance(inner)=sumQvalue(inner)/sumQall;
%     end
    tt=0.2;
    sumQvalue=exp(Qvalue(state,:)/tt);
    for inner=1:nstrategy
        chance(inner)=exp(Qvalue(state,inner)/tt)/sum(sumQvalue);
    end
    
    
        if mod(t0,24)~=0
        [~, idx]=max(chance);
        show(t)=alphaset(idx);
        else
        [~, idx]=max(chance);
        show(24)=alphaset(idx);
        end
    r=rand;
    l=0;
    for i=1:nstrategy       
      l=l+chance(i);
      if l>r
            break
      end
    end
    [~, idx]=max(chance);
%     idx=i;
    alphareal=alphaset(idx);
    record(daymark,t)=idx;
%%%end trying%%%

alpha(t)=alphareal;
    cost(t)=evaluation(alphareal,t,batterystage,Energy,SoC(t),b0,daygoal,1-phireal*(t0>=dump1&&t0<=dump2),phi(sitenumber)*(t>timecheckin),deadload*(t0>dump11&&t0<dump22),0);
    SoC(t+1)=(SoC(t)*Energy-deadload*(t0>dump11&&t0<dump22)-integral(@(x)load2(x),t,t+1)*alphareal+integral(@(y)solar(y),t,t+1)*(1-phireal*(t0>dump1&&t0<dump2)))/Energy;
    if SoC(t+1)>=1
        SoC(t+1)=1;
    elseif SoC(t+1)<=0
        SoC(t+1)=0;
    end
    
    if mod(t0,24)==0
        SoC(t+1)=rand;
    end
    v(t+1)=(SoC(t+1)-0.5)/0.05+56;
    vpre=v(t+1);
%%%Reinforcement learning updating%%%
%new state
newstate=floor(SoC(t+1)/0.1)+1;
%reward function

% 
% if t~=24
%     r=0.5*(SoC(t+1)-SoC(t)+(SoC(t+1)))+alphareal*0.5+(SoC(t+1)<0.5)*(-5);
% elseif SoC(t+1)>0.8
%         r=24;
% elseif SoC(t+1)<0.8
%         r=-24;
% elseif SoC(t+1)<0.5
%         r=-50;
% elseif SoC(t+1)<0.2
%         r=-100;
% else
%         r=SoC(t+1)-SoC(t);
% end

%rewardfunction
if t~=24
    r=50*((SoC(t+1)-SoC(t)))+0*alphareal;
elseif SoC(t)>=0.8
        r=10;
else
        r=200*(SoC(t+1)-SoC(t));
end


cost_record(kpp)=cost_record(kpp)+r;
%cost_record(kpp)=sum(cost);
if t==24  
    kpp=kpp+1;
end

%updating law
candidate=zeros(1,nstrategy);
    for inner=1:nstrategy 
        candidate(inner)=Qvalue(newstate,inner);
    end

Qvalue(state,i)=Qvalue(state,i)+10/t0*(r+gamma*max(candidate)-Qvalue(state,i));
%%%Reinforcement learning end%%%
end


     figure('Name','Game solution')
     
      z=plotyy(1:n,SoC(1:n),1:n,alpha);
     tail1=sum(SoC)/n;
     tail2=sum(alpha)/n;
%       stem(1:n,cost)
     legend('SoC','\sigma')
     xlabel('Time (Hr)')
     ylabel(z(1),'SoC') % left y-axis
     ylabel(z(2),'Traffic Shaping factor \sigma','Fontsize',20)   
    i=1:24;
    figure
    sum(cost)
    plot(i,show(i))
    i=1:day;
    figure
    plot(i,cost_record(i))
    assignin('base', 'Q_table', Qvalue)
% for    d=1:1:day+1
%     y=1:1:24;
%     d2=d*ones(24);
%     plot3(d2,y,record(d,:),'color','blue')
%     hold on
% end
figure
[d,y]=meshgrid(1:1:24,1:1:day+1);
surf(d,y,record)
end

function Pload=load2(t)
global random_switch
pl1 =    0.000839 ;
pl2 =       1.205  ;
pl3 =      -12.02 ;
pl4 =       34.29  ;
ql1 =      -6.495  ;
ql2 =       43.45  ;
Pload =(500* (pl1*(t).^3 + pl2*(t).^2 + pl3*(t) + pl4) ./((t).^2 + ql1*(t) + ql2)+500)*(1+(0.2*rand-0.2*rand)*random_switch);
end

function Psolar=solar(ti)
global random_switch
t=ti*5;
p1 =      -327.4 ;
p2 =   4.435e+04;
p3 =  -7.078e+05;
q1 =      -143.6 ;
q2 =        5928 ;
Psolar = ((p1*t.^2 + p2*t + p3) ./ (t.^2 + q1*t + q2)+80)*(1+(0.5*rand-0.5*rand)*random_switch);
end

function Pload=load2nojump(t)
global random_switch
pl1 =    0.000839 ;
pl2 =       1.205  ;
pl3 =      -12.02 ;
pl4 =       34.29  ;
ql1 =      -6.495  ;
ql2 =       43.45  ;
Pload =(500* (pl1*(t).^3 + pl2*(t).^2 + pl3*(t) + pl4) ./((t).^2 + ql1*(t) + ql2)+500)*(1+(0.2*rand-0.2*rand)*random_switch);
end

function Psolar=solarnojump(ti)
global random_switch
t=ti*5;
p1 =      -327.4 ;
p2 =   4.435e+04;
p3 =  -7.078e+05;
q1 =      -143.6 ;
q2 =        5928 ;
Psolar = ((p1*t.^2 + p2*t + p3) ./ (t.^2 + q1*t + q2)+80)*(1+(0.5*rand-0.5*rand)*random_switch);
end