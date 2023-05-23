% ----------------------------------------------------------------------- %
% ------------------------------ escrever_excel-------------------------- %
% ----------------------------------------------------------------------- %

% Lê todos os 24 arquivos "ieee-x.txt' gerados pelo 'escrever_sistema';
% Roda o Flow para esses 24 arquivos;
% Escreve na planilha 'Fluxos.xlsx'as informações sobre o Fluxo, V e Teta;

passo=1;
for jj=1:24/passo
    sis_file=strcat('ieee14-',int2str(jj),'.txt');
    planilha = strcat('Plan',int2str(jj));
    [Caso, Barra, Ramo, M, N]=ler_sistema(sis_file);
% sorteia se vai haver falta
    [mat_fluxo, voltage, ang]=FLow2(M,N);
% sorteio de onde (barra) e qual (mono bi tri ou bit) vetor op
%    [mat_fluxo, voltage, ang]=anaofaz(op);   
    xlswrite('Fluxos.xlsx', mat_fluxo, planilha,'B6:K25');
    xlswrite('Fluxos.xlsx', voltage, planilha, 'O6');
    xlswrite('Fluxos.xlsx', ang, planilha, 'P6');
end
    

