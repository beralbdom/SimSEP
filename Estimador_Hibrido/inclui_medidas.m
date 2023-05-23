function inclui_medidas
path('.\sub', path);
% Ler arquivo de medidores e calcula as medidas de referencia e aleatorias
disp('=============================== Inclui Medidas ===============================')
dft_s = 'S';
dft_n = 'N';
med_file = input('Arquivo de dados dos medidores: ', 's');
% Ler dados do arquivo de medidores
[medidores, Nmed]=ler_medidores(med_file);
% Leitura dos dados do sistema
sis_file = input('Arquivo de dados do sistema no formato IEEE CDF: ', 's');
[Caso, Barra, Ramo]=ler_sistema(sis_file);
NB = size(Barra.num,1);
% Monta Ybus
[Ybus, Yd, Yp] = Ybarra(Barra, Ramo);
% Lista de barras DE e PARA
d = Ramo.de;
p = Ramo.para;
% Tensões de Referência
V = Barra.tensao .* exp(j * Barra.angulo);
% Calcula as medidas de referencia do caso
msg = 'Calcula valores de referência [S]/N?: ';
rep = s_n(msg, dft_s);
if (rep == 's' || rep == 'S')
    disp('Calculando os valores de referencia!')
    medidores.ref = calc_medidas(Ybus, Yd, Yp, d, p, V, medidores);
else
    if isempty(medidores.ref)
        disp('Não há valores de referencia!')
        msg = 'Deseja calcular [S]/N?: ';
        rep = s_n(msg, dft_s);
        if (rep == 's' || rep == 'S')
            disp('Calculando os valores de referencia!')
            medidores.ref = calc_medidas(Ybus, Yd, Yp, d, p, V, medidores);
        end
    end
end
% Calcula medidas aleatorias
msg = 'Calcula medidas aleatórias [S]/N?: ';
rep = s_n(msg, dft_s);
if (rep == 's' || rep == 'S')
   %Calcula a variancia
    var = cal_var(medidores,medidores.ref);
    % Calcula medidas aleatoriamente, considerando a variancia
    medidores.leitura = normrnd(medidores.ref, var);
else
    disp('Medidas iguais aos valores de referencia!')
    medidores.leitura = medidores.ref;
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








