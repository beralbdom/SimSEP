clear
[medidores, Nmed] = ler_medidores('.\med\S1_CS5_352M.med'); % Dados de v e t do Load Flow %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Retira de Full Conv apenas algumas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NUM=size(medidores.num);
contador=0;
%B=[2 5 9 11 12 17 21 24 25 28 34 37 40 45 49 52 56 62 63 68 73 75 77 80 85 86 90 94 101 105 110 114];
%A=[2 5 9 11 12 17 21 25 28 114];
IEEE34=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 20 21 22 23 25 26 27 28 29 30 31 32 113 114 115 117];
tam=size(IEEE34);
tipos=[6 1 2 4 5];
for k=1:1
    for j=1:tam(2)
        for i=1:NUM(2)
            if medidores.de(i)==0 && medidores.para(i)==IEEE34(j) && medidores.tipo(i)==tipos(k)
                contador=contador+1;
                dados(contador,1) = contador;
                dados(contador,2) = medidores.de(i);
                dados(contador,3) = medidores.para(i);
                dados(contador,4) = medidores.circ(i);
                dados(contador,5) = medidores.tipo(i);
                dados(contador,6) = medidores.PMU_num(i);
                dados(contador,7) = medidores.ok(i);
                dados(contador,8) = medidores.acc(i);
                dados(contador,9) = medidores.fs(i);
                dados(contador,10) = medidores.dp(i);
                dados(contador,11) = medidores.ref(i);
                dados(contador,12) = medidores.leitura(i);
            end
        end
    end
end
for k = 2:5
    for j=1:tam(2)
        for i=1:NUM(2)
            if medidores.de(i)==IEEE34(j) && medidores.tipo(i)==tipos(k)
                contador=contador+1;
                dados(contador,1) = contador;
                dados(contador,2) = medidores.de(i);
                dados(contador,3) = medidores.para(i);
                dados(contador,4) = medidores.circ(i);
                dados(contador,5) = medidores.tipo(i);
                dados(contador,6) = medidores.PMU_num(i);
                dados(contador,7) = medidores.ok(i);
                dados(contador,8) = medidores.acc(i);
                dados(contador,9) = medidores.fs(i);
                dados(contador,10) = medidores.dp(i);
                dados(contador,11) = medidores.ref(i);
                dados(contador,12) = medidores.leitura(i);
            end
        end
    end
end
contador
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Grava Arquivo .med                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
format = '%04i %04i %04i %02i %02i %03i %01i %05.3f %05.3f %10.6f %+10.5f %+10.5f\n';
fid = fopen('.\med\S1_CS5_100M_Conv_34.med', 'wt');
% Grava os dados dos medidores
fprintf(fid, format, dados');
% Fecha o arquivo de medidores
fclose(fid);