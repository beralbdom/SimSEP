% ----------------------------------------------------------------------- %
% ----------------- escrever medidores_leitura em txt ------------------- %
% ----------------------------------------------------------------------- %

% Abre o arquivo "Simulador de Medidas_II.xlsx";
% Le a coluna I (chute) desse arquivo;
% Substitui essa coluna lida na coluna "medidores.leitura" dos arquivos "S1_CS01_39M-Y.txt" que foram gerados anteriormente pelo programa "escrever_medidores_ref_leitura";

% ----------- Acessando o arquivo "Simulador de Medidas_II.xlsx" -------- %

Nmed = 39;
file = input('Entre com o nome do arquivo de Simulador de Medidas:', 's');
file = strcat(file,'.xlsx');
for ii = 1:24;
    arq_read = strcat('S1_CS01_39M-',int2str(ii),'.txt');
    [medidores, Nmed, mat_med]=ler_medidores(arq_read);
    aba_plan = strcat('SimMedidasConv_',int2str(ii));
    medidores.leitura = xlsread(file, aba_plan, 'I5:I43');
        
    % ------------ Escrevendo os arquivos "S1_CS01_39M_final-" ---------- %
    med_arq = strcat('S1_CS01_39M_final-',int2str(ii),'.med'); % troquei ".txt" para ".med"
    
    celldata(ii) = cellstr(med_arq);
    arq_medidores = celldata;
    
    
    med_write = fopen(med_arq, 'w');
    format = '%04i %04i %04i %02i %02i %03i %01i %05.3f %05.3f %8.6f %+8.5f %+8.5f  \r\n';
    for hh = 1:Nmed;
        fprintf(med_write, format, transp(medidores.num(hh)), transp(medidores.de(hh)), transp(medidores.para(hh)), transp(medidores.circ(hh)), transp(medidores.tipo(hh)), transp(medidores.PMU_num(hh)), transp(medidores.ok(hh)), transp(medidores.acc(hh)), transp(medidores.fs(hh)), transp(medidores.dp(hh)), transp(medidores.ref(hh)), medidores.leitura(hh));
    end      
end

[nlin,ncol] = size(arq_medidores);

for kk = 1:24
    copyfile (arq_medidores{nlin,kk}, 'Estimador_Hibrido\med');
end

