function x=linearprograming(Apre)
[m,n]=size(Apre);
mark=[];
k=0;
eliminate=0;
for i=1:n
    if Apre(:,i)==zeros(m,1)
        k=k+1;
        mark(k)=i;
        eliminate=1;
    end
end
Apre(:,mark)=[];
x0=ones(m,1)/m;
A=[];
b=[];
lb=zeros(m,1);
ub=[];
Aeq=ones(1,m);
beq=1;
x=fminimax(@(x)(-Apre'*x),x0,A,b,Aeq,beq,lb,ub);
% k=1;
% l=1;
% x=zeros(1,n)';
% if eliminate==1
%     for i=1:n
%         if i~=mark(k)
%             x(i)=x0(l);
%             l=l+1;
%         else
%             x(i)=0;
%             k=k+1;
%         end
%     end
% else
%     x=x0;
% end
% x
end
