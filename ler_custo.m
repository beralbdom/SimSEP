function [custo, Plim] = ler_custo(sis_file)
format long;
custo.usi_bus = [];
custo.coefs_deriv = [];
custo.coefs = [];
Plim.usi_bus = [];
Plim.Pmin = [];
Plim.Pmax = [];

if nargin < 1
    sis_file = input('Entre com o nome do arquivo da funcao de custo:', 's');
end

% Abre o arquivo para leitura
fid = fopen(sis_file, 'r');
Le_Limites = 0;

N_busger = 1; %numero de barras com geração
N_busger_Plim = 1; %Numero de barras de geração utilizado na leitura dos Plim

while 1
      %le a linha completa
      tline = strtrim(fgetl(fid));     
   
    %Veririca se o arquivo foi encerrado
     if tline(1:3) == 'END'
          break
     end   
     if tline(1:4) == 'NEXT' 
         Le_Limites = 1;
         break    
     end
     
      step_leitura_ini = 14;
      step_leitura_final = step_leitura_ini + 12;
      
      %Le a linha e os coeficientes da função de custo
      if tline(1) ~= '('
          custo.usi_bus(N_busger,1) = str2double(tline(1:13));  
          %realiza um for para ler todos os coeficientes de uma determinada
          %barra
          for n_coef = 1:fix(length(tline)/13)
              %se o for estiver na ultima iteração o elemento final é lido
              %ate o limite da linha
              if n_coef ~= fix(length(tline)/13)
                  %multiplica por n_coef-1 para ja obter o resultado do
                  %polinomio derivado
                custo.coefs_deriv(N_busger,n_coef) = str2double(tline(step_leitura_ini:step_leitura_final)) * (n_coef-1);
                custo.coefs(N_busger,n_coef) = str2double(tline(step_leitura_ini:step_leitura_final));
                step_leitura_ini = step_leitura_ini + 13;
                step_leitura_final = step_leitura_ini + 12;
              else
                  custo.coefs_deriv(N_busger,n_coef) = str2double(tline(step_leitura_ini:length(tline))) * (n_coef-1);
                  custo.coefs(N_busger,n_coef) = str2double(tline(step_leitura_ini:length(tline)));
              end
          end      
          N_busger = N_busger + 1;
     %se a linha for um comentario nada é feito       
      end   
end

  if Le_Limites == 1; 
      while 1
          
          tline = strtrim(fgetl(fid));
          
          if tline(1:3) == 'END'
              break
          end
           
          %Le a linha e os limites de Potencia
          if tline(1) ~= '('
              Plim.usi_bus(N_busger_Plim) = str2double(tline(1:13));  
              %realiza um for para ler os Limites           
              Plim.min(N_busger_Plim) = str2double(tline(14:26));
              Plim.max(N_busger_Plim) = str2double(tline(27:length(tline)));
     
              N_busger_Plim = N_busger_Plim + 1;
          end       
      end
  end
  
return;
end

