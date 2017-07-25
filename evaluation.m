function cost=evaluation(k,t,batterystage,Energy,SoC,b0,daygoal,phireal,add,deadload,guess)
daygoal2=daygoal*40;
T=1;
n=20;
dT=T/n;
[En,Sn]=pdf2_add(t,dT,1,k,0,n*(24-t),phireal,add,deadload,guess);
P=zeros(1,batterystage);
if t~=24
    for l=1:(batterystage)
        P(l)=(normcdf(((Energy/batterystage*(l+1)-SoC*Energy)*1-En*(24-t))/sqrt(Sn)))-(normcdf(((Energy/batterystage*(l)-SoC*Energy)*1-En*(24-t))/sqrt(Sn)));
    end      
        if 1-sum(P(1:daygoal2))>0.5 %if there is  possibility reaching 0.8 SoC?
          opteva=b0*(1-sum(P(1:daygoal2)));
          cost=k*(1-b0)+opteva;
       else  %if not stay at minimum alpha
           cost=(1-k)/10;
        end
else
     cost=k*(1-b0)+b0*SoC;
        end
end
   