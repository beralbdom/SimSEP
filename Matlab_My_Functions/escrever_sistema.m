function [Caso, Barra, Ramo]=escrever_sistema(sis_file)
% Escrever arquivo de dados no formato IEEE Common Data Format.
%
% escrever_sistema              -> Solicita o nome do arquivo de dados
% escrever_sistema(cdf_file)    -> Utiliza o arquivo especificado
% 
% Define a estrutura dos dados das barra
Barra.num = [];
Barra.nome = {};
Barra.area = [];
Barra.zona = [];
Barra.tipo = [];
Barra.tensao = [];
Barra.angulo = [];
Barra.carga_MW = [];
Barra.carga_MVAR = [];
Barra.ger_MW = [];
Barra.ger_MVAR = [];
Barra.kVBase = [];
Barra.tensao_inic = [];
Barra.lim_max = [];
Barra.lim_min = [];
Barra.g = [];
Barra.b = [];
Barra.ctrl_rem = [];
Barra.P = [];
Barra.Q = [];
Barra.inj_P = [];
Barra.inj_Q = [];
Barra.estado_mod = [];
Barra.estado_ang = [];

Barra.T = []; % Inclui essa linha para que o programa possa ler as potências aparente das barras em kVA (ex: 132 kVA)


% Define a estrutura dos dados dos ramos
Ramo.num = [];
Ramo.de = [];
Ramo.para = [];
Ramo.area = [];
Ramo.zona = [];
Ramo.circuito = [];
Ramo.tipo = [];
Ramo.r = [];
Ramo.x = [];
Ramo.b = [];
Ramo.rat_1 = [];
Ramo.rat_2 = [];
Ramo.rat_3 = [];
Ramo.barra_ctrl = [];
Ramo.lado = [];
Ramo.rel_tr = [];
Ramo.ang_tr = [];
Ramo.tap_min = [];
Ramo.tap_max = [];
Ramo.step = [];
Ramo.lim_min = [];
Ramo.lim_max = [];
Ramo.P_para = [];
Ramo.Q_para = [];
Ramo.P_de = [];
Ramo.Q_de = [];
Ramo.status = [];

% Define a estrutura do caso
if nargin < 1
    sis_file = input('Entre com o nome do arquivo no formato IEEE CDF:', 's');
end

% Abre o arquivo para leitura
fid = fopen(sis_file, 'r');

% Le e apresentar titulo do caso
while 1
    % Le a primeira linha do arquivo
    tline = fgetl(fid);
    % Se encontrar 'TAPE' le mais uma linha
    if findstr(tline,'TAPE');tline = fgetl(fid);end
    % Verifica se esta e a linha de titulo
    CASE_DATE=tline(2:9);
    if length(findstr(CASE_DATE,'/'))==2
        if length(tline) >= 30
            CASE_SENDER=tline(11:30);
        end
        if length(tline) >= 37
            MVA_BASE=str2double(tline(32:37));
        end
        if length(tline) >= 42
            YEAR=str2double(tline(39:42));
        end
        if length(tline) >= 44
            SEASON=tline(44);
        end
        if length(tline) >= 46
            CASE_IDENT=tline(46:length(tline));
        end
        break;
    end
end

% Procura a frase 'BUS DATA FOLLOWS'
while 1 
    tline = fgetl(fid);
    if  strcmp(tline(1:16), 'BUS DATA FOLLOWS'), break, end
end


% ---------------------------------------------------------------------- %
% Início da programação para ESCREVER do matlab para o aquivo "ieee14.cdf"
% ---------------------------------------------------------------------- %

NB = 14;
val_Barra.carga_MW = '%4d \r\n';
out_file = input('Nome do arquivo:','s');
fout = fopen(out_file,'w');
for ii = 1:NB;
    for jj = 1:24;
    fprintf(fout,val_Barra.carga_MW, matriz_aux(ii,jj));
    end
end


n_ref = 0;
ibus = 0;
while 1
    tline = fgetl(fid);
    % Conclui se encontra o fim do bloco
    if  strcmp(tline(1:4), '-999'), break, end   % "strcmp" compara valores e retorna '1' se forem iguais e '0' se forem diferentes
    % Le dados das barras
    ibus = ibus + 1;
    Barra.num(ibus,1) = str2double(tline(1:4));
    %Barra.nome(ibus,1) = cellstr(tline(6:17)); % Retirei essa linha pelo seguinte motivo: ela estava retornando 'Bus 1 132kV' e o le como str
    
    
    Barra.T(ibus,1) = str2double(tline(13:15)); % Inclui essa linha para que leia a potência em kVA de cada uma das barras (ex.: 132 kVA)
    Barra.num(ibus,1) = str2double(tline(1:4)); % Inclui essa linha para conseguir ler o número da Barra 
        
    Barra.area(ibus,1) = str2double(tline(19:20));
    Barra.zona(ibus,1) = str2double(tline(21:23));
    Barra.tipo(ibus,1) = str2double(tline(25:26));    % 25 - 26
    if Barra.tipo(ibus,1) == 3
        n_ref = n_ref + 1;
        if n_ref == 1
%             fprintf('Barra de Referencia: %d\n', Barra.num(ibus,1));
            Bref = Barra.num(ibus,1);
        else
%             fprintf('Barra de Referencia: %d\n', Barra.num(ibus,1));
            disp('AVISO: Mais de uma Barra de Referencia - Usando a primeira!')
        end
    end
    Barra.tensao(ibus,1) = str2double(tline(28:33));
    Barra.angulo(ibus,1) = pi/180*(str2double(tline(34:40)));
    if Barra.tipo(ibus,1) == 3
        if Barra.angulo(ibus,1) ~= 0
            fprintf('AVISO: Angulo da Barra de Referencia diferente de zero: %0.4f\n', Barra.angulo(ibus,1));
        end
    end
    Barra.carga_MW(ibus,1) = str2double(tline(41:49));
    Barra.carga_MVAR(ibus,1) = str2double(tline(50:58));
    Barra.ger_MW(ibus,1) = str2double(tline(59:67));
    Barra.ger_MVAR(ibus,1) = str2double(tline(68:75));
    Barra.kVBase(ibus,1) = str2double(tline(77:83));
    Barra.tensao_inic(ibus,1) = str2double(tline(85:90));
    Barra.lim_max(ibus,1) = str2double(tline(91:98));
    Barra.lim_min(ibus,1) = str2double(tline(99:106));
    Barra.g(ibus,1) = str2double(tline(107:114));
    Barra.b(ibus,1) = str2double(tline(115:122));
    Barra.ctrl_rem(ibus,1) = str2double(tline(124:127));
    Barra.estado_mod(ibus,1) = 1;
    Barra.estado_ang(ibus,1) = 0;
end
if n_ref == 0
    disp('AVISO: Nao ha Barra de Referencia! - Usando Barra 1')
    Bref = Barra.num(1,1);
end
% Procura a frase 'BRANCH DATA FOLLOWS'
while 1 
    tline = fgetl(fid);
    if  strcmp(tline(1:19), 'BRANCH DATA FOLLOWS'), break, end
end
% Ler dados dos ramos
ilin = 0;
while 1
    tline = fgetl(fid);
    % Conclui se encontra o fim do bloco
    if  strcmp(tline(1:4), '-999'), break, end
    ilin = ilin + 1;
    clin = length(tline);
    Ramo.num(ilin,1)=ilin;
    Ramo.de(ilin,1)=str2double(tline(1:4));
    Ramo.para(ilin,1)=str2double(tline(6:9));
    Ramo.area(ilin,1)=str2double(tline(11:12));
    Ramo.zona(ilin,1)=str2double(tline(13:15));    % 14
    Ramo.circuito(ilin,1)=str2double(tline(17));
    Ramo.tipo(ilin,1)=str2double(tline(19));
    Ramo.r(ilin,1)=str2double(tline(20:29));
    Ramo.x(ilin,1)=str2double(tline(30:39));            % 40
    Ramo.b(ilin,1)=str2double(tline(40:49));            % 41 - 50
    Ramo.rat_1(ilin,1)=str2double(tline(51:55));
    Ramo.rat_2(ilin,1)=str2double(tline(57:61));
    Ramo.rat_3(ilin,1)=str2double(tline(63:67));
    Ramo.barra_ctrl(ilin,1)=str2double(tline(69:72));
    Ramo.lado(ilin,1)=str2double(tline(74));
    Ramo.rel_tr(ilin,1)=str2double(tline(77:82));
    Ramo.ang_tr(ilin,1)=str2double(tline(84:90));
    Ramo.tap_min(ilin,1)=str2double(tline(91:97));
    Ramo.tap_max(ilin,1)=str2double(tline(98:104));
    Ramo.step(ilin,1)=str2double(tline(106:111));
    if clin <= 119
        Ramo.lim_min(ilin,1)=str2double(tline(113:clin));
    else
        Ramo.lim_min(ilin,1)=str2double(tline(113:119));
    end
    if clin <= 126
        Ramo.lim_max(ilin,1)=str2double(tline(120:clin));
    else
        Ramo.lim_max(ilin,1)=str2double(tline(120:126));
    end
    Ramo.status(ilin,1) = 1;
end
% Retorna os dados do caso
Caso.data = CASE_DATE;
Caso.origem = CASE_SENDER;
Caso.MVA = MVA_BASE;
Caso.ano = YEAR;
Caso.epoca = SEASON;
Caso.ident = CASE_IDENT;
Caso.NB = ibus;
Caso.NR = ilin;
Caso.Bref = Bref; 
return;