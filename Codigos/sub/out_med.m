function out_med(medidores, fout)
% Imprime as medidas em arquivo
% Estrutura de medidores
% num           n� do medidor
% de            n� da barra DE
% para          n� da barra PARA
% circ          n� do circuito
% tipo          tipo de medidor
% PMU_num       Medida associada a PMU n
% ok            Utiliza ou nao o medidor
% acc           exatid�o do medidor
% fs            fundo de escala do medidor
% dp            desvio-padr�o
% ref           valor de referencia
% leitura       valor medido
if nargin == 1; fout = 1; end
Nmed = length(medidores.num);
zm = medidores.leitura';
zr = medidores.ref';
dz = zm - zr;
% Calcula o erro das medidas
for i = 1 : Nmed
    if abs(dz(i)) > 1e-6 && abs(zr(i)) > 1e-8
        erro_m(i) = (dz(i) * 100) / zr(i);
    elseif abs(dz(i)) < 1e-8 && abs(zr(i)) > 1e-6
        erro_m(i) = 0;
    elseif abs(dz(i)) > 1e-2 && abs(zr(i)) < 1e-8
        erro_m(i) = 100;
    end
end
A = erro_m';
N  = medidores.num';
D  = medidores.de';
P  = medidores.para';
T = medidores.tipo';
PN = medidores.PMU_num';
ST = medidores.ok';
exa = medidores.acc';
fs = medidores.fs';
dp = medidores.dp';
MED = [N D P T PN ST exa fs dp zr zm A];
n_PMU = max(medidores.PMU_num);
med_PMU = 0;
med_SCADA = 0;
for i = 1 : Nmed
    if medidores.PMU_num(i) == 0
        med_SCADA = med_SCADA + 1;
    else
        med_PMU = med_PMU + 1;
    end
end
fprintf(fout, '--- TELEMEDIDAS ------------------------------------------------------------------\n');
fprintf(fout, '    Tipo 1 = Fluxo de potencia ativa        Tipo  6 = M�dulo da tens�o            \n');
fprintf(fout, '    Tipo 2 = Inje��o de potencia ativa      Tipo  7 = Corrente de ramo (real)     \n');
fprintf(fout, '    Tipo 3 = �ngulo de fase da tens�o       Tipo  8 = Corrente de ramo (imag)     \n');
fprintf(fout, '    Tipo 4 = Fluxo de potencia reativa      Tipo  9 = Inje��o de corrente (real)  \n');
fprintf(fout, '    Tipo 5 = Inje��o de potencia reativa    Tipo 10 = Inje��o de corrente (imag)  \n');
fprintf(fout, '----------------------------------------------------------------------------------\n');
fprintf(fout, '   N    D    P TP  PN ST   Exa   FS       DP      V_Ref      V_Med          E(%%) \n');
fprintf(fout, '----------------------------------------------------------------------------------\n');
relat = '%4d %4d %4d %2d %3d %2d %05.3f %04.1f %8.5f %+10.5f %+10.5f  %+12.6f \n';
for i = 1 : Nmed
   fprintf(fout,relat, MED(i,:));
end
fprintf(fout, '----------------------------------------------------------------------------------\n');
fprintf(fout, 'N�mero de medidores SCADA:     %d\n', med_SCADA);
fprintf(fout, 'N�mero de PMUs:                %d\n', n_PMU);
fprintf(fout, 'N�mero de medidas das PMUs:    %d\n', med_PMU);
fprintf(fout, '----------------------------------------------------------------------------------\n\n');
return