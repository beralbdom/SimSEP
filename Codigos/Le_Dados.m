function [qi_hora, qi_dia, NB] = Le_Dados(Dir)
%LE_DADOS Summary of this function goes here
%   Detailed explanation goes here
ArqDI = fopen(Dir, 'r');

tline = fgetl(ArqDI);tline = fgetl(ArqDI);
tlineN = regexp(tline,'[-.\d]{1,10}','match');
NB = str2double(tlineN(1));
step = str2double(tlineN(2));
qi_hora=60/step;               % Quantidade de instantes em uma hora, em relação ao step selecionado
qi_dia=qi_hora*24;                 % Quantidade de instantes em um dia
end

