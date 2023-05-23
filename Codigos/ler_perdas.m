function [perdas] = ler_perdas(sis_file)

format long;

perdas.usi_bus = [];
perdas.coefs = [];
perdas.coefs_deriv = [];


if nargin < 1
    sis_file = input('Entre com o nome do arquivo da funcao de custo:', 's');
end

% Abre o arquivo para leitura
fid = fopen(sis_file, 'r');

N_busger = 1; %numero de barras com geração

while 1
      %le a linha completa
      tline = strtrim(fgetl(fid));     
   
    %Veririca se o arquivo foi encerrado
     if tline(1:3) == 'END'
          break
      end
      
      step_leitura_ini = 14;
      step_leitura_final = step_leitura_ini + 12;
      
      %Le a linha e os coeficientes da função de custo
      if tline(1) ~= '('
          perdas.usi_bus(N_busger,1) = str2double(tline(1:13));  
          %realiza um for para ler todos os coeficientes de uma determinada
          %barra
          for n_coef = 1:fix(length(tline)/13)
              %se o for estiver na ultima iteração o elemento final é lido
              %ate o limite da linha
              if n_coef ~= fix(length(tline)/13)
                  %multiplica por n_coef-1 para ja obter o resultado do
                  %polinomio derivado
                perdas.coefs_deriv(N_busger,n_coef) = str2double(tline(step_leitura_ini:step_leitura_final)) * (n_coef-1);
                perdas.coefs(N_busger,n_coef) = str2double(tline(step_leitura_ini:step_leitura_final));
                step_leitura_ini = step_leitura_ini + 13;
                step_leitura_final = step_leitura_ini + 12;
              else
                  perdas.coefs_deriv(N_busger,n_coef) = str2double(tline(step_leitura_ini:length(tline))) * (n_coef-1);
                  perdas.coefs(N_busger,n_coef) = str2double(tline(step_leitura_ini:length(tline)));
              end
          end      
          N_busger = N_busger + 1;
     %se a linha for um comentario nada é feito     
      else     
      end   
end
return;

end

