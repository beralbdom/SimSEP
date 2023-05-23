
% Lê todos os 24 arquivos "ieee-x.txt' gerados pelo 'escrever_sistema';
% Roda o Flow para esses 24 arquivos;
% Escreve na planilha 'Fluxos.xlsx'as informações sobre o Fluxo, V e Teta;


for jj=1:24
    sis_file=strcat('ieee14-',int2str(jj),'.txt');
    planilha = strcat('Plan',int2str(jj));
    [Caso, Barra, Ramo, M, N]=ler_sistema(sis_file);
    [mat_fluxo, voltage, ang]=FLow2(M,N);
    xlswrite('Fluxos.xlsx', mat_fluxo, planilha,'B6:K25');
    xlswrite('Fluxos.xlsx', voltage, planilha, 'O6');
    xlswrite('Fluxos.xlsx', ang, planilha, 'P6');
end
    

