% Desenvolvido por: Wellyngton Soares
% Email: wsoares@id.uff.br
function [X]=SOLVE_LDU (L,D,U,B)
    n=length(L);
    for i=1:n
        Z(i,1)=B(i,1);
        if i>1
            for j=1:i-1
                Z(i,1)=Z(i,1)-(L(i,j)*Z(j,1));  
            end
        end
    end
    for i=1:n
        Y(i,1)=Z(i,1)/D(i,i);
    end    
    for i=n:-1:1
        X(i,1)=Y(i,1);
        if i<n
            for j=i+1:n
                X(i,1)=X(i,1)-(U(i,j)*X(j,1));  %Matriz com solução da equação
            end
        end
    end
end