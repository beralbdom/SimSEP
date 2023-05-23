% ---------------------------------------------------------------------- %
% ---------------------------- pot_ativa ------------------------------- %
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

% loop para mudar de planilha

plan=1
ler_planilha=strcat('Plan',int2str(plan))
fluxo=xlsread('Fluxos.xlsx',ler_planilha,'B6:k25')
ler_planilha1=strcat('Plan',int2str(plan))
vt=xlsread('Fluxos.xlsx',ler_planilha1,'o6:p19')

% calcular injeções de potencia nas colunas 3 e 4 de vt , se não fores 
% mudar a função de geração do excel para tal

tam_fluxo=size(fluxo)
tam_vt=size(vt)

% loop para resolver fluxos e correntes (OK) %
for ii=1:Nmed
% ---- ler a planilha e tirar todas as informações necessarias dela (OK)- %
    for jj= 1:tam_fluxo(1)
        if (medidores.de(ii)==fluxo(jj,1) && medidores.para(ii)==fluxo(jj,2) && medidores.tipo(ii)==1)
            medidores.ref(ii)=fluxo(jj,3)
        end
        if (medidores.para(ii)==fluxo(jj,1) && medidores.de(ii)==fluxo(jj,2) && medidores.tipo(ii)==1)
            medidores.ref(ii)=fluxo(jj,5)
        end
        if (medidores.de(ii)==fluxo(jj,1) && medidores.para(ii)==fluxo(jj,2) && medidores.tipo(ii)==4)
            medidores.ref(ii)=fluxo(jj,4)
        end            
        if (medidores.para(ii)==fluxo(jj,1) && medidores.de(ii)==fluxo(jj,2) && medidores.tipo(ii)==4)
            medidores.ref(ii)=fluxo(jj,6)
        end            
        if (medidores.de(ii)==fluxo(jj,1) && medidores.para(ii)==fluxo(jj,2) && medidores.tipo(ii)==7)
            medidores.ref(ii)=fluxo(jj,7)*cos(fluxo(jj,8))
        end            
        if (medidores.para(ii)==fluxo(jj,1) && medidores.de(ii)==fluxo(jj,2) && medidores.tipo(ii)==7)
            medidores.ref(ii)=fluxo(jj,9)*cos(fluxo(jj,10))
        end            
        if (medidores.de(ii)==fluxo(jj,1) && medidores.para(ii)==fluxo(jj,2) && medidores.tipo(ii)==8)
            medidores.ref(ii)=fluxo(jj,7)*sin(fluxo(jj,8))
        end            
        if (medidores.para(ii)==fluxo(jj,1) && medidores.de(ii)==fluxo(jj,2) && medidores.tipo(ii)==8)
            medidores.ref(ii)=fluxo(jj,9)*sin(fluxo(jj,10))
        end            
    end
    for jj=1:tam_vt()
        % buscar injeçoes de potencia e modulos de tensões e angulo (tipos
        % 2, 5, 6 e 3
    end
end

% fim do loop das planilhas

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



