function x3=multiple_run_test_add(v,t,wk,wa,batterystage,Energy,amin,daygoal,phi,add)
SoC=(v-56)*0.05+0.5;
T=1;
globalsearch=0.5;
n=20;
dT=T/n;
P=zeros(1,batterystage);
costhigh=-inf;
k0=amin;
opteva=zeros(1,9);
cost=zeros(1,9);
aminr=amin*0.1;
daygoal2=daygoal*40;
for k=aminr:0.05:0.9
[En,Sn]=pdf2_add(t,dT,1,k,0,n*(24-t),phi,add,0,0);
for l=1:(batterystage*1.5)
    P(l)=(normcdf(((Energy/batterystage*(l+1)-SoC*Energy)*1-En*(24-t))/sqrt(Sn)))-(normcdf(((Energy/batterystage*(l)-SoC*Energy)*1-En*(24-t))/sqrt(Sn)));
end   
      if (1-sum(P(1:daygoal2)))>0.05 %if there is  possibility reaching 0.8 SoC?
          opteva(k0)=wa*(sum(P(daygoal2:end)));
          cost(k0)=(k*(wk)*SoC+opteva(k0));
      else  %if not stay at minimum alpha
          cost(k0)=(1-k)/10;
      end
      
      k0=k0+1;
end
cost(1:amin-1)=zeros(1,amin-1);

for i=1:(1+(0.9-aminr)/0.05)
if cost(i)>costhigh
    costhigh=cost(i);
    globalsearch=i*0.05;
end
end
% 
% [En,Sn]=pdf2(t,dT,1,globalsearch,0,n*(24-t),1);
% for l=1:(batterystage)
%     P(l)=(normcdf(((Energy/batterystage*(l+1)-SoC*Energy)*1-En*(24-t))/sqrt(Sn)))-(normcdf(((Energy/batterystage*(l)-SoC*Energy)*1-En*(24-t))/sqrt(Sn)));
% end  

 x3=globalsearch;
end



