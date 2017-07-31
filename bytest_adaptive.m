function bytest_adaptive
clear workspace
n=48;
SoC=zeros(1,n);
SoC(1)=0.75;
v=zeros(1,n);
alpha=zeros(1,n);
v(1)=(SoC(1)-0.5)/0.05+56;
Energy=1*25*1000;
b0=0.5;
wa=1-b0;
socm=40;
batterystage=40;
cost=zeros(1,n);
cg=zeros(1,socm);
co=zeros(1,socm);
cc=zeros(1,socm);
amin=1;
dump1=5;
dump2=15;
daygoal=0.8;
phireal=0.5;
sitenumber=4;
rate=[0.2 0.3 0.2 0.3];
phi=[0 0 0];
p0=100;
dflag=zeros(1,n+1);
estpre=SoC(1)*batterystage;
adp_int=12;
sitabig(1)=0;
ktotal=1;
% 
% for t0=1:n
%     t=mod(t0,24);
% %     alpha(t)=multiple_run_test(v(t),t,b0,batterystage);
%     alpha0=gamesolver_virtual_load(v(t0),t,wa,b0,batterystage,Energy,amin,daygoal,phi,sitenumber,rate);
%     alpha(t0)=alpha0;
%     cost(t0)=evaluation(alpha(t0),t,batterystage,Energy,SoC(t0),b0,daygoal,phireal*(t0>=dump1&&t0<=dump2));
%     SoC(t0+1)=(SoC(t0)*Energy-integral(@(x)load2(x),t,t+1)*alpha(t0)+integral(@(y)solar(y),t,t+1)*(1-1*(t0>dump1&&t0<dump2)))/Energy;
%     v(t0+1)=(SoC(t0+1)-0.5)/0.05+56;
%     
%     adptemp=1;
%     adptempinner=1;
%     %adaptive estimation try
% %     E=zeros(1,adp_int);
% %     Estar=zeros(1,adp_int);
%     sita=zeros(1,14);
%     for tinterval=t0:(1/adp_int):t0+1
%         E(adptemp)=(load2(tinterval)*alpha(t0)-solar(tinterval)+p0*sitabig(adptemp));
%         Etotal(ktotal)=E(adptemp);
%         Estar(adptemp)=load2(tinterval)*alpha(t0)-solar(tinterval)*(1-0.5*(t0>dump1&&t0<dump2));
%         Estartotal(ktotal)=Estar(adptemp);
%         ktotal=ktotal+1;
% %         e0=integral(@(x)load2(x),tinterval,tinterval+(1/adp_int))*alpha(t0)-integral(@(y)solar(y),tinterval,tinterval+(1/adp_int))*(1-0.5*(t0>dump1&&t0<dump2))-(integral(@(x)load2(x),tinterval,tinterval+(1/adp_int))*alpha(t0)-integral(@(y)solar(y),tinterval,tinterval+(1/adp_int))*sitabig(adptemp)*(1));
%         sita(1)=sitabig(adptemp);
% %         trace(1)=sita(1);
%         for ininer=tinterval:(1/(adp_int)^2):(tinterval+(1/adp_int))
% %         trace((adptemp-1)*adp_int+adptempinner)=sita(adptempinner);
% %         Etrace((adptemp-1)*adp_int+adptempinner)=(load2(ininer)*alpha(t0)-solar(ininer)*trace((adptemp-1)*adp_int+adptempinner));
%         e0=integral(@(x)load2(x),tinterval,tinterval+(1/adp_int))*alpha(t0)-integral(@(y)solar(y),tinterval,tinterval+(1/adp_int))*(1-0.5*(t0>dump1&&t0<dump2))-(integral(@(x)load2(x),tinterval,tinterval+(1/adp_int))*alpha(t0)-integral(@(y)solar(y),tinterval,tinterval+(1/adp_int))+p0*sitabig(adptemp)*(1/adp_int));
%         sita(adptempinner+1)=sita(adptempinner)+0.5e-4*(e0*p0+1);
%         adptempinner=adptempinner+1;
%         end
%         sitabig(adptemp+1)=sita(adptempinner);
%         adptempinner=1;
%         adptemp=adptemp+1;
%     end
%     sitabig(1)=sitabig(adptemp);
% %     figure
% %     scatter(t0:(1/adp_int):t0+1,E,'MarkerFaceColor','r');
% %     hold on
% %     scatter(t0:(1/adp_int):t0+1,Estar,'MarkerFaceColor','b');
% % %     scatter(t0:(1/156):t0+1,Etrace,'MarkerFaceColor','y');
% %     hold off
% 
%     v(t0+1)=(SoC(t0+1)-0.5)/0.05+56;
%     soce=(estimatorlow/batterystage);
%     if SoC(t0+1)-(soce)<-0.01
%         dflag(t0+1)=1;
%     end
% end
% figure('Name','Game solution')
% stem(1:n,SoC(1:n))
% hold on
% stem(1:n,alpha)
% stem(1:n,cost)
% legend('SoC','alpha','Obj')
% cg=sum(cost);
dflag=zeros(1,n+1);
estpre=SoC(1)*batterystage;
adp_int=12;
sitabig(1)=0;
ktotal=1;

for t0=1:n
    t=mod(t0,24);   
    adp=1;
    [alpha(t0),estimatorlow,est]=multiple_run_test_adaptive_virtual_load(v(t0),t,wa,b0,batterystage,amin,daygoal,estpre,SoC((t-1)*(t>1)+(t==1)+24*(t==0)),adp,sitabig(1));
%     if disturb==1
%      alpha(t0)=amin*0.1;
%     end
     estpre=est;   
    %[~,~,~,alpha0]=gamesolver(v(t),t,b0,batterystage);
    %alpha(t)=alpha0;
    cost(t0)=evaluation(alpha(t0),t,batterystage,Energy,SoC(t0),b0,daygoal,phireal*(t0>dump1&&t0<dump2),0,0);
    SoC(t0+1)=(SoC(t0)*Energy-integral(@(x)load2(x),t,t+1)*alpha(t0)+integral(@(y)solar(y),t,t+1)*(1-0.5*(t0>dump1&&t0<dump2)))/Energy;
    
    adptemp=1;
    adptempinner=1;
    %adaptive estimation try
%     E=zeros(1,adp_int);
%     Estar=zeros(1,adp_int);
    sita=zeros(1,14);
    for tinterval=t0:(1/adp_int):t0+1
        E(adptemp)=(load2(tinterval)*alpha(t0)-solar(tinterval)+p0*sitabig(adptemp));
        Etotal(ktotal)=E(adptemp);
        Estar(adptemp)=load2(tinterval)*alpha(t0)-solar(tinterval)*(1-0.5*(t0>dump1&&t0<dump2));
        Estartotal(ktotal)=Estar(adptemp);
        ktotal=ktotal+1;
%         e0=integral(@(x)load2(x),tinterval,tinterval+(1/adp_int))*alpha(t0)-integral(@(y)solar(y),tinterval,tinterval+(1/adp_int))*(1-0.5*(t0>dump1&&t0<dump2))-(integral(@(x)load2(x),tinterval,tinterval+(1/adp_int))*alpha(t0)-integral(@(y)solar(y),tinterval,tinterval+(1/adp_int))*sitabig(adptemp)*(1));
        sita(1)=sitabig(adptemp);
%         trace(1)=sita(1);
        for ininer=tinterval:(1/(adp_int)^2):(tinterval+(1/adp_int))
%         trace((adptemp-1)*adp_int+adptempinner)=sita(adptempinner);
%         Etrace((adptemp-1)*adp_int+adptempinner)=(load2(ininer)*alpha(t0)-solar(ininer)*trace((adptemp-1)*adp_int+adptempinner));
        e0=integral(@(x)load2(x),tinterval,tinterval+(1/adp_int))*alpha(t0)-integral(@(y)solar(y),tinterval,tinterval+(1/adp_int))*(1-0.5*(t0>dump1&&t0<dump2))-(integral(@(x)load2(x),tinterval,tinterval+(1/adp_int))*alpha(t0)-integral(@(y)solar(y),tinterval,tinterval+(1/adp_int))+p0*sitabig(adptemp)*(1/adp_int));
        sita(adptempinner+1)=sita(adptempinner)+0.5e-4*(e0*p0+1);
        adptempinner=adptempinner+1;
        end
        sitabig(adptemp+1)=sita(adptempinner);
        adptempinner=1;
        adptemp=adptemp+1;
    end
    sitabig(1)=sitabig(adptemp);
%     figure
%     scatter(t0:(1/adp_int):t0+1,E,'MarkerFaceColor','r');
%     hold on
%     scatter(t0:(1/adp_int):t0+1,Estar,'MarkerFaceColor','b');
% %     scatter(t0:(1/156):t0+1,Etrace,'MarkerFaceColor','y');
%     hold off

    v(t0+1)=(SoC(t0+1)-0.5)/0.05+56;
    soce=(estimatorlow/batterystage);
    if SoC(t0+1)-(soce)<-0.01
        dflag(t0+1)=1;
    end
end
     figure
     plot(1:312*2,Etotal,'MarkerFaceColor','r');
     hold on
     plot(1:312*2,Estartotal,'MarkerFaceColor','b');
%      scatter(t0:(1/156):t0+1,Etrace,'MarkerFaceColor','y');
     hold off
dflag(n+1)=[];
figure('Name','Opt solution')
plot(1:n,SoC(1:n))
hold on
stem(1:n,alpha)
stem(1:n,cost)
stem(1:n,dflag)
legend('SoC','alpha','Obj','dflag')
xlabel('time(Hr)')
co=sum(cost)
% for t0=1:n
%     t=mod(t0,24);
%     alpha(t0)=0.1;
%     %[~,~,~,alpha0]=gamesolver(v(t),t,b0,batterystage);
%     %alpha(t)=alpha0;
%     cost(t0)=evaluation(alpha(t0),t,batterystage,Energy,SoC(t0),b0,daygoal);
%     SoC(t0+1)=(SoC(t0)*Energy-integral(@(x)load2(x),t,t+1)*alpha(t0)+integral(@(y)solar(y),t,t+1)*(1-1*(t0>dump1&&t0<dump2)))/Energy;
%     v(t0+1)=(SoC(t0+1)-0.5)/0.05+56;
%     if SoC(t0+1)>1
%         SoC(t0+1)=1;
%     end
% end
% figure('Name','cc')
% cc=sum(cost);
% stem(1:n,SoC(1:n))
% hold on
% stem(1:n,cost)
% cg
% co
% cc
end
function Pload=load2(t)
pl1 =    0.000839 ;
pl2 =       1.205  ;
pl3 =      -12.02 ;
pl4 =       34.29  ;
ql1 =      -6.495  ;
ql2 =       43.45  ;
Pload =(500* (pl1*(t).^3 + pl2*(t).^2 + pl3*(t) + pl4) ./((t).^2 + ql1*(t) + ql2)+500)*(1+(0.2*rand-0.2*rand)*0);
end

function Psolar=solar(ti)
t=ti*5;
p1 =      -327.4 ;
p2 =   4.435e+04;
p3 =  -7.078e+05;
q1 =      -143.6 ;
q2 =        5928 ;
Psolar = ((p1*t.^2 + p2*t + p3) ./ (t.^2 + q1*t + q2)+80)*(1+(0.5*rand-0.5*rand)*0);

end