function [ko,koreal,alphao, kself] = gamesolver_virtual_load_local_SoC(v,t,~,b0,batterystage,Energy,amin,daygoal,phi,sitenumber,rate,operation,guess,SoC_local)
alphao=zeros(1,sitenumber);
daygoal2=daygoal*batterystage;
T=1;
n=20;
dT=T/n;
realp=zeros(1,9);  
coder.extrinsic('linearprograming')
coder.varsize('cost1','cost2','realrow','realcolumn')
decide=zeros(1,sitenumber);
P=zeros(1,batterystage*1.5);
p=zeros(1,9);
po=zeros(1,9);
for ppt=1:sitenumber
    if operation(ppt)~=0
    opteva=zeros(9);
    cost1=zeros(9);  
    loadrate=rate(ppt);
    if ppt ~= 3
        SoC=SoC_local;
    else
        SoC=(v-56)*0.05+0.5;
    end
for k0=amin:1:9
 for sigmaother0=amin:1:9
        k=k0*0.1;
        sigmaother=sigmaother0*0.1;       
        [En,Sn]=pdf2_add(t,dT,loadrate,k,sigmaother,n*(24-t),phi(ppt),0,0,guess(ppt));
        if t~=24
%         for l=1:(batterystage*1.5)
%         P(l)=normcdf(((Energy/batterystage*(l+1)-SoC*Energy)-En*(24-t))/sqrt(Sn))-(normcdf(((Energy/batterystage*(l)-SoC*Energy)-En*(24-t))/sqrt(Sn)));
%         end
        P_smaller_than_obj=normcdf(((Energy/batterystage*(daygoal2)-SoC*Energy)-En*(24-t))/sqrt(Sn));
        if (1-P_smaller_than_obj)>0.5 %if there is  possibility reaching 0.8 SoC?
            opteva(k0,sigmaother0)=b0*(sum(P(daygoal2:end)));
            cost1(k0,sigmaother0)=((k*loadrate+0*sigmaother*(1-loadrate))*(1-b0)*SoC+0*opteva(k0,sigmaother0));
        else  %if not stay at minimum alpha
            cost1(k0,sigmaother0)=(1-k)/10;
        end
        else
            cost1(k0,sigmaother0)=(k*loadrate+sigmaother*(1-loadrate))*(1-b0)+b0*SoC;
        end
%           cost1(k0,sigmaother0)=k0+SoC;
 end
end
 [m,~]=size(cost1);
 realrow=1:m;
p(1:amin-1)=0;
p(amin:9)=linearprograming(cost1(amin:9,amin:9))';
po(1:amin-1)=0;
% po(amin:9)=linprog(cost1(amin:9,amin:9)');
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
end
kself=decide;
ko=decide*rate(1:sitenumber)'/sum(rate(1:sitenumber));
koreal=decide*rate(1:sitenumber)';
end




