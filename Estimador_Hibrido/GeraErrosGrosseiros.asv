path('.\sub', path);
med_file = input('Arquivo de dados dos medidores: ', 's');
[medidores, Nmed]=ler_medidores(med_file);
for j=1:1
    medidores.leitura(j)=medidores.leitura(j)+2;
    %( Bolar como fazer com o nome do arquivo )
    for k = 1 : Nmed
        dados(1,k)=medidores.de(k);
        dados(2,k)=medidores.para(k); 
        dados(3,k)=medidores.circ(k);
        dados(4,k)=medidores.tipo(k);
        dados(5,k)=medidores.PMU_num(k);
        dados(6,k)=medidores.ok(k);
        dados(7,k)=medidores.acc(k);
        dados(8,k)=medidores.fs(k);
        dados(9,k)=medidores.dp(k);
        dados(10,k)=medidores.ref(k);
        dados(11,k)=medidores.leitura(k);
    end
    fid=fopen('concatenado.med','w');
    fprintf(fid, '%s', dados);
    fclose(fid);
    medidores.leitura(j)=medidores.leitura(j)-2;
end