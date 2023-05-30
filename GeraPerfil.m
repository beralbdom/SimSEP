function [Carga] = GeraPerfil(DirD, TipoDeCarga, qi_hora, qi_dia, x_pc, Carga)
    %TipoDeCarga = 'Residencial'
    %TipoDeCarga = 'Comercial';
    %step = 1; %hora a hora
    %step = 60; %min a min
    fileID = strcat(DirD, 'PerfisdeCarga.xlsx');
    Sheets = TipoDeCarga;
    horaX = xlsread(fileID, Sheets, 'A2:A25');
    PesosY = xlsread(fileID, Sheets, 'B2:B25');
    
    for i = 1 : qi_dia
        Carga(i, x_pc) = interp1(horaX, PesosY, (i/qi_hora), 'pchip','extrap');
        end
    end


