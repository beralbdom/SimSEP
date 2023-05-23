% ---------------------------------------------------------------------- %
% ------------------------- escrever_no_med ---------------------------- %
% ---------------------------------------------------------------------- %

% Esse programa pega os elementos das colunas da matriz 'pot_ativa' e  substitui na coluna 11 do arquivo 'S1_CS01_39M.med'

% variavel fluxo
% coluna 1  de
% coluna 2  para
% coluna 3  P(i,j)
% coluna 4  Q(i,j)
% coluna 5  P(j,i)
% coluna 6  Q(j,i)
% coluna 7  I(i,j)
% coluna 8  delta(i,j)
% coluna 9  I(j,i)
% coluna 10 delta(j,i)

% ----------- Acessando cada aba da planilha 'Fluxos.xlsx' -------------- %
for plan = 1:24;
    ler_planilha=strcat('Plan',int2str(plan));
    fluxo=xlsread('Fluxos.xlsx',ler_planilha,'B6:k25');
    ler_planilha1=strcat('Plan',int2str(plan));
    vt=xlsread('Fluxos.xlsx',ler_planilha1,'N6:P19');
    tam_fluxo=size(fluxo);
    tam_vt=size(vt);

% --------------------- Início do loop dos Fluxos ----------------------- %
    for ii=1:Nmed;
        for jj= 1:tam_fluxo(1);
            if (medidores.de(ii)==fluxo(jj,1) && medidores.para(ii)==fluxo(jj,2) && medidores.tipo(ii)==1)
                medidores.ref(ii)=fluxo(jj,3);
            end
            if (medidores.para(ii)==fluxo(jj,1) && medidores.de(ii)==fluxo(jj,2) && medidores.tipo(ii)==1)
                medidores.ref(ii)=fluxo(jj,5);
            end
            if (medidores.de(ii)==fluxo(jj,1) && medidores.para(ii)==fluxo(jj,2) && medidores.tipo(ii)==4)
                medidores.ref(ii)=fluxo(jj,4);
            end
            if (medidores.para(ii)==fluxo(jj,1) && medidores.de(ii)==fluxo(jj,2) && medidores.tipo(ii)==4)
                medidores.ref(ii)=fluxo(jj,6);
            end
            if (medidores.de(ii)==fluxo(jj,1) && medidores.para(ii)==fluxo(jj,2) && medidores.tipo(ii)==7)
                medidores.ref(ii)=fluxo(jj,7)*cos(fluxo(jj,8));
            end
            if (medidores.para(ii)==fluxo(jj,1) && medidores.de(ii)==fluxo(jj,2) && medidores.tipo(ii)==7)
                medidores.ref(ii)=fluxo(jj,9)*cos(fluxo(jj,10));
            end
            if (medidores.de(ii)==fluxo(jj,1) && medidores.para(ii)==fluxo(jj,2) && medidores.tipo(ii)==8)
                medidores.ref(ii)=fluxo(jj,7)*sin(fluxo(jj,8));
            end
            if (medidores.para(ii)==fluxo(jj,1) && medidores.de(ii)==fluxo(jj,2) && medidores.tipo(ii)==8)
                medidores.ref(ii)=fluxo(jj,9)*sin(fluxo(jj,10));
            end
            if (medidores.de(ii)==0 && medidores.para(ii)==fluxo(jj,1) && medidores.tipo(ii)==2)
                aux = fluxo(jj,1);
                soma_pot_ativa = 0;
                for lin = 1:tam_fluxo(1);
                    if (aux == fluxo(lin,1))
                        soma_pot_ativa = soma_pot_ativa + fluxo(lin,3);
                    end
                    medidores.ref(ii) = soma_pot_ativa;
                    if (aux == fluxo(lin,2))
                        soma_pot_ativa = soma_pot_ativa + fluxo(lin,5);
                    end
                    medidores.ref(ii) = soma_pot_ativa;
                end
            end
            if (medidores.de(ii)==0 && medidores.para(ii)==fluxo(jj,1) && medidores.tipo(ii)==5)
                aux = fluxo(jj,1);
                soma_pot_reativa = 0;
                for lin = 1:tam_fluxo(1);
                    if (aux == fluxo(lin,1))
                        soma_pot_reativa = soma_pot_reativa + fluxo(lin,4);
                    end
                    medidores.ref(ii) = soma_pot_reativa;
                    if (aux == fluxo(lin,2))
                        soma_pot_reativa = soma_pot_reativa + fluxo(lin,6);
                    end
                    medidores.ref(ii) = soma_pot_reativa;
                end
            end
        end
    end


% ------------------- Início do loop para V e Teta ---------------------- %
    for ii = 1:Nmed;
        for jj = 1:tam_vt(1);
            if (medidores.de(ii)==0 && medidores.para(ii)==vt(jj,1) && medidores.tipo(ii)==6)
                medidores.ref(ii) = vt(jj,2);
            end
            if (medidores.de(ii)==0 && medidores.para(ii)==vt(jj,1) && medidores.tipo(ii)==3)
                medidores.ref(ii) = vt(jj,3);
            end     
        end
    end


% -------------------- Escrevendo no arquivo.med ------------------------ %
        med_arq = strcat('S1_CS01_39M-',int2str(plan),'.txt');
        med_write = fopen(med_arq, 'w');
        format = '%04i %04i %04i %02i %02i %03i %01i %05.3f %05.3f %8.6f %+8.5f %+8.5f  \r\n';
        
    for k = 1:Nmed;
        fprintf(med_write, format, transp(medidores.num(k)), transp(medidores.de(k)), transp(medidores.para(k)), transp(medidores.circ(k)), transp(medidores.tipo(k)), transp(medidores.PMU_num(k)), transp(medidores.ok(k)), transp(medidores.acc(k)), transp(medidores.fs(k)), transp(medidores.dp(k)), transp(medidores.ref(k)), transp(medidores.leitura(k)));
    end    
   
end



