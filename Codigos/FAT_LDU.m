% Desenvolvido por: Wellyngton Soares
% Email: wsoares@id.uff.br
function [L,D,U]=FAT_LDU (A)
    n=length(A);
    U=A;
    D(1:n,1:n)=0;
    if n==1
        L(1,1)=1;
    else
      for k=1:n-1                              %Controla linha e coluna do pivo
        if k==1
            for j=1:n
                if k==j
                    L(k,j)=1;
                elseif k<j
                    L(k,j)=0;
                end
            end
        end
        for i=k+1:n                          %Controla linha modificada
            pivo=U(i,k)/U(k,k);
            for j=1:n                        %Controla coluna da matriz A
                U(i,j)=U(i,j)-pivo*U(k,j);   %Modifica linha de A  
                if i==j
                    L(i,j)=1;
                elseif i<j
                    L(i,j)=0;
                elseif (i>j && j==k)
                    L(i,j)=pivo;
                end
            end
        end
      end
    end
    for i=1:n
        for j=1:n
            if i==j
                pivoU=U(i,j);
                D(i,j)=pivoU;
                U(i,j)=1;
            else
                U(i,j)=U(i,j)/pivoU;
            end
        end
    end
end