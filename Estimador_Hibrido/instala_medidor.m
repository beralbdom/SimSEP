function [medidores] = instala_medidor
%Instala medidor SCADA
%function [medidores] = instala_medidor(Barra, Ramo, medidores)
% 
% Estrutura de medidores
% num           nº do medidor
% de            nº da barra DE
% para          nº da barra PARA
% circ          nº do circuito
% tipo          tipo de medidor
% PMU_num       Medida associada a PMU n
% ok            Utiliza ou nao o medidor
% acc           exatidão do medidor
% fs            fundo de escala do medidor
% dp            desvio-padrão
% ref           valor de referencia
% leitura       valor medido
%
% Convençoes:
% - Medidas de fluxo de potencia ativa:     tipo 1
% - Medidas de injecao de potencia ativa:   tipo 2
% - Medidas de angulo:                      tipo 3
% - Medidas de fluxo de potencia reativa:   tipo 4
% - Medidas de injecao de potencia reativa: tipo 5
% - Medidas de tensao:                      tipo 6
% - Medidas de corrente de ramo real        tipo 7
% - Medidas de corrente de ramo imag        tipo 8
% - Medidas de injecao de corrente real     tipo 9
% - Medidas de injecao de corrente imag     tipo 10
% - Medidas de fluxo de 1 => 2   ---> de=1 e para=2
% - Medidas de tensao na barra 3 ---> de=0 e para=3
path('.\sub', path);
dft_s = 'S';
% dft_n = 'N';
sis_file = input('Arquivo de dados do sistema no formato IEEE CDF: ', 's');
[Caso, Barra, Ramo]=ler_sistema(sis_file);
med_file = input('Arquivo de dados dos medidores: ', 's');
if isempty(med_file);
    % Monta o plano de medicao
    medidores.num = [];
    medidores.de = [];
    medidores.para = [];
    medidores.circ = [];
    medidores.tipo = [];
    medidores.PMU_num = [];
    medidores.ok = [];
    medidores.acc = [];
    medidores.fs = [];
    medidores.dp = [];
    medidores.ref = [];
    medidores.leitura = [];
    Nmed = 0;
else
    [medidores, Nmed]=ler_medidores(med_file);
end
NB = size(Barra.num,1);
NL = size(Ramo.num,1);
disp('==================================================================================')
if isempty(medidores.num)
    NMed = 0;
else
    NMed = max(medidores.num);
end
val = ['1' '2' '4' '5' '6'];
msg = 'Entre com o número do tipo de medidor: ';
ent = false;
while ~ent 
    disp('Medida de fluxo de potência ativa:     tipo 1 ')
    disp('Medida de injeção de potência ativa:   tipo 2 ')
    disp('Medida de fluxo de potência reativa:   tipo 4 ')
    disp('Medida de injeção de potencia reativa: tipo 5 ')
    disp('Medida de módulo de tensão:            tipo 6 ')
    disp('----------------------------------------------------------------------------------')
    MED= input(msg, 's');
    if ismember(MED, val)
        ent = true;
    end
end
NMed=NMed+1;
% medidores de fluxo de potencia ativa e reativa
if (MED == '1' || MED == '4')
    medidores.num(NMed) = NMed;
    status = 0;
    while ~status 
        DE = input ('Entre com o número da Barra DE: ');
        status = barra_val(DE, Barra);
        if status == 0; disp ('Barra inválida!'); end
    end
    [vizinhas, nv] = barras_vizinhas (DE, Ramo);
    fprintf ('Barras vizinhas:');
    for i = 1 : nv
        fprintf (' %d', vizinhas(i));
    end
    fprintf ('\n');
    status = 0;
    while ~status
        PR = input ('Entre com o número da Barra PARA: ');
            if ismember(PR, vizinhas)
                status = 1;
            else
               disp ('Barra não vizinha!')
            end
    end
    CR = input ('Entre com o número do circuito [1]: ');
    if isempty(CR); CR = 1; end
    medidores.de(NMed) = DE;
    medidores.para(NMed) = PR;
    medidores.circ(NMed) = CR;
    if MED == '1'; medidores.tipo(NMed) = 1; end
    if MED == '4'; medidores.tipo(NMed) = 4; end
    medidores.PMU_num(NMed) = 0;
    medidores.ok(NMed) = 0;
    MED_P = input('Exatidão dos medidores de potência [0.02]?: ');
    if isempty(MED_P); MED_P = 0.02; end
    medidores.acc(NMed) = MED_P;
    P_FS = input('Fundo de escala dos medidores de potência [1]?: ');
    if isempty(P_FS); P_FS = 1; end
    medidores.fs(NMed) = P_FS;
    medidores.dp(NMed) = 0;
    medidores.ref(NMed) = 0;
    medidores.leitura(NMed) = 0;
end
% medidores de injeção de potencia ativa e reativa
if (MED == '2' || MED == '5' )
    medidores.num(NMed) = NMed;
    medidores.de(NMed) = 0;
    status = 0;
    while ~status 
        PR = input ('Entre com o número da Barra: ');
        status = barra_val(PR, Barra);
        if status == 0; disp ('Barra inválida!'); end
    end
    medidores.para(NMed) = PR;
    CR = input ('Entre com o número do circuito [1]: ');
    if isempty(CR); CR = 1; end
    medidores.circ(NMed) = CR;
    if MED == '2'; medidores.tipo(NMed) = 2; end
    if MED == '5'; medidores.tipo(NMed) = 5; end
    medidores.PMU_num(NMed) = 0;
    medidores.ok(NMed) = 0;
    MED_P = input('Exatidão dos medidores de potência [0.02]?: ');
    if isempty(MED_P); MED_P = 0.02; end
    medidores.acc(NMed) = MED_P;
    P_FS = input('Fundo de escala dos medidores de potência [1]?: ');
    if isempty(P_FS); P_FS = 1; end
    medidores.fs(NMed) = P_FS;
    medidores.dp(NMed) = 0;
    medidores.ref(NMed) = 0;
    medidores.leitura(NMed) = 0;
end
 if (MED == '6')
    medidores.num(NMed) = NMed;
    medidores.de(NMed) = 0;
    status = 0;
    while ~status 
        PR = input ('Entre com o número da Barra: ');
        status = barra_val(PR, Barra);
        if status == 0; disp ('Barra inválida!'); end
    end
    medidores.para(NMed) = PR;
    CR = input ('Entre com o número do circuito [1]: ');
    if isempty(CR); CR = 1; end
    medidores.circ(NMed) = CR;
    medidores.tipo(NMed) = 6;
    medidores.PMU_num(NMed) = 0;
    medidores.ok(NMed) = 0;
    MED_V = input('Exatidão do medidor de tensão [0.015]?: ');
    if isempty(MED_V); MED_V = 0.015; end
    medidores.acc(NMed) = MED_V;
    V_FS = input('Fundo de escala do medidor de tensao [1]?: ');
    if isempty(V_FS); V_FS = 1; end
    medidores.fs(NMed) = V_FS;
    medidores.dp(NMed) = 0;
    medidores.ref(NMed) = 0;
    medidores.leitura(NMed) = 0;
 end
[medidores] = ordena_med(medidores);
fprintf('Salvar medidores no arquivo: %s ', med_file);
rep = input('[S]/N?: ', 's');
if isempty(rep) || rep == 's' || rep == 'S'
    grava_arq_med(medidores, med_file);
elseif rep == 'n' || rep == 'N'
    med_file = input('Entre com o nome do arquivo de medidores: ', 's');
    grava_arq_med(medidores, med_file);
end
return