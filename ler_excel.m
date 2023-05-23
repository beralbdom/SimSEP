% ----------------------------------------------------------------------- %
% ------------------------------- ler_excel ----------------------------- %
% ----------------------------------------------------------------------- %


% Ler Voltage & Ang da planilha "Fluxos.xlsx";
% Armazena nas matrizes 'mat_voltage' e 'mat_ang' as informa��es referentes a tens�o e �ngulo, respectivamente, retiradas da planilha;
% O arquivo excel deve ser preenchido conforme padr�o da planilha 'Fluxos.xlsx'.


function [mat_voltage, col_ang] = ler_excel()

arq = input('Entre com o nome do arquivo do excel que deseja ler as Tens�es e Angulos:', 's');
arq = strcat(arq,'.xlsx');

mat_voltage = zeros(14,24);
col_ang = zeros(14,24);

for jj = 1:24;
    file=strcat('Plan',int2str(jj));
    mat_voltage(:,jj) = xlsread(arq, file,'O6:O19');
    col_ang = xlsread(arq, file,'P6:P19');
    %mat_ang(:,jj) = col_ang;
end





