path('.\sub', path);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Lê Arquivo Medidores Sem Erros Grosseiros               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
med_file = input('Ler medidores no arquivo:[medidores.dat] ', 's');
[medidores, Nmed] = ler_medidores(med_file);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Calcula Desvios das Medidas                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[medida]=medidores.ref';
[Desvios]=cal_var(medidores,medida);
Erro=50;
EG=Erro*Desvios;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Monta Novo Arquivo de Medidores                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
format = '%04i %04i %04i %02i %02i %03i %01i %05.3f %05.3f %10.6f %+10.5f %+10.5f\n';
par=[1,2
    3,4
    5,6
    7,8
    9,16
    10,15
    11,14
    12,13
    17,21
    18,22
    19,24
    20,23
    25,30
    26,29
    27,28
    31,37
    32,38
    33,35
    34,36];
[Npar,Mpar]=size(par);
for i=1:Npar
    medidores.leitura(par(i,1))=medidores.ref(par(i,1))+EG(par(i,1));
    medidores.leitura(par(i,2))=medidores.ref(par(i,2))+EG(par(i,2));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Grava .med da Etapa B                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
med_file1 = 'medidores.dat';
format = '%04i %04i %04i %02i %02i %03i %01i %05.3f %05.3f %10.6f %+10.5f %+10.5f\n';
fid = fopen(med_file1, 'wt');
fprintf(fid, format, medidores);
fclose(fid);