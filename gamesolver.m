function [ko,alphao, kself] = gamesolver(v,t,~,b0,batterystage,Energy,amin,daygoal,phi,sitenumber,rate)
alphao=zeros(1,sitenumber);
kself=zeros(1,sitenumber);
SoC=(v-56)*0.05+0.5;
daygoal2=daygoal*batterystage;
T=1;
n=20;
dT=T/n;
realp=zeros(1,9);
coder.extrinsic('linearprograming')
coder.varsize('cost1','cost2','realrow','realcolumn')
decide=zeros(1,sitenumber);
P=zeros(1,batterystage*1.5);  
for ppt=1:sitenumber
    opteva=zeros(9);
    cost1=zeros(9);  
    loadrate=rate(ppt);
for k0=amin:1:9
 for sigmaother0=amin:1:9
        k=k0*0.1;
        sigmaother=sigmaother0*0.1;       
        [En,Sn]=pdf2(t,dT,loadrate,k,sigmaother,n*(24-t),phi(ppt));
        if t~=24
        for l=1:(batterystage*1.5)
        P(l)=normcdf(((Energy/batterystage*(l+1)-SoC*Energy)-En*(24-t))/sqrt(Sn))-(normcdf(((Energy/batterystage*(l)-SoC*Energy)-En*(24-t))/sqrt(Sn)));
        end
        if (1-sum(P(1,1:daygoal2)))>0.05 %if there is  possibility reaching 0.8 SoC?
            opteva(k0,sigmaother0)=b0*(sum(P(daygoal2:end)));
            cost1(k0,sigmaother0)=((k*loadrate+sigmaother*(1-loadrate))*(1-b0)*SoC+opteva(k0,sigmaother0));
        else  %if not stay at minimum alpha
            cost1(k0,sigmaother0)=(1-k)/10;
        end
        else
            cost1(k0,sigmaother0)=(k*loadrate+sigmaother*(1-loadrate))*(1-b0)+b0*SoC;
        end
 end
end
 [m,~]=size(cost1);
 realrow=1:m;
p(1:amin-1)=0;
p(amin:9)=linearprograming(cost1(amin:9,amin:9));
po(1:amin-1)=0;
po(amin:9)=linearprograming(cost1(amin:9,amin:9)');
linespace=0.1:0.1:0.9;
alphao(ppt)=po*linespace';
realn=size(realrow,2);
for i=1:realn    
    realp(realrow(i))=p(i);
end
r=rand;
l=0;
for i=1:9        
    l=l+realp(i);
    if l>r
        break
    end
end
decide(ppt)=i*0.1;   
end
kself=decide;
ko=decide*rate'/sum(rate);
end

% 
% function Pload=load2(t,loadrate)
% pl1 =    0.000839 ;
% pl2 =       1.205  ;
% pl3 =      -12.02 ;
% pl4 =       34.29  ;
% ql1 =      -6.495  ;
% ql2 =       43.45  ;
% Pload =loadrate*(500* (pl1*(t)^3 + pl2*(t)^2 + pl3*(t) + pl4) /((t)^2 + ql1*(t) + ql2)+500);
% end
% 
% function Psolar=solar(ti,loadrate)
% t=ti*5;
% p1 =      -327.4 ;
% p2 =   4.435e+04;
% p3 =  -7.078e+05;
% q1 =      -143.6 ;
% q2 =        5928 ;
% Psolar = loadrate*2*(p1*t^2 + p2*t + p3) / (t^2 + q1*t + q2);
% if Psolar>0
% else
%     Psolar=0;
% end
% end
% 
% function [En,Sn]=pdf2(t,dT,loadrate,k,sigmaother,n)
% EPsolar=zeros(1,n);
% SitaPSolar=zeros(1,n);
% SitaLoad=zeros(1,n);
% EPload=zeros(1,n);
% Er=zeros(1,n);
% Var=zeros(1,n);
% Psolar_range=zeros(1,n);
% Pload_range=zeros(1,n);
% for i=1:n
%     timepoint=(t+(i-1)*dT);
%     Pload=load2(timepoint,1);
%     Psolar_range(i)=solar(timepoint,1)*0.4;
%     Pload_range(i)=Pload;
%     Psolar_low=solar(timepoint,1)*0.8;
%     Psolar_high=solar(timepoint,1)*1.2;
%     Load_high=Pload*1.5;
%     Load_low=Pload*0.5;
%     if Psolar_low==0||Psolar_high==0
%         EPsolar(i)=0;
%         SitaPSolar(i)=0;
%     else
%         EPsolar(i)=1/2*(Psolar_high+Psolar_low);
%         SitaPSolar(i)=1/12*(Psolar_high-Psolar_low)^2;
%     end    
%    EPload(i)=(k*loadrate)/2*(Load_high+Load_low)+sigmaother*(1-loadrate)/2*(Load_high+Load_low);
%    SitaLoad(i)=1/12*(((k*loadrate+(sigmaother*(1-loadrate)))^2)*(Load_high-Load_low)^2);
%     Er(i)=EPsolar(i)-EPload(i);
%     Var(i)=SitaPSolar(i)+SitaLoad(i);
%     
% end
% Sn=sum(Var);
% En=sum(Er)/n;
% end

% function [selfchoice,otherchoice]=best_response2(cost1)
% [m,n]=size(cost1);
% selfchoice=zeros(m,n);
% otherchoice=zeros(m,n);
% for j=1:n
%     costhigh=-inf;
%     candidate=0;
%     for i=1:m
%         if costhigh<cost1(i,j)
%          costhigh=cost1(i,j);
%          candidate=i;
%         end
%     end
%     selfchoice(candidate,j)=1;
% end
% for i=1:m
%     costhigh=-inf;
%     candidate=0;
%     for j=1:n
%         if costhigh<cost1(i,j)
%          costhigh=cost1(i,j);
%          candidate=j;
%         end
%     end
%     otherchoice(i,candidate)=1;
% end
% end



