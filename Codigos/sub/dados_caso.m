function dados_caso(Caso, fout)

if nargin == 1; fout = 1; end
fprintf(fout, '--- DADOS DA REDE --------------------------------------------------------------- \n');
fprintf(fout, 'Data do caso:                  %s\n', Caso.data);
fprintf(fout, 'Origem:                        %s\n', Caso.origem);
fprintf(fout, 'MVA base:                      %d\n', Caso.MVA);
fprintf(fout, 'Ano:                           %d\n', Caso.ano);
fprintf(fout, 'Esta��o:                       %s\n', Caso.epoca);
fprintf(fout, 'Identifica��o:                 %s\n', Caso.ident);
fprintf(fout, 'N�mero de barras:              %d \n', Caso.NB);
fprintf(fout, 'N�mero de ramos:               %d \n', Caso.NR);
fprintf(fout, 'Refer�ncia na barra:           %d\n\n', Caso.Bref);
return

