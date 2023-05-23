% ---------------------------------------------------------------------- %
% ---------------------------- pot_ativa ------------------------------- %
% ---------------------------------------------------------------------- %

% Esse programa pega os elementos das colunas da matriz 'pot_ativa' e  substitui na coluna 11 do arquivo 'S1_CS01_39M.med'


num_med = 39;                               % n�mero de medidas do arquivo 'S1_CS01_39M.med'
mat_aux_fluxo = zeros(20,10);               % matriz auxiliar que vai receber os dados de fluxo da planilha 'Fluxos.xlsx'
lin_pot_ativa = 0;                          % quantidade de linhas da matriz 'pot_ativa'
mat_pot_ativa = zeros(lin_pot_ativa,24);    % conta quantas linhas de pot�ncia ativa (tipo 1) existe na matriz 'mat_med'
cont_pot_ativa = 0;

% Conta quantas linhas de Fluxo de Pot�ncia Ativa tem na matriz 'mat_med'
% Essa ser� o n�mero de linhas da matriz 'mat_pot_ativa'


for linha = 1:num_med;
    if mat_med(linha,5) == 1;
        cont_pot_ativa = cont_pot_ativa + 1;
    end
end


for ii = 1:2;
    aba_plan = strcat('Plan',int2str(ii));
    mat_aux_fluxo = xlsread('Fluxos.xlsx', aba_plan, 'B6:K25');
    cont = 1;
    
    for k = 1:20;
        for m = 1:cont_pot_ativa;
            if mat_aux_fluxo(k,1:2) == mat_med(m,2:3);
                lin_pot_ativa = lin_pot_ativa + 1; 
            end
            if mat_aux_fluxo(k,1:2) == wrev(mat_med(m,2:3));
                lin_pot_ativa = lin_pot_ativa + 1;              
            end           
        end
    end
    
    mat_pot_ativa = zeros(lin_pot_ativa,24);
    vet_col = zeros(lin_pot_ativa,1);
        
    for col_mat_pot_ativa = 1:24; % colunas da matriz 'mat_pot_ativa'
        %cont = 1;
        for k = 1:20;            
           cont = 1;
            for m = 1:cont_pot_ativa;
                if mat_aux_fluxo(k,1:2) == mat_med(m,2:3);
                    vet_col(cont,1) = mat_aux_fluxo(k,3);
                    cont = cont + 1;
                
                
                elseif mat_aux_fluxo(k,1:2) == wrev(mat_med(m,2:3));
                    vet_col(cont,1) = -(mat_aux_fluxo(k,3));
                    cont = cont + 1;
                end
            end
            
        end
        mat_pot_ativa(:,col_mat_pot_ativa) = vet_col;
        
    end
       
end


% ---------------------------------------------------------------------- %
% ------------------- Escrevendo no arquivo.med ------------------------ %
% ---------------------------------------------------------------------- %

for t = 1:24;
    
    med_arq = strcat('S1_CS01_39M-',int2str(t),'.txt');
    med_write = fopen(med_arq, 'w');
    format = '%04i %04i %04i %02i %02i %03i %01i %05.3f %05.3f %8.6f %+8.5f %+8.5f  \r\n';
    tam = size(mat_pot_ativa);
    aux = tam(1,1);
    
    for k = 1:aux;
        fprintf(med_write, format, transp(medidores.num(k)), transp(medidores.de(k)), transp(medidores.para(k)), transp(medidores.circ(k)), transp(medidores.tipo(k)), transp(medidores.PMU_num(k)), transp(medidores.ok(k)), transp(medidores.acc(k)), transp(medidores.fs(k)), transp(medidores.dp(k)), mat_pot_ativa(k), transp(medidores.leitura(k)));
    end
    
    for k = aux+1:num_med;
        fprintf(med_write, format, transp(medidores.num(k)), transp(medidores.de(k)), transp(medidores.para(k)), transp(medidores.circ(k)), transp(medidores.tipo(k)), transp(medidores.PMU_num(k)), transp(medidores.ok(k)), transp(medidores.acc(k)), transp(medidores.fs(k)), transp(medidores.dp(k)), transp(medidores.ref(k)), transp(medidores.leitura(k)));
    end
    
end



