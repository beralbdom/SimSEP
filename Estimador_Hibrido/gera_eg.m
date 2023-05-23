function gera_eg
% Gera Erros Grosseiros em medidas 
%function gera_eg
% 
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
%
% Conven�oes:
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
true = 1;
false = 0;
% dft_s = 'S';
% dft_n = 'N';
disp('==================================================================================')
med_file = input('Arquivo de dados dos medidores: ', 's');
if isempty(med_file);
    fprintf('N�o existem medidores neste arquivo!');
    return
else
    [medidores, Nmed]=ler_medidores(med_file);
end
CON = false;
while ~CON
    [dp] = cal_var(medidores,medidores.leitura);
    medidores.dp = dp';
    out_med(medidores);
    medidores_2 = medidores;
    ENT = false;
    while ~ENT
        MED = input('N�mero do medidor: ');
        if MED >= 1 && MED <= Nmed
        disp('----------------------------------------------------------------------------------')
            switch medidores.tipo(MED)
                case 1
                    fprintf('Medida de fluxo de pot�ncia ativa de %d para %d - circuito %d \n', medidores.de(MED),medidores.para(MED), medidores.circ(MED));
                    fprintf('Valor de refer�ncia: %+10.5f \n',medidores.ref(MED));
                    fprintf('Valor da leitura:    %+10.5f \n',medidores.leitura(MED));
                    fprintf('Exatid�o: %+10.4f - Fundo de Escala: %+10.4f \n', medidores.acc(MED), medidores.fs(MED));
                    fprintf('Desvio-padr�o: %d \n', medidores.dp(MED));

                case 2
                    fprintf('Medida de inje��o de pot�ncia ativa na Barra %d - circuito %d \n', medidores.para(MED), medidores.circ(MED));
                    fprintf('Valor de refer�ncia: %+10.5f \n',medidores.ref(MED));
                    fprintf('Valor da leitura:    %+10.5f \n',medidores.leitura(MED));
                    fprintf('Exatid�o: %+10.4f - Fundo de Escala: %+10.4f \n', medidores.acc(MED), medidores.fs(MED));
                    fprintf('Desvio-padr�o: %d \n', medidores.dp(MED));

                case 3
                    fprintf('PMU: %d \n', medidores.PMU_num(MED));
                    fprintf('Medida de �ngulo de fase da tens�o na Barra %d - circuito %d \n', medidores.para(MED), medidores.circ(MED));
                    fprintf('Valor de refer�ncia: %+10.5f \n',medidores.ref(MED));
                    fprintf('Valor da leitura:    %+10.5f \n',medidores.leitura(MED));
                    fprintf('Exatid�o: %+10.4f - Fundo de Escala: %+10.4f \n', medidores.acc(MED), medidores.fs(MED));
                    fprintf('Desvio-padr�o: %d \n', medidores.dp(MED));

                case 4
                    fprintf('Medida de fluxo de pot�ncia reativa de %d para %d - circuito %d \n', medidores.de(MED),medidores.para(MED), medidores.circ(MED));
                    fprintf('Valor de refer�ncia: %+10.5f \n',medidores.ref(MED));
                    fprintf('Valor da leitura:    %+10.5f \n',medidores.leitura(MED));
                    fprintf('Exatid�o: %+10.4f - Fundo de Escala: %+10.4f \n', medidores.acc(MED), medidores.fs(MED));
                    fprintf('Desvio-padr�o: %d \n', medidores.dp(MED));

                case 5
                    fprintf('Medida de inje��o de pot�ncia reativa na Barra %d - circuito %d \n', medidores.para(MED), medidores.circ(MED));
                    fprintf('Valor de refer�ncia: %+10.5f \n',medidores.ref(MED));
                    fprintf('Valor da leitura:    %+10.5f \n',medidores.leitura(MED));
                    fprintf('Exatid�o: %+10.4f - Fundo de Escala: %+10.4f \n', medidores.acc(MED), medidores.fs(MED));
                    fprintf('Desvio-padr�o: %d \n', medidores.dp(MED));
                case 6
                    if medidores.PMU_num(MED) ~= 0
                        fprintf('PMU: %d \n', medidores.PMU_num(MED));
                    end 
                    fprintf('Medida de m�dulo de tens�o na Barra %d - circuito %d \n', medidores.para(MED), medidores.circ(MED));
                    fprintf('Valor de refer�ncia: %+10.5f \n',medidores.ref(MED));
                    fprintf('Valor da leitura:    %+10.5f \n',medidores.leitura(MED));
                    fprintf('Exatid�o: %+10.4f - Fundo de Escala: %+10.4f \n', medidores.acc(MED), medidores.fs(MED));
                    fprintf('Desvio-padr�o: %d \n', medidores.dp(MED));
                case 7
                    fprintf('PMU: %d \n', medidores.PMU_num(MED));
                    fprintf('Medida de corrente de ramo real de %d para %d - circuito %d \n', medidores.de(MED),medidores.para(MED), medidores.circ(MED));
                    fprintf('Valor de refer�ncia: %+10.5f \n',medidores.ref(MED));
                    fprintf('Valor da leitura:    %+10.5f \n',medidores.leitura(MED));
                    fprintf('Exatid�o: %+10.4f - Fundo de Escala: %+10.4f \n', medidores.acc(MED), medidores.fs(MED));
                    fprintf('Desvio-padr�o: %d \n', medidores.dp(MED));
                case 8
                    fprintf('PMU: %d \n', medidores.PMU_num(MED));
                    fprintf('Medida de corrente de ramo imagin�ria de %d para %d - circuito %d \n', medidores.de(MED),medidores.para(MED), medidores.circ(MED));
                    fprintf('Valor de refer�ncia: %+10.5f \n',medidores.ref(MED));
                    fprintf('Valor da leitura:    %+10.5f \n',medidores.leitura(MED));
                    fprintf('Exatid�o: %+10.4f - Fundo de Escala: %+10.4f \n', medidores.acc(MED), medidores.fs(MED));
                    fprintf('Desvio-padr�o: %d \n', medidores.dp(MED));
                case 9
                    fprintf('PMU: %d \n', medidores.PMU_num(MED));
                    fprintf('Medida de inje��o de corrente real na Barra %d - circuito %d \n', medidores.para(MED), medidores.circ(MED));
                    fprintf('Valor de refer�ncia: %+10.5f \n',medidores.ref(MED));
                    fprintf('Valor da leitura:    %+10.5f \n',medidores.leitura(MED));
                    fprintf('Exatid�o: %+10.4f - Fundo de Escala: %+10.4f \n', medidores.acc(MED), medidores.fs(MED));
                    fprintf('Desvio-padr�o: %d \n', medidores.dp(MED));
                case 10
                    fprintf('PMU: %d \n', medidores.PMU_num(MED));
                    fprintf('Medida de inje��o de corrente imagin�ria na Barra %d - circuito %d \n', medidores.para(MED), medidores.circ(MED));
                    fprintf('Valor de refer�ncia: %+10.5f \n',medidores.ref(MED));
                    fprintf('Valor da leitura:    %+10.5f \n',medidores.leitura(MED));
                    fprintf('Exatid�o: %+10.4f - Fundo de Escala: %+10.4f \n', medidores.acc(MED), medidores.fs(MED));
                    fprintf('Desvio-padr�o: %d \n', medidores.dp(MED));
            end
            disp('----------------------------------------------------------------------------------')
            if medidores.ok(MED) == 1
                fprintf('Medidor desabilitado! \n')
                rep = input('Deseja habilitar [S]/n?: ', 's');
                rep = lower(rep);
                if isempty(rep) || rep == 's'
                    medidores_2.ok(MED) = 0;
                elseif rep == 'n'
                    ENT = false;
                end
            end
            rep = input('Incluir erro neste medidor [S]/n?: ', 's');
            rep = lower(rep);
            if isempty(rep) || rep == 's'
                TE = false;
                while ~TE
                    tipo = input('Tipo de erro: [P]ercentual da medida, [M]�ltiplo do Desvio-Padr�o ou [I]nvers�o?: ', 's');
                    switch lower(tipo)
                        case 'p'
                                ERRO_P = input('Percentual de erro [+50%]?: ');
                                if isempty(ERRO_P); ERRO_P = 50; end
                                medidores_2.leitura(MED)= medidores.ref(MED)*(1+ERRO_P/100);
                                fprintf('Valor da leitura com erro: %+10.5f \n',medidores_2.leitura(MED));
                                TE = true;                                               
                        case 'm'
                                ERRO_P = input('M�ltiplo do desvio-padr�o [+4]?: ');
                                if isempty(ERRO_P); ERRO_P = 4; end
                                medidores_2.leitura(MED)= medidores.ref(MED)+ERRO_P*medidores.dp(MED);
                                fprintf('Valor da leitura com erro: %+10.5f \n',medidores_2.leitura(MED));
                                TE = true;
                        case 'i'
                                medidores_2.leitura(MED)= -medidores.leitura(MED);
                                fprintf('Valor da leitura com erro: %+10.5f \n',medidores_2.leitura(MED));
                                TE = true;
                        otherwise
                                TE = false;
                    end
                end
                disp('----------------------------------------------------------------------------------')
                rep = input('Confirma inclus�o deste erro [S]/n?: ', 's');
                rep = lower(rep);
                if isempty(rep) || rep == 's'
                    ENT = true;
                    MOD = true;
                else
                    ENT = false;
                    MOD = false;
                end
             end
        else
            fprintf('Medidor %d inexistente! \n',MED);
            rep = input('Deseja continuar [S]/n?: ', 's');
                rep = lower(rep);
                if isempty(rep) || rep == 's'
                    ENT = false;
                    MOD = false;
                else
                    return
                end
        end
    end
    if MOD
        med_file_2 = med_file;
        fprintf('Salvar medidores no arquivo: %s \n', med_file_2);
        rep = input('Confirma s/[N] ?: ', 's');
        rep = lower(rep);
        if isempty(rep) || rep == 'n'  
            med_file_2 = input('Entre com o nome do arquivo de medidores: ', 's');
            grava_arq_med(medidores_2, med_file_2);
        elseif rep == 's'
            grava_arq_med(medidores_2, med_file_2);
        end
    end
    rep = input('Deseja continuar [S]/n?: ', 's');
    rep = lower(rep);
    if isempty(rep) || rep == 's'
        CON = false;
    else
        return
    end
end
