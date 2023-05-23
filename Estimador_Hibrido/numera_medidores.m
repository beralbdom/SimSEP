function Numera_medidores

path('.\sub', path);
med_file = input('Ler medidores no arquivo:[medidores.dat] ', 's');
[medidores, Nmed]=ler_medidores_ant(med_file);
fprintf('Número de medidores lidos %d !\n', Nmed);
grava_arq_med(medidores, med_file);
return
