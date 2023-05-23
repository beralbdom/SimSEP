% ------------------- Rodando o Estimador de Estados -------------------- %

tol_max = 0.0001;
int_max = 10;
S_PESO = 1;
med_opt = 0;
DBG = 0;

for ii = 1:24;
    med_file = strcat('med\S1_CS01_39M_final-', int2str(ii),'.med');
    sis_file = strcat('sist\Relatorio-', int2str(ii),'.txt');
    out_file = strcat('Hora-',int2str(ii),'.txt');
    [V, Vref, conv ] = ee(med_file, sis_file, tol_max, int_max, S_PESO, out_file, med_opt, DBG);
end
