clear
[medidores, Nmed] = ler_medidores('.\med\S1_CS5_90M_Conv.med');
contador=0;
for i=1:Nmed
    dados(i,1) = i;
    dados(i,2) = medidores.de(i);
    dados(i,3) = medidores.para(i);
    dados(i,4) = medidores.circ(i);
    dados(i,5) = medidores.tipo(i);
    dados(i,6) = medidores.PMU_num(i);
    dados(i,7) = medidores.ok(i);
    dados(i,8) = medidores.acc(i);
    dados(i,9) = medidores.fs(i);
    dados(i,10) = medidores.dp(i);
    dados(i,11) = medidores.ref(i);
    dados(i,12) = medidores.leitura(i);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tem que aprender a tirar alguns Ramos antes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% De 34 para 118 deve-se percorrer de traz pra frente
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
de34para118=[34 117
    33 115
    32 114
    31 113
    30 32
    29 31
    28 30
    27 29
    26 28
    25 27
    24 26
    23 25
    22 23
    21 22
    20 21
    19 20];
tam=size(de34para118);
for k=tam(1):-1:1
    for i=1:Nmed
        if medidores.de(i)==de34para118(k,2)
            medidores.de(i)=de34para118(k,1);
        end
        if medidores.para(i)==de34para118(k,2)
            medidores.para(i)=de34para118(k,1);
        end
        if medidores.PMU_num(i)==de34para118(k,2)
            medidores.PMU_num(i)=de34para118(k,1);
        end
    end
end
dados(:,2)=medidores.de;
dados(:,3)=medidores.para;
dados(:,6)=medidores.PMU_num;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Grava Arquivo .med                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
format = '%04i %04i %04i %02i %02i %03i %01i %05.3f %05.3f %10.6f %+10.5f %+10.5f\n';
fid = fopen('.\med\S1_CS5_90M_Conv_34.med', 'wt');
% Grava os dados dos medidores
fprintf(fid, format, dados');
% Fecha o arquivo de medidores
fclose(fid);