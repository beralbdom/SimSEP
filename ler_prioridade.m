function [prioridades] = ler_prioridade(sis_file)


    if nargin < 1
        sis_file = input('Entre com o nome do arquivo da funcao de custo:', 's');
    end

    % Abre o arquivo para leitura
    fid = fopen(sis_file, 'r');
    pos_ini = 1;
    pos_fim = 1;
    usi = 1;
    num_teste = 1;
    while 1   
        tline = strtrim(fgetl(fid));  
         if tline(1) == 'E'
              break
         end
         pos_ini = 1;
         usi = 1;
        if tline(1) ~= '('  

            for i = 1:length(tline)      
                if tline(i) == ';'
                    prioridades(num_teste,usi) = str2double(tline(pos_ini:i-1));
                    pos_ini = i + 1;
                    break
                end  
                if tline(i) == ','
                    prioridades(num_teste,usi) = str2double(tline(pos_ini:i-1));
                    pos_ini = i + 1;
                    usi = usi+1;
                end  
            end
            num_teste = num_teste + 1;
        end
    end
    return
end

