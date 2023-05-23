function [medidores] = gera_medidores
%Monta estrutura de medidores
%function [medidores] = gera_medidores
%
% Controle: 0 ou 1
% PMU -> Modulo e angulo da tensao, correntes de ramos e injecoes
% TEN -> Modulo de tensao
% FPA -> Fluxo de Potencia Ativa
% FPR -> Fluxo de Potencia Reativa
% IPA -> Injecao de Potencia Ativa
% IPR -> Injecao de Potencia Reativa

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
% Monta estrutura de medidores
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

% Variáveis default
dft_s = 'S';
dft_n = 'N';
% Leitura dos dados do sistema
sis_file = input('Arquivo de dados do sistema no formato IEEE CDF: ', 's');
[Caso, Barra, Ramo]=ler_sistema(sis_file);

while 1
    msg = 'Fluxo de potência ativa [S]/n?: ';
    resposta = s_n(msg, dft_s);
    if (resposta == 's'|| resposta == 'S')
        FPA = 1;
    else
        FPA = 0;
    end
    msg = 'Fluxo de potência reativa? [S]/n?: ';
    resposta = s_n(msg, dft_s);
    if (resposta == 's'|| resposta == 'S')
        FPR = 1;
    else
        FPR = 0;
    end
    msg = 'Injeção de potência ativa? [S]/n?: ';
    resposta = s_n(msg, dft_s);
    if (resposta == 's'|| resposta == 'S')
        IPA = 1;
    else
        IPA = 0;
    end
    msg = 'Injeção de potência reativa? [S]/n?: ';
    resposta = s_n(msg, dft_s);
    if (resposta == 's'|| resposta == 'S')
        IPR = 1;
    else
        IPR = 0;
    end
    if (FPA || FPR || IPA || IPR) 
        % Exatidao e fundo de escala dos medidores de potencia
        MED_P = input('Exatidao dos medidores de potencia [0.02]?: ');
        if isempty(MED_P); MED_P = 0.02; end
        P_FS = input('Fundo de escala dos medidores de potencia [2]?: ');
        if isempty(P_FS); P_FS = 2; end
    end
    % Medidores de modulo de tensao
    msg = 'Módulo de tensão [S]/n?: ';
    resposta = s_n(msg, dft_s);
    if (resposta == 's'|| resposta == 'S')
        TEN = 1;
        MED_V = input('Exatidao dos medidores de tensao [0.015]?: ');
        if isempty(MED_V); MED_V = 0.015; end
        V_FS = input('Fundo de escala dos medidores de tensao [1.1]?: ');
        if isempty(V_FS); V_FS = 1.1; end
    else
        TEN=0;
    end
    % Corrigir os dados?
    msg = 'Deseja corrigir os dados S/[N]?: ';
    resposta = s_n(msg, dft_n);
    if (resposta == 'n'|| resposta == 'N'); break; end
end
NB = size(Barra.num,1);
NL = size(Ramo.num,1);
NMed = 0;
% medidores de fluxo de potencia ativa
if FPA
    for i = 1 : NL
        % Fluxo de potencia ativa de -> para
        NMed = NMed + 1;
        medidores.num(NMed) = NMed;
        medidores.de(NMed) = Ramo.de(i);
        medidores.para(NMed) = Ramo.para(i);
        medidores.circ(NMed) = Ramo.circuito(i);
        medidores.tipo(NMed) = 1;
        medidores.PMU_num(NMed)=0;
        medidores.ok(NMed)=0;
        medidores.acc(NMed) = MED_P;
        medidores.fs(NMed) = P_FS;
        medidores.dp(NMed) = 0;
        medidores.ref(NMed) = 0;
        medidores.leitura(NMed) = 0;
        % Fluxo de potencia ativa para -> de
        NMed = NMed + 1;
        medidores.num(NMed) = NMed;
        medidores.de(NMed) = Ramo.para(i);
        medidores.para(NMed) = Ramo.de(i);
        medidores.circ(NMed) = Ramo.circuito(i);
        medidores.tipo(NMed) = 1;
        medidores.PMU_num(NMed) = 0;
        medidores.ok(NMed) = 0;
        medidores.acc(NMed) = MED_P;
        medidores.fs(NMed) = P_FS;
        medidores.dp(NMed) = 0;
        medidores.ref(NMed) = 0;
        medidores.leitura(NMed) = 0;
     end
end 
%medidores de injecao de potencia ativa
if IPA
    for i = 1 : NB
        NMed = NMed + 1;
        medidores.num(NMed) = NMed;
        medidores.de(NMed) = 0;
        medidores.para(NMed) = Barra.num(i);
        medidores.circ(NMed) = 1;
        medidores.tipo(NMed) = 2;
        medidores.PMU_num(NMed) = 0;
        medidores.ok(NMed) = 0;      
        medidores.acc(NMed) = MED_P;
        medidores.fs(NMed) = P_FS;
        medidores.dp(NMed) = 0;
        medidores.ref(NMed) = 0;
        medidores.leitura(NMed) = 0;
    end
end
%medidores de fluxo de potencia reativa
if FPR
    for i = 1 : NL
        % Fluxo de potencia reativa de -> para
        NMed = NMed + 1;
        medidores.num(NMed) = NMed;
        medidores.de(NMed) = Ramo.de(i);
        medidores.para(NMed) = Ramo.para(i);
        medidores.circ(NMed) = Ramo.circuito(i);
        medidores.tipo(NMed) = 4;
        medidores.PMU_num(NMed) = 0;
        medidores.ok(NMed) = 0;
        medidores.acc(NMed) = MED_P;
        medidores.fs(NMed) = P_FS;
        medidores.dp(NMed) = 0;
        medidores.ref(NMed) = 0;
        medidores.leitura(NMed) = 0;
        % Fluxo de potencia reativa para -> de
        NMed = NMed + 1;
        medidores.num(NMed) = NMed;
        medidores.de(NMed) = Ramo.para(i);
        medidores.para(NMed) = Ramo.de(i);
        medidores.circ(NMed) = Ramo.circuito(i);
        medidores.tipo(NMed) = 4;
        medidores.PMU_num(NMed) = 0;
        medidores.ok(NMed) = 0;
        medidores.acc(NMed) = MED_P;
        medidores.fs(NMed) = P_FS;
        medidores.dp(NMed) = 0;
        medidores.ref(NMed) = 0;
        medidores.leitura(NMed) = 0;
    end
end 
%medidores de injecao de potencia reativa
if IPR
    for i = 1 : NB
        NMed = NMed + 1;
        medidores.num(NMed) = NMed;
        medidores.de(NMed) = 0;
        medidores.para(NMed) = Barra.num(i);
        medidores.circ(NMed) = 1;
        medidores.tipo(NMed) = 5;
        medidores.PMU_num(NMed) = 0;
        medidores.ok(NMed) = 0;
        medidores.acc(NMed) = MED_P;
        medidores.fs(NMed) = P_FS;
        medidores.dp(NMed) = 0;
        medidores.ref(NMed) = 0;
        medidores.leitura(NMed) = 0;
    end
end
%medidores de tensao
if TEN
    for i = 1 : NB
        NMed = NMed + 1;
        medidores.num(NMed) = NMed;
        medidores.de(NMed) = 0;
        medidores.para(NMed) = Barra.num(i);
        medidores.circ(NMed) = 1;
        medidores.tipo(NMed) = 6;
        medidores.PMU_num(NMed) = 0;
        medidores.ok(NMed) = 0;
        medidores.acc(NMed) = MED_V;
        medidores.fs(NMed) = V_FS;
        medidores.dp(NMed) = 0; 
        medidores.ref(NMed) = 0;
        medidores.leitura(NMed) = 0;
    end
end
med_file = input('Entre com o arquivo de medidores: ', 's');
grava_arq_med(medidores, med_file);
return