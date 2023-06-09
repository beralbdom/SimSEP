function titulo(fout, med_file, sis_file, tol_max, int_max)
% Mostra o t�tulo
if nargin < 2
    fout = 1;
    fprintf(fout, '================================================================================= \n');
    fprintf(fout, '=== UFF - Doutorado em Computa��o - Aplica�oes em Sistemas de Potencia        === \n');
    fprintf(fout, '=== ESTIMADOR DE ESTADO M�NIMOS QUADRADOS PONDERADOS INCLUINDO MEDIDAS DE PMU === \n');
    fprintf(fout, '=== Desenvolvido por: Rui Menezes de Moraes - 2009                            === \n');
    fprintf(fout, '================================================================================= \n');
else
    fprintf(fout, '================================================================================= \n');
    fprintf(fout, '=== UFF - Doutorado em Computa��o - Aplica�oes em Sistemas de Potencia        === \n');
    fprintf(fout, '=== ESTIMADOR DE ESTADO M�NIMOS QUADRADOS PONDERADOS INCLUINDO MEDIDAS DE PMU === \n');
    fprintf(fout, '=== Desenvolvido por: Rui Menezes de Moraes - 2009                            === \n');
    fprintf(fout, '================================================================================= \n');
    fprintf(fout, 'Arquivo de medidores:          %s\n', med_file);
    fprintf(fout, 'Arquivo do sistema:            %s\n', sis_file);
    fprintf(fout, 'Toler�ncia entre itera�oes:    %9.2e\n', tol_max);
    fprintf(fout, 'Limite de itera�oes:           %d\n\n', int_max);
%    fprintf(fout, 'Desvios no Arquivo: (1 - Sim, 0 - N�o): %d\n\n', med_opt);
end
return