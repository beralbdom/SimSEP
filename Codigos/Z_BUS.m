function [ZB,Zth,NB]=Z_BUS(D_BUS,k_BUS,D_BRANCH,k_BRANCH)
 % Inserção das Impedâncias Shunts
 for m=1:k_BUS
     if D_BUS(m,9) ~= 0 || D_BUS(m,10) ~=0
         k_BRANCH=k_BRANCH+1;
         D_BRANCH(k_BRANCH,1)=D_BUS(m,1);                           % Inserção da Barra
         D_BRANCH(k_BRANCH,2)=0;                                    % Insercão da Referência
         G=D_BUS(m,9);B=D_BUS(m,10);
         D_BRANCH(k_BRANCH,3)=(G/(G^2+B^2));                        % Insercão da Resistência Shunt       
         D_BRANCH(k_BRANCH,4)=(-B/(G^2+B^2));                       % Insercão da Reatância Shunt
     end
 end
 % Cálculo Zbus
 i_B=0;wh=0;
 while i_B < k_BUS
    wh=wh+1;
    if wh>20
        fprintf('\n *** SEM BARRA DE REFERÊNCIA OU DIAGRAMA COM BARRAS NÃO INTERLIGADAS! ***\n\n');
        ZB=0;Zth=0;If=0;
        return
    end
    for m=1:k_BRANCH
        if i_B==0
            % Localiza Barra Inicial com Referência
            if D_BRANCH(m,2)==0 && D_BRANCH(m,1)~=0
                i_B=i_B+1;
                ZB(i_B,i_B)=D_BRANCH(m,3)+1i*D_BRANCH(m,4);     % Valor da Impedância
                NB(i_B,1)=D_BRANCH(m,1);                        % Numero da Barra
                D_BRANCH(m,6)=1;
            elseif D_BRANCH(m,1)==0 && D_BRANCH(m,2)~=0
                i_B=i_B+1;
                ZB(i_B,i_B)=D_BRANCH(m,3)+1i*D_BRANCH(m,4);     % Valor da Impedância
                NB(i_B,1)=D_BRANCH(m,2);                        % Numero da Barra
                D_BRANCH(m,6)=1;    
            end        
        else
            for n=1:i_B
                if (D_BRANCH(m,1)==NB(n,1) || D_BRANCH(m,2)==NB(n,1)) && D_BRANCH(m,6)~=1
                    if D_BRANCH(m,1)==NB(n,1)
                        vr=2;
                    elseif D_BRANCH(m,2)==NB(n,1)
                        vr=1;
                    end
                    if D_BRANCH(m,vr)==0
                        % TIPO 3 - Barra existente para Referência
                        for q=1:i_B
                            L(1,q)=ZB(n,q);C(q,1)=ZB(q,n);
                        end
                        ZBC=ZB;
                        ZBC(i_B+1,i_B+1)=(D_BRANCH(m,3)+1i*D_BRANCH(m,4))+ZB(n,n);   % Valor da Impedância
                        ZBC(1:i_B+1,1:i_B+1)=[ZBC(1:i_B,1:i_B) C;L ZBC(i_B+1,i_B+1)];
                        ZB(1:i_B,1:i_B)=ZBC(1:i_B,1:i_B)-(ZBC(1:i_B,i_B+1)*(ZBC(i_B+1,i_B+1)^(-1)))*ZBC(i_B+1,1:i_B);  % Redução de Kron
                        D_BRANCH(m,6)=1;
                    else
                        for p=1:i_B
                            if D_BRANCH(m,vr)==NB(p,1)
                                % TIPO 4 - Barra existente para Barra existente
                                for q=1:i_B
                                    L(1,q)=ZB(n,q)-ZB(p,q);
                                    C(q,1)=ZB(q,n)-ZB(q,p);
                                end
                                ZBC=ZB;
                                ZBC(i_B+1,i_B+1)=(D_BRANCH(m,3)+1i*D_BRANCH(m,4))+ZB(n,n)+ZB(p,p)-2*ZB(n,p);           % Valor da Impedância
                                ZBC(1:i_B+1,1:i_B+1)=[ZBC(1:i_B,1:i_B) C;L ZBC(i_B+1,i_B+1)];
                                ZB(1:i_B,1:i_B)=ZBC(1:i_B,1:i_B)-(ZBC(1:i_B,i_B+1)*(ZBC(i_B+1,i_B+1)^(-1)))*ZBC(i_B+1,1:i_B);  % Redução de Kron
                                D_BRANCH(m,6)=1;
                                break
                            elseif p==i_B
                                % TIPO 2 - Barra existente para Barra nova
                                for q=1:i_B
                                    L(1,q)=ZB(n,q);C(q,1)=ZB(q,n);
                                end
                                i_B=i_B+1;
                                ZB(i_B,i_B)=(D_BRANCH(m,3)+1i*D_BRANCH(m,4))+ZB(n,n);   % Valor da Impedância
                                NB(i_B,1)=D_BRANCH(m,vr);
                                ZB(1:i_B,1:i_B)=[ZB(1:i_B-1,1:i_B-1) C;L ZB(i_B,i_B)];
                                D_BRANCH(m,6)=1;
                            end
                        end
                    end
                    break
                elseif (n==i_B) && (D_BRANCH(m,1)==0 || D_BRANCH(m,2)==0) && D_BRANCH(m,6)~=1
                    % TIPO 1 - Barra nova para Referência
                    if D_BRANCH(m,1)==0
                        vr1=2;
                    elseif D_BRANCH(m,2)==0
                        vr1=1;
                    end
                    for q=1:i_B
                        L(1,q)=0;C(q,1)=0;
                    end
                    i_B=i_B+1;
                    ZB(i_B,i_B)=D_BRANCH(m,3)+1i*D_BRANCH(m,4);   % Valor da Impedância
                    NB(i_B,1)=D_BRANCH(m,vr1);
                    ZB(1:i_B,1:i_B)=[ZB(1:i_B-1,1:i_B-1) C;L ZB(i_B,i_B)];
                    D_BRANCH(m,6)=1;
                elseif (n==i_B) && (D_BRANCH(m,2)~=0) && D_BRANCH(m,6)~=1
                    % "TIPO 5" - BARRA NOVA PARA BARRA NOVA
                    %disp('TIPO 5')
                end
            end
        end
    end
 end
 % Rotina para ordenar Barras
 NBs=sort(NB);
 NBo=NB;ZBo=ZB;
 for p=1:i_B
     m=NBs(p);
     if NBo(p)~=m
         for n=p:i_B
             if m==NBo(n)
                 break
             end
         end     
         aux=NBo(n);
         NBo(n)=NBo(p);
         NBo(p)=aux;
         Laux=ZBo(n,:);
         ZBo(n,:)=ZBo(p,:);
         ZBo(p,:)=Laux;
         Caux=ZBo(:,n);
         ZBo(:,n)=ZBo(:,p);
         ZBo(:,p)=Caux;
     end
 end
 ZB=ZBo;NB=NBo;
 % Definição do Zth
 for m=1:i_B
     Zth(m,1)=ZB(m,m);
 end
end



        
    
        
