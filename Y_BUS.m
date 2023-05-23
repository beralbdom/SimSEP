% Desenvolvido por: Wellyngton Soares e Daniel Veloso
% Email: wsoares@id.uff.br
function [YB]=Y_BUS(D_BUS,k_BUS,D_LINE,k_LINE)
 % Cálculo Ybus
 NB(1:k_BUS)=sort(D_BUS(1:k_BUS,1));
 YB(1:k_BUS,1:k_BUS)=0;
 for m=1:k_LINE
     y1=0;y2=0;
     for n=1:k_BUS                             % Índice barra
         if D_LINE(m,1)==NB(n)
             y1=n;
         elseif D_LINE(m,2)==NB(n)
             y2=n;
         elseif y1~=0 && y2~=0
             break
         end
     end
     if D_LINE(m,1)~=0 && D_LINE(m,2)==0
         YB(y1,y1)=1/(D_LINE(m,3)+1i*D_LINE(m,4))+1i*D_LINE(m,5)+YB(y1,y1);
     elseif D_LINE(m,1)==0 && D_LINE(m,2)~=0
         YB(y2,y2)=1/(D_LINE(m,3)+1i*D_LINE(m,4))+1i*D_LINE(m,5)+YB(y2,y2);
     elseif D_LINE(m,1)~=0 && D_LINE(m,2)~=0
         t=D_LINE(m,6);fi=D_LINE(m,7);
         tap=t*exp(1i*fi);
         ykm=1/(D_LINE(m,3)+1i*D_LINE(m,4));
         YB(y1,y1)=ykm/(tap*conj(tap))+1i*D_LINE(m,5)+YB(y1,y1);
         YB(y2,y2)=ykm+1i*D_LINE(m,5)+YB(y2,y2);
         YB(y1,y2)=-ykm/tap+YB(y1,y2);
         YB(y2,y1)=-ykm/(conj(tap))+YB(y2,y1);
     end
 end
end