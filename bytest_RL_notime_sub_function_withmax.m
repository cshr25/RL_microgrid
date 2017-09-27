function [r,Q_update]=bytest_RL_notime_sub_function(SoC_future,newstate,SoC_now,SoC_initial,alpha,Qvalue,Qtable,~,nstrategy,t,t0,gamma,aupdate)

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
if t~=23
    r=0.5*(SoC_now)+0.7*alpha;
elseif SoC_now>=0.8
        r=20;
else
        r=500*(SoC_future-SoC_initial);
end

%updating law
candidate=zeros(1,nstrategy);

    for inner=1:nstrategy 
        candidate(inner)=Qtable(1,newstate,inner);
    end
if r+gamma*max(candidate)-Qvalue>0
    Q_update=Qvalue+aupdate/t0*(r+gamma*max(candidate)-Qvalue);
else
    Q_update=Qvalue;
end


