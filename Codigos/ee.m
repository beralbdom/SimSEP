function [V, Vref, conv,Ybus ] = ee(med_file, sis_file, tol_max, int_max, S_PESO, out_file, med_opt, DBG)
% Estima��o de estado - Newton-Raphson
% global Barra Ramo MVA_BASE Ybus Yd Yp H medidores
% med_file    => Arquivo com a estrutura de medidores e respectivas medidas
% sis_file    => Arquivo com os dados da rede, no formato IEEE CDF
% tol_max     => Diferen�a m�xima entre as tens�es em itera��es sucessivas
% int_max     => N�mero m�ximo de itera��es para converg�ncia
% S_PESO = 1  => Matriz de pesos formada pela covari�ncias das medidas
% S_PESO = 0  => Matriz de pesos formada por valores ajustados
% out_file    => Arquivo de sa�da
% med_opt = 0 => Tens�es de referencia do arquivo sis_file
%                Vari�ncias das telemedidas calculadas internamente
% med_opt = 1 => N�o utiliza tens�es de refer�ncia
%                Desvio-padr�o das telemedidas informado no arquivo med_file
% DBG         => Exterioriza alguns resultados parciais para debug
%% Configura o caminho para as subfun��es
path('.\sub', path);
%% Analisa os par�metros de entrada
if nargin < 8; DBG = 0; end
if nargin < 7; med_opt = 0; end
if nargin < 6
    titulo(1);
    out_file = input('Arquivo de sa�da: ', 's');
    if isempty(out_file); out_file = 'ee.out'; end
end
fout = fopen(out_file, 'w');
if nargin < 5, S_PESO = 1; end
if nargin < 4
    int_max = input('Numero maximo de itera�oes?: ');
end
if nargin < 3
    tol_max = input('Tolerancia maxima entre itera�oes?: ');
end
if nargin < 2
    sis_file = input('Arquivo de dados do sistema no formato IEEE CDF: ', 's');
end
if nargin < 1
    med_file = input('Arquivo de dados dos medidores: ', 's');
end
%% Exterioriza titulo e dados do caso na tela e no arquivo de sa�da
if nargin == 6
    titulo(1, med_file, sis_file, tol_max, int_max);
end
titulo(fout, med_file, sis_file, tol_max, int_max);
%% Leitura dos dados da rede
[Caso, Barra, Ramo] = ler_sistema(sis_file);
% Exterioriza dados do caso
%dados_caso(Caso);
dados_caso(Caso, fout);
% Vref = Valor das tensoes de referencia
%if med_opt == 0
    Vref = Barra.tensao .* exp(j * Barra.angulo);   
%end
% d = lista das barras DE dos ramos
d = Ramo.de;
% p = lista das barras PARA dos ramos
p = Ramo.para;
% Ybus = Matriz de admitancia da rede
% Yd = Matriz para calculo das correntes do terminal DE
% Yp = Matriz para calculo das correntes do terminal PARA
[Ybus, Yd, Yp] = Ybarra(Barra, Ramo);
%% Ler dados do arquivo de medidores
% Nmed = numero de medidores no arquivo med_file
[medidores, Nmed] = ler_medidores(med_file);
% Exterioriza as telemedidas
%out_med(medidores);
out_med(medidores, fout);
% zmt = valor das telemedidas
zmt = medidores.leitura';
%% Calcula variancia das telemedidas
if med_opt == 0     % Calcula a vari�ncia das telemedidas internamente
    VAR = cal_var(medidores,zmt);
    % Calcula o desvio-padr�o das telemedidas
    dp = VAR .^ 2;
%    dp(56)=0.0000537;dp(57)=dp(56);
    medidores.dp = dp;
    if S_PESO
        % Matriz de pesos formada com a covari�ncia das telemedidas
        peso = 1 ./ dp';
        disp('Matriz de pesos formada com as covari�ncias das telemedidas.')
        fprintf(fout, 'Matriz de pesos formada com as covari�ncias das telemedidas.\n');   
    else
        % Utiliza pesos ajustados
        peso = cal_peso(medidores);
        disp('Matriz de pesos formada com valores ajustados.')
        fprintf(fout, 'Matriz de pesos formada com valores ajustados.\n');   
    end
elseif med_opt == 1     % Desvio-padr�o das telemedidas informado no arquivo med_file
    VAR = medidores.dp;
    dp = VAR .^ 2;
    peso = 1 ./ dp';
end
% SALVA INFORMA��ES PARA ANALISE DE DESVIOS DAS MEDIDAS
% save dp; save peso; save VAR;
%% Inicia o processo de estima�ao
% ESTIMA = 0 => Encerra o processo de remo��o de erros grosseiros
ESTIMA = 1;
while ESTIMA
    %% Verifica se h� medidor de �ngulo desabilitado
    med_ang = find((medidores.tipo == 3) & (medidores.ok == 0));
    med_mod = find((medidores.tipo == 6) & (medidores.ok == 0) & (medidores.PMU_num > 0));
    if isempty(med_ang)
        Med_Ref = 0;
        %fprintf(1, 'N�o h� medidas de �ngulo.\n');
        fprintf(fout, 'N�o h� medidas de �ngulo.\n');
    else
        Med_Ref = 1;
        %fprintf(1, 'Medidas de �ngulo: \n');
        %fprintf(1, 'Barra: %d\n', medidores.para(med_ang));
        fprintf(fout, 'Medidas de �ngulo: \n');
        fprintf(fout, 'Barra: %d\n', medidores.para(med_ang));
    end
    %% Verifica quais medidores est�o desabilitados
    % n_ok = lista de medidores desabilitados
    n_ok = find (medidores.ok');
    %% Exterioriza os medidores desabilitados
    if isempty(n_ok)
        %fprintf(1,'N�o h� medidores desabilitados.\n');
        fprintf(fout,'N�o h� medidores desabilitados.\n');
    else
        %fprintf(1,'Medidores desabilitados:\n');
        %fprintf(1,'Medidor %d.\n', n_ok);
        fprintf(fout,'Medidores desabilitados:\n');
        fprintf(fout,'Medidor %d.\n', n_ok);
    end
    %% Exclui os medidores desabilitados
    % ind_med = lista dos medidores habilitados
    ind_med = dim_cut(Nmed, n_ok); 
    ind_med = ind_med';
    % zm = vetor com apenas os medidores habilitados 
    zm = zmt(ind_med,:);
    %% Inicializa o contador de itera�oes
    n_it = 0;
    %% Calcula matriz de pondera��o
    R = spdiags(dp', 0, Nmed, Nmed );
    % Reduz R para os medidores habilitados
    R = R(ind_med,ind_med);
    % W = Inverso da matriz de pondera��o
    W = spdiags( peso, 0, Nmed, Nmed );
    % Reduz W para os medidores habilitados
    W = W(ind_med, ind_med); 
    % V = vetor de tens�o nas barras
    V = ones(Caso.NB,1);   % Flat start
    % Transforma vetor de tensao em vetor estados [ANG(V):MOD(V)]
    x = V2x(V, Caso.NB, Caso.Bref, Med_Ref);
    %% Inicia o processo iterativo
    % Itera��o por Newton-Raphson
    conv = 0;   % Processo iterativo n�o convergido
    while (~conv && n_it < int_max)
        % Converte o vetor estado para vetor tensao
        V = x2V(x, Caso.NB, Caso.Bref);
        %% Calcula as telemedidas estimadas
        z = calc_medidas(Ybus, Yd, Yp, d, p, V, medidores);
        medidores.v_estimado = z';
        % Reduz o vetor de telemedidas estimadas para os medidores habilitados
        z = z(ind_med,:);
        %% Calculo do Jacobiano
        H = jacobiano(Ybus, Yd, Yp, d, p, V, Caso.Bref, Med_Ref, medidores);
        % Reduz o Jacobiano para os medidores habilitados
        H = H(ind_med,:);
        %% Calculo de Fx
        fx = H' * W * (zm - z);
        %% Calculo da matriz de ganho
        G = (H' * W * H);
        %% Calculo da inversa da matriz de ganho
        if DBG
            c = condest(G);
            fprintf(1,'Indice de condicionamento de G: %E \n', c)
        end
        G1 = inv(G);
        %% dx(k)
        deltax = G1 * fx;
        %% x(k+1) = x(k) + dx(k)
        x = x + deltax;
        %% Calcula o valor da toler�ncia
        tol = max(abs(deltax));
        if tol < tol_max;
            % finaliza o processo iterativo
            conv = 1;
        else
            % Incrementa o contador de itera��es e continua
            n_it = n_it + 1;
        end
    end
    %% Apresenta o valor final do estado
%    if med_opt
%        Vref = V;
%    end
    %mostra_estado(Barra.num, V, Vref, n_it, conv, med_opt);
    mostra_estado_2(Barra.num, V, Vref, n_it, conv, med_opt, fout);
    %% Calcula as medidas estimadas
    z = calc_medidas(Ybus, Yd, Yp, d, p, V, medidores);
    medidores.v_estimado = z';

    %% C�lculo do Desvio-Padr�o das telemedidas estimadas
    E_red = R - H * G1 * H';
    dpc = (diag(E_red).^ 0.5);
    dpc_ex = exp_vec(dpc, n_ok);
    E = exp_mat(E_red, n_ok);
    medidores.dpc = dpc_ex;
    medidores.residuo = medidores.leitura - medidores.v_estimado;
    lim_EG = 3;
    Tol_LB = 1e-6;
    [medidores, mc, EG, c_cand] = residuos_normalizados_1(medidores, lim_EG);
    %mostra_residuos(medidores, ind_med, 0, 1);
    mostra_residuos(medidores, ind_med, 0, fout);
    if EG ~= 0
        %fprintf(1,'Poss�vel erro grosseiro no medidor %d!\n', EG);
        fprintf(fout,'Poss�vel erro grosseiro no medidor %d!\n', EG);
    else
        %fprintf(1,'N�o foram identificados erros grosseiros.\n');
        fprintf(fout,'N�o foram identificados erros grosseiros.\n');
    end
    if isempty(mc)
        %fprintf(1,'N�o foram identificadas medidas cr�ticas.\n');
        fprintf(fout,'N�o foram identificadas medidas cr�ticas.\n');
    else
        %fprintf(1,'Medida cr�tica %4d!\n', mc);
        fprintf(fout,'Medida cr�tica %4d!\n', mc);
    end
    %% Mostra os poss�veis conjuntos cr�ticos
    [lins,cols] = size(c_cand);
    %fprintf(1,'Poss�veis conjuntos cr�ticos:\n');
    fprintf(fout,'Poss�veis conjuntos cr�ticos:\n');
    for i = 1 : lins
        %fprintf(1,'Conjunto %d:', i );
        fprintf(fout,'Conjunto %d:', i );
        nc = length(find(c_cand(i,:)));
        for k = 1 : nc
            %fprintf(1,' %d', c_cand(i,k));
            fprintf(fout,' %d', c_cand(i,k));
        end
        %fprintf(1,'\n');
        fprintf(fout,'\n');
    end
    %% Calcula a correla��o
    for l = 1 : lins
        nc = length(find(c_cand(l,:)));
        for i = 1 : nc
            for k = i : nc
                Eik = E(c_cand(l,i), c_cand(l,k));
                Eii = E(c_cand(l,i), c_cand(l,i));
                Ekk = E(c_cand(l,k), c_cand(l,k));
                LB(i,k) = abs(Eik)/(sqrt(Eii) * sqrt(Ekk));
                if LB(i,k) >= (1 - Tol_LB) && LB(i,k) <= (1 + Tol_LB) && i ~= k
                    % Medidas com alta correla��o
                    fprintf(1,'Medidas com alta correla��o: %d e %d \n', c_cand(l,i), c_cand(l,k));
                    fprintf(fout,'Medidas com alta correla��o: %d e %d \n', c_cand(l,i), c_cand(l,k));
                end
            end
        end 
    end
%    save E;    save R; save G1;
%    save E_red;    save LB;     
%    save H;
    %% Altera o plano de medi��o
    %rep = input('Alterar plano de medi��o: S/P [N]?: ', 's');
    rep = 'N';
    if isempty(rep); rep = 'N'; end
    if (rep == 's'|| rep == 'S')
        rep = input('Habilita ou desabilita medidor? H/D [N]?: ', 's');
        if isempty(rep); rep = 'N'; end
        if (rep == 'd'|| rep == 'D')
            exclui = input('Numero do medidor a ser desabilitado?: ');
            medidores.ok(exclui)=1;
        elseif (rep == 'h' || rep =='H')
            inclui = input('Numero do medidor a ser habilitado?: ');
            medidores.ok(inclui)=0;
        elseif (rep == 'n' || rep =='N')
        end
    elseif (rep == 'p' || rep == 'P')
        rep = input('Habilita ou desabilita PMU? H/D [N]?: ', 's');
        if isempty(rep); rep = 'N'; end
        if (rep == 'd'|| rep == 'D')
            PMU_num = input('Numero da PMU a ser desabilitada?: ');
            for i = 1: Nmed
                if medidores.PMU_num(i) == PMU_num
                    medidores.ok(i) = 1;
                end
            end
        elseif (rep == 'h'|| rep == 'H')
            PMU_num = input('Numero da PMU a ser habilitada?: ');
            for i = 1: Nmed
                if medidores.PMU_num(i) == PMU_num
                    medidores.ok(i) = 0;
                end
            end
        elseif (rep == 'n' || rep =='N')
        end   
    elseif (rep == 'n' || rep == 'N')
        ESTIMA = 0;
    end
end
fclose(fout);
% save medidores;
% rep = input('Deseja salvar configuracao de medidores S/[N]?: ', 's');
% if isempty(rep); rep = 'N'; end
% if (rep == 's'|| rep == 'S')
%     grava_arq_med(medidores, med_file);
% end
% msg = 'Deseja plotar os resultados S/[N]?: ';
% rep = s_n(msg, 'N');
% if (rep == 's'|| rep == 'S')
%     if med_opt
%         %% plota os res�duos normalizados
%         subplot(1,1,1), plot(medidores.rn,'*'), title('RN (pu)');
%     else
%         nr = length(medidores.residuo);
%         % prepara para plotar os res�duos normalizados
%         for i = 1 : nr
%             if medidores.rn(i) >= 4
%                 RN(i) = 4;
%             else
%                 RN(i) = medidores.rn(i);
%             end
%         end
%         % Plota a diferenca do estado real para o estado estimado
%         EA=100*(abs(V)- Barra.tensao)/Barra.tensao;
%         EF=60*180/pi*(Barra.angulo-angle(V));
%         createfigure(EA, EF, RN);
% %         subplot(3,1,1), plot(EA,'+'), title('Erro de Amplitude (%)');
% %         subplot(3,1,2), plot(EF,'+'), title('Erro de Fase (min)');
% %         subplot(3,1,3), plot(medidores.rn,'*'), title('RN (pu)');
%     end
% else
%     return
% end