function instala_PMU
%Instala PMU
%function [medidores] = inst_PMU(Barra, Ramo, medidores, PRR, Bn, var_mod, var_ang, opt)
% PMU -> Modulo e angulo da tensao, correntes de ramos e injecoes
% Barra     Dados das barras
% Ramo      Dados dos ramos
% Medidores Dados dos medidores
% var_mod   Variância da medida de magnitude da PMU
% var_ang   Variância da medida de ângulo da PMU
% PRR       Taxa de fasores por segundo da PMU
% opt       Seleção das medidas incluidas na PMU
%           opt = 0   Mede tensao e angulo da tensao
%           opt = 1   Mede tensao e correntes
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
per_SCADA = input('Tempo de varredura do sistemas SCADA [1 s]?: ');
if isempty(per_SCADA); per_SCADA = 1; end
PRR = input('Taxa de exteriorização de fasores [1 fasor/s]?: ');
if isempty(PRR); PRR = 1; end
% Calcula o número de medidas das PMUs a ser incluido na estimação
tef = per_SCADA * PRR;
exa_mag = input('Exatidão da magnitude das grandezas [0.01 %]?: ');
if isempty(exa_mag); exa_mag = 0.01; end
exa_ang = input('Exatidão do ângulo de fase [0.02 graus]?: ');
if isempty(exa_ang); exa_ang = 0.02; end
msg = 'Mede as correntes [S]/N?: ';
rep = s_n(msg, dft_s);
if isempty(rep); rep = 'S'; end
if rep =='S'|| rep == 's'
    opt = 1;
else
    opt = 0;
end

if Nmed == 0;
    PMU_num = 0;
else
    PMU_num = max(medidores.PMU_num);
end
INSTALA = 1;
PMUs_Instaladas = [];
PMU_ind = 0;
while INSTALA
    % Instala PMU na Barra Bn
    status = 0;
    while ~status
        Bn = input('Numero da barra?: ');
        status = barra_val(Bn, Barra);
        if status == 0; disp ('Barra inválida!'); end
    end
    PMU_num = PMU_num + 1;
    Nramos = length(Ramo.de);

    for i = 1 : tef
        %Medida de angulo da PMU
        Nmed = Nmed + 1;
        medidores.num(Nmed) = Nmed;
        medidores.de(Nmed) = 0;
        medidores.para(Nmed) = Bn;
        medidores.circ(Nmed) = 1;
        medidores.tipo(Nmed) = 3;
        medidores.PMU_num(Nmed) = PMU_num;
        medidores.ok(Nmed) = 0;
        medidores.acc(Nmed) = exa_ang;
        medidores.fs(Nmed) = 1;
        medidores.dp(Nmed) = 0;
        medidores.ref(Nmed) = 0;
        medidores.leitura(Nmed) = 0;

        %Medida de tensao da PMU
        Nmed = Nmed + 1;
        medidores.num(Nmed) = Nmed;
        medidores.de(Nmed) = 0;
        medidores.para(Nmed) = Bn;
        medidores.circ(Nmed) = 1;
        medidores.tipo(Nmed) = 6;
        medidores.PMU_num(Nmed) = PMU_num;
        medidores.ok(Nmed) = 0;
        medidores.acc(Nmed) = exa_mag;
        medidores.fs(Nmed) = 1;
        medidores.dp(Nmed) = 0;
        medidores.ref(Nmed) = 0;
        medidores.leitura(Nmed) = 0;
        if opt
            % Medida de injecao de corrente real da PMU
            Nmed = Nmed + 1;
            medidores.num(Nmed) = Nmed;
            medidores.de(Nmed) = 0;
            medidores.para(Nmed) = Bn;
            medidores.circ(Nmed) = 1;
            medidores.tipo(Nmed) = 9;
            medidores.PMU_num(Nmed) = PMU_num;
            medidores.ok(Nmed) = 0;
            medidores.acc(Nmed) = exa_mag;
            medidores.fs(Nmed) = 1;
            medidores.dp(Nmed) = 0;
            medidores.ref(Nmed) = 0;
            medidores.leitura(Nmed) =  0;

            % Medida de injecao de corrente imag da PMU
            Nmed = Nmed + 1;
            medidores.num(Nmed) = Nmed;
            medidores.de(Nmed) = 0;
            medidores.para(Nmed) = Bn;
            medidores.circ(Nmed) = 1;
            medidores.tipo(Nmed) = 10;
            medidores.PMU_num(Nmed) = PMU_num;
            medidores.ok(Nmed) = 0;
            medidores.acc(Nmed) = exa_mag;
            medidores.fs(Nmed) = 1;
            medidores.dp(Nmed) = 0;
            medidores.ref(Nmed) = 0;
            medidores.leitura(Nmed) = 0;

            % Medidas de corrente de ramo real
            for k = 1 : Nramos
                if Ramo.de(k) == Bn
                    Nmed = Nmed + 1;
                    medidores.num(Nmed) = Nmed;
                    medidores.de(Nmed) = Ramo.de(k);
                    medidores.para(Nmed) = Ramo.para(k);
                    medidores.circ(Nmed) = Ramo.circuito(k);
                    medidores.tipo(Nmed) = 7;
                    medidores.PMU_num(Nmed) = PMU_num;
                    medidores.ok(Nmed) = 0;
                    medidores.acc(Nmed) = exa_mag;
                    medidores.fs(Nmed) = 1;
                    medidores.dp(Nmed) = 0;
                    medidores.ref(Nmed) = 0;
                    medidores.leitura(Nmed) = 0;
                elseif Ramo.para(k) == Bn
                    Nmed = Nmed + 1;
                    medidores.num(Nmed) = Nmed;
                    medidores.de(Nmed) = Ramo.para(k);
                    medidores.para(Nmed) = Ramo.de(k);
                    medidores.circ(Nmed) = Ramo.circuito(k);
                    medidores.tipo(Nmed) = 7;
                    medidores.PMU_num(Nmed) = PMU_num;
                    medidores.ok(Nmed) = 0;
                    medidores.acc(Nmed) = exa_mag;
                    medidores.fs(Nmed) = 1;
                    medidores.dp(Nmed) = 0;
                    medidores.ref(Nmed) = 0;
                    medidores.leitura(Nmed) = 0;
                end
            end

            % Medidas de corrente de ramo imag
            for k = 1 : Nramos
                if Ramo.de(k) == Bn
                    Nmed = Nmed + 1;
                    medidores.num(Nmed) = Nmed;
                    medidores.de(Nmed) = Ramo.de(k);
                    medidores.para(Nmed) = Ramo.para(k);
                    medidores.circ(Nmed) = Ramo.circuito(k);
                    medidores.tipo(Nmed) = 8;
                    medidores.PMU_num(Nmed) = PMU_num;
                    medidores.ok(Nmed) = 0;
                    medidores.acc(Nmed) = exa_mag;
                    medidores.fs(Nmed) = 1;
                    medidores.dp(Nmed) = 0;
                    medidores.ref(Nmed) = 0;
                    medidores.leitura(Nmed) = 0;
                elseif Ramo.para(k) == Bn
                    Nmed = Nmed + 1;
                    medidores.num(Nmed) = Nmed;
                    medidores.de(Nmed) = Ramo.para(k);
                    medidores.para(Nmed) = Ramo.de(k);
                    medidores.circ(Nmed) = Ramo.circuito(k);
                    medidores.tipo(Nmed) = 8;
                    medidores.PMU_num(Nmed) = PMU_num;
                    medidores.ok(Nmed) = 0;
                    medidores.acc(Nmed) = exa_mag;
                    medidores.fs(Nmed) = 1;
                    medidores.dp(Nmed) = 0;
                    medidores.ref(Nmed) = 0;
                    medidores.leitura(Nmed) = 0;
               end
            end
        end
    end
    PMU_ind = PMU_ind + 1;
    PMUs_Instaladas(PMU_ind) = PMU_num;
    msg = 'Instala outra PMU [S]/N?: ';
    rep = s_n(msg, dft_s);
    if isempty(rep); rep = 'S'; end
    if rep == 'N' || rep == 'n'
        INSTALA = 0;
    end
end
% gera as medidas para as PMUs instaladas
msg = 'Calcula as medidas [S]/N?: ';
rep = s_n(msg, dft_s);
if (rep == 's' || rep == 'S')
    % Monta Ybus
   [Ybus, Yd, Yp] = Ybarra(Caso.MVA, Barra, Ramo);
    % Calcula os valores de referencia das medidas
    d = Ramo.de;
    p = Ramo.para;
    V = Barra.tensao .* exp(j * Barra.angulo);
    med_ref = calc_medidas(Ybus, Yd, Yp, d, p, V, medidores);
    var = cal_var(medidores,med_ref);
    % Calcula medidas aleatoriamente, considerando a variancia
    med_leitura = normrnd(med_ref, var);
    for i = 1 : PMU_ind
        for k = 1 : Nmed
            if medidores.PMU_num(k) == PMUs_Instaladas(i);
                medidores.ref(k) = med_ref(k);
                medidores.leitura(k) = med_leitura(k);
            end
        end
    end
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
