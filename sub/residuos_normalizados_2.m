function [medidores, mc] = residuos_normalizados_2(medidores, E)
% An�lise dos residuos normalizados
Nmed = length(medidores.num);
cand = [];
c_cand = [];
% Passo 1 - Verifica medidas cr�ticas
mc = [];    % Vetor com as medidas cr�ticas
n_mc = 0;   % N�mero de medidas cr�ticas
Tol_RN = 1e-5;
Tol_DP = 1e-6;
Tol_RO = 1e-4;
Tol_LB = 1e-5;

for i = 1 : Nmed
    %  Se o medidor est� habilitado
    if medidores.ok(i) == 0
        if medidores.residuo(i) <= Tol_RN && medidores.dpc(i) <= Tol_RN
            % medida � critica
            n_mc = n_mc + 1;
            medidores.rn(i) = 0;
            mc(n_mc) = medidores.num(i);
        end
    end
end
% Passo 2 - C�lculo dos res�duos normalizados
for i = 1 : Nmed
    %  Se o medidor est� habilitado
    if medidores.ok(i) == 0
        if medidores.dpc(i) >= Tol_DP
            % Calcula res�duo normalizado
            medidores.rn(i) = abs(medidores.residuo(i) / medidores.dpc(i));
        elseif medidores.dpc(i) == 0
            % Res�duo normalizado infinito
            medidores.rn(i) = 99999.9999;
        end
    else
        medidores.rn(i) = 0;
    end
end
% Passo 3 - Ordena os res�duos normalizados
A = medidores.num';
B = medidores.ok';
C = medidores.rn';
res_ord = sortrows([A B C], 3);
% Passo 3 - Encontra os conjuntos cr�ticos
k = 0;
for i = 1 : Nmed
    med_ni = res_ord(i,1);
    med_oi = res_ord(i,2);
    med_ri = res_ord(i,3);
    if  med_oi == 0 % Medidor est� habilitado
        k = k + 1;
        q = 1;
        cand(k,q)= med_ni;
        for j = i + 1 : Nmed
            med_nj = res_ord(j,1);
            med_oj = res_ord(j,2);
            med_rj = res_ord(j,3);
            if  med_ni ~= med_nj && med_oj == 0
                % Medidor j diferente do i e habilitado? 
                RO = med_ri/med_rj;
                if RO >= (1 - Tol_RO) && RO <= (1 + Tol_RO)
                    q = q + 1;
                    cand(k,q) = med_nj;
                end
            end
        end
    end
end

%Separa os conjuntos candidatos
k = 1;
[lins,cols] = size(cand);

for i = 1 : lins
    nc = find(cand(i,:));
    if length(nc) >= 2
        c_cand(k,:) = cand(i,:);
        k = k + 1;
    end
end

% Mostra os poss�veis conjuntos cr�ticos
[lins,cols] = size(c_cand);
fprintf('Poss�veis conjuntos cr�ticos:\n');
for i = 1 : lins
    fprintf('Conjunto %d:', i );
    nc = length(find(c_cand(i,:)));
    for j = 1 : nc
        fprintf(' %d', c_cand(i,j));
    end
    fprintf('\n');
end
% Calcula a correla��o
for k = 1 : lins
    nc = length(find(c_cand(k,:)));
    for i = 1 : nc
        for j = i : nc
            Eij = E(c_cand(k,i), c_cand(k,j));
            Eii = E(c_cand(k,i), c_cand(k,i));
            Ejj = E(c_cand(k,j), c_cand(k,j));
            LB(i,j) = abs(Eij)/(sqrt(Eii) * sqrt(Ejj));
            if LB(i,j) >= (1 - Tol_LB) && LB(i,j) <= (1 + Tol_LB) && i ~= j
                % Medidas com alta correla��o
                fprintf('Medidas com alta correla��o: %d e %d \n', c_cand(k,i), c_cand(k,j));
            end
        end
    end 
end
            
        

       


%                     Eij = E(med_ni,med_nj);
   
%                     Ejj = E(med_nj,med_nj);
%                     
%                     
%                     
%                     
%                         
%                         n_c = n_c + 1;
%                         
%                         med_ni
%                         med_nj
%                                                 
% %                         cc(n_cc,n_c) = medidores.num(j);
%                     end
%                 end
%             end
%         end
% %         if n_c > 1
% %             n_cc = n_cc + 1;
% %         else
% %             cc(n_cc) = [];
% %             n_cc = n_cc + 1;
% %         end
%     end
% end
% 
%                     
%             
% 
% 
% return
