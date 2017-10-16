function RL_OPT_compare_10_13()
tic
global random_switch
random_switch=0;
day=300;
n=24;
SoC=zeros(1,n);
soc1=0.50;
SoC(1)=soc1;

SoC_record=zeros(1,24*day);

v=zeros(1,n);
alpha=zeros(1,n);
v(1)=(SoC(1)-0.5)/0.05+56;
vpre=v(1);
Energy=1*25*1000;
cost=zeros(1,n);
dump1=inf;
dump2=20;
daygoal=0.8;
phireal=0.3;
cost_record=zeros(1,day);
kpp=1;
agent_1_r=zeros(1,day);

%battreryin time
batteryin=inf;

%new load time
timecheckin=inf;
timecheckout=90;

%rule breaker:dead load 
dump11=90;
dump22=10;
deadload=-500;

%number of BS controllers
limitt=5;

%BS load rate
load_rate=ones(1,limitt)/limitt;

%new connected device index
phi=[1 1 1 1 1]; 

%operation status index
operation=zeros(1,limitt);
operation(1:3)=ones(1,3);

%new battery plug in flag
checkflag=0;
    
% Q learning step size
aupdate=0.5;

% Horizon factor
gamma=0.7;

%available strategy number
nstrategy=20;

%battery level
batterysnumber=20;


%initialize Q value table
Qvalue=ones(limitt,batterysnumber+1,nstrategy);

% for i=1:batterysnumber
%     for j=1:nstrategy
%         Qvalue(:,i,j)=normrnd(1,1);
%     end
% end
Eva_game=zeros(1,day);
Eva_agent=zeros(1,day);
%initilize strategy index
alphaset=zeros(1,nstrategy);

wa=0.5;
b0=1;

for i=1:nstrategy
    alphaset(i)=1/nstrategy*i;
end
learning_count=0;
ini=0;

alpha_all=zeros(1,limitt);

for t0=1:n*day
    daymark=floor(t0/24)+1;
    
%     if t0>batteryin&&checkflag==0
%         checkflag=1;
%         SoC(t0)=SoC(t0)+0.5;
%     end

    %get time of one day
    t=mod(t0,24)+(mod(t0,24)==0)*24;
    
    %power outage flag
%     if t>dump1&&t<dump2&&cheat==1
%         phi=[0.5 0.5 0.5 0.5];
%     end
    
    % new load kick in
    if t0>timecheckin
       operation(4)=1;
    end
    % load 3 and 4 disconnected
    if t0>timecheckout
        operation(3:4)=[0 0];
    end
    
%SoC state verifying
if daymark<60&&t==1
    SoC(t)=rand*0.8+0.2;       
elseif daymark==60
    SoC(t)=0.5;
else    
    v(t)=vpre;
    SoC(t)=(v(t)-56)*0.05+0.5;
end

SoC_record(t0)=SoC(t);
    state=floor(SoC(t)/(1/batterysnumber))+1;  
%%% making decisions %%%
% for each BS controller
     alphareal=zeros(1,limitt);
     idx=zeros(1,limitt);
    for agent=1:limitt
        sumQall=0;
        sumQvalue=zeros(1,nstrategy);
        
    % calculate sum of Q value rows
        for inner=1:nstrategy
            sumQvalue(inner)=(Qvalue(agent,state,inner));
            sumQall= sumQall+sumQvalue(inner);
        end
    
%     for inner=1:nstrategy
%         chance(inner)=sumQvalue(inner)/sumQall;
%     end
    tt=0.5;
    sumQvalue=exp(Qvalue(agent,state,:)/tt);
    % softmax function
    chance=zeros(1,nstrategy);
    for inner=1:nstrategy
        chance(inner)=exp(Qvalue(agent,state,inner)/tt)/sum(sumQvalue);
    end
    
    % choose the action with maximum Q value
    [~, idx(agent)]=max(chance);
     
    if daymark<=inf
    rr=rand;
    l=0;
    for i=1:nstrategy       
      l=l+chance(i);
      if l>rr
            break
      end
    end
    
    idx(agent)=i;
    end
    
    alphareal(agent)=alphaset(idx(agent));
    
%     record(daymark,t)=idx;
%%%end trying%%%
    end

%     cost(t)=evaluation(alphareal,t,batterystage,Energy,SoC(t),b0,daygoal,1-phireal*(t0>=dump1&&t0<=dump2),phi(sitenumber)*(t>timecheckin),deadload*(t0>dump11&&t0<dump22),0);
    alphareal_total=alphareal*load_rate(1:limitt)';
    alpha(t)=alphareal_total;
    alpha_all=alpha_all+alphareal;
    SoC(t+1)=(SoC(t)*Energy-deadload*(t0>dump11&&t0<dump22)-integral(@(x)load2(x),t,t+1)*alphareal_total+integral(@(y)solar(y),t,t+1)*(1-phireal*(t0>dump1&&t0<dump2)))/Energy;
    if SoC(t+1)>=1
        SoC(t+1)=1;
    elseif SoC(t+1)<=0
        SoC(t+1)=0;
    end
    
%     if mod(t0,24)==0
%         SoC(t+1)=soc1;
%     end
    v(t+1)=(SoC(t+1)-0.5)/0.05+56;
    vpre=v(t+1);
%%%Reinforcement learning updating%%%
%new state
    newstate=floor(SoC(t+1)/0.1)+1;
    %difference between previous two days' rewards
    r_diff=0;
    if kpp~=1
        r_diff=agent_1_r(kpp)-agent_1_r(kpp-1);
    end
    
    if abs(r_diff)>=5&&ini==1
        learning_count=10*24;
        ini=1;
    end
    if learning_count>0
        learning_count=learning_count-1;
        time_gap=t0-24-learning_count;
        t0_in=t0-time_gap;
    else
        t0_in=t0;
    end
    for agent=1:limitt
        [r,Qvalue(agent,state,idx(agent))]=bytest_RL_notime_sub_function(newstate,SoC(t),SoC(1),alphareal(agent),Qvalue(agent,state,idx(agent)),Qvalue(agent,:,:),batterysnumber,nstrategy,t,t0_in,gamma,aupdate,b0);
    end
%         agent_1_r(kpp)=agent_1_r(kpp)+r;
        % evaluate performance using total reward
        agent_1_r(kpp)=agent_1_r(kpp)+r;
        
        % evaluate performance using total objective function
        Eva_agent(kpp)=Eva_agent(kpp)+evaluation(alphareal_total,t,batterysnumber,Energy,SoC(t),b0,daygoal,1,0,deadload,0);
        if daymark>100
%             alphareal_total
            evaluation(alphareal_total,t,batterysnumber,Energy,SoC(t),b0,daygoal,1,0,deadload,0)
        end
%         Eva_agent(kpp)
        if t==24  
            kpp=kpp+1;
            ini=0;
            alpha_all=0;
        end

end
figure
plot(SoC_record);

%initilize game simulation
kpp=1;
dayreward=0;
wa=0.2;
b0=0.8;
amin=2;
phi1=0;
add=0;
SoC(1)=soc1;
v(1)=(SoC(t+1)-0.5)/0.05+56;
game_record=zeros(1,day);
for treal=1:t0
    t=mod(treal,24);
    if t==0
        t=24;
    end
    alpha(t)=multiple_run_test_add(v(t),t,wa,b0,batterysnumber,Energy,amin,daygoal,phi1,add);
    %[~,~,~,alpha0]=gamesolver(v(t),t,b0,batterystage);
    %alpha(t)=alpha0;
    if t~=23
        if SoC(t)>0.4
            r=0.5*(SoC(t))+2*alpha(t);
        else
            r=-10*alpha(t);
        end
    else
        r=10*SoC(t);
    end
    dayreward = dayreward + r;
    
    Eva_game(kpp)=Eva_game(kpp)+evaluation(alpha(t),t,batterysnumber,Energy,SoC(t),b0,daygoal,1,0,deadload,0);
    if t==23
        game_record(kpp) = game_record(kpp)+dayreward;
        dayreward=0;
        kpp=kpp+1;
    end
    if kpp==300
        break
    end
    SoC(t+1)=(SoC(t)*Energy-integral(@(x)load2(x),t,t+1)*alpha(t)+integral(@(y)solar(y),t,t+1))/Energy;
    
    v(t+1)=(SoC(t+1)-0.5)/0.05+56;
end


%      figure('Name','Game solution')
%      
%      z=plotyy(1:n,SoC(1:n),1:n,alpha);
%      tail1=sum(SoC)/n;
%      tail2=sum(alpha)/n;
% %       stem(1:n,cost)
%      legend('SoC','\sigma')
%      xlabel('Time (Hr)')
%      ylabel(z(1),'SoC') % left y-axis
%      ylabel(z(2),'Traffic Shaping factor \sigma','Fontsize',20)   
% %     i=1:24;
% %     figure
% %     sum(cost)
% %     plot(i,show(i))
     i=1:day;
     figure
     plot(i,agent_1_r)
     hold on
     plot(i,game_record)
     hold off
     
      
     figure
     plot(i,Eva_agent(i))
     hold on
     plot(i,Eva_game(i))
% %     assignin('base', 'Q_table', Qvalue)
% % for    d=1:1:day+1
% %     y=1:1:24;
% %     d2=d*ones(24);
% %     plot3(d2,y,record(d,:),'color','blue')
% %     hold on
% % end
% % figure
% % [d,y]=meshgrid(1:1:24,1:1:day+1);
% % surf(d,y,record)
% assignin('base', 'Q_table', Qvalue)
toc
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