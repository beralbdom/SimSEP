function [f_busger,Custo_atual,Perda_final_dinheiro] = minimiza_custo(f_custo,f_busger,f_barra,f_perda,erro,Plim,Prioridades)

    %funcao do lagrangiano L = sum(Fi(Pi) + lambda(Pload - sum(Pi))
    %gradiente de L = [dF1(P1)/dP1 - lambda, ..., Pload - sum(Pi)]
    %f_custo é a estrutura com os coeficientes da função de custo já
    %derivada (uma vez)
    
    
    %numero de barras de geração
    N_bus_ger = length(f_busger.numbar);
    N_bus_custo = length(f_custo.usi_bus);
    N_bus_perda = length(f_perda.usi_bus);
    
    if N_bus_ger > N_bus_custo  
        fprintf('Falta função de custo!');        
    end   
    if N_bus_ger > N_bus_perda 
        fprintf('Falta função de perda!');
    end
    
    
   %carga total do sistema (nao considerando as perdas)
    Pload = sum(f_barra.carga_MW(:));
    
    %Variavel que habilita o while de iterações
    Prioridades = sort(Prioridades);
    soma_pot_maxima = 0;
    count = 1;
    for i = 1:length(Prioridades)   
        if Prioridades(i) ~= 0
            Usina_Ligadas(count) = Prioridades(i);
            soma_pot_maxima = soma_pot_maxima + Plim.max(Prioridades(i));
            count = count + 1;
        end     
    end
    %Verifica se a potencia maxima das usinas ligadas atende a carga
    Desliga_Usi = [];
    if soma_pot_maxima >= Pload
        run = 1;
        
        %Verifica as usinas que devem ser desligadas
        achou = 0;
        count_usi = 1;
        %muda as barras de geração para uma ordem sequencial para ser
        %comparada com a lista de prioridades.
        for i = 1:length(f_busger.numbar)
            usi_exist(i) = i;
        end
        for i = 1:N_bus_ger
            for j = 1:length(Usina_Ligadas)
                
                if usi_exist(i) == Usina_Ligadas(j)
                    achou = 1;
                end       
            end 
            if achou == 0 
                Desliga_Usi(count_usi) = i;
                count_usi = count_usi + 1;
            end
            achou = 0;
        end
               
    else
        run = 0;
    end
    

        
    %Criação de um vetor que conterá todas as variáveis do problema.
    Var = f_busger.MW;
    
      %Desliga as usinas para comissionamento
    if ~isempty(Desliga_Usi) 
        for i = 1:length(Desliga_Usi)      
            Plim.max(Desliga_Usi(i)) = 0.0;
            Plim.min(Desliga_Usi(i)) = 0.0;
        end
    end
    %y representará o lambda
    y = 0.0;

    %adicionar o lambda à estrutura de barras de geração 
    Var(N_bus_ger + 1) = y;
    
    %O vetor será da forma:
    % [P1 P2 ... Pn y u1 s1 d1 k1 u2 s2 d2 k2 ... un sn dn kn]
    for i = (N_bus_ger + 2):(N_bus_ger*4) + N_bus_ger+1
       Var(i) = 1;        
    end
    
   
    
    

    %utilizando a propria potencia de geração com potencia total de carga, pois
    %nao sao consideradasas perdas
    %Pload = sum(f_busger.MW(:));
    Pload = sum(f_barra.carga_MW(:));
    %Criação dos coeficientes da segunda derivada de custo para obtenção da matriz
    %Hessiana
    for j = 1:length(f_custo.coefs_deriv(:,1))
        for i = 1:length(f_custo.coefs_deriv(1,:))
            coefs_Hess(j,i) = f_custo.coefs_deriv(j,i) * (i-2);
        end
    end
    
    %Criação dos coeficientes da segunda derivada de perda para obtenção da matriz
    %Hessiana
    for j = 1:length(f_perda.coefs_deriv(:,1))
        for i = 1:length(f_perda.coefs_deriv(1,:))
            coefs_Hess_perda(j,i) = f_perda.coefs_deriv(j,i) * (i-2);
        end
    end

    %matriz Hessiana do lagrangiano com dimensao igual ao numero de barras de
    %geração somado de 1
    H = zeros (N_bus_ger*5 + 1,N_bus_ger*5 + 1);
    
    %Preenche a Hessiana com os valores constantes necessários resultantes
    %das derivadas
    linha = 1;
    for i = N_bus_ger+2:4:length(H)
       H(linha,i) = 1;
       H(linha,i+2) = -1;
    
       H(i,linha) = 1;
       H(i+2,linha) = -1;
       
       linha = linha + 1;    
    end
    
    

    %verifica o maior grau dos polinomios de custo ou perda (o que for maior) original
    for i = 1:N_bus_ger
        tst_grau(i) = max(find(f_custo.coefs_deriv(i,:)));
    end
    for i = N_bus_ger + 1:N_bus_ger + N_bus_ger
        tst_grau(i) = max(find(f_perda.coefs_deriv(i - N_bus_ger,:)));
    end
    grau_max = max(tst_grau(:));

    %criação da matriz de potencias que será utilizada para calcular o
    %gradiente e a hessiana
    Pcalc = zeros(grau_max,N_bus_ger);
    Pcalc(1,:) = 1;
    %---------------------------------------------------------------------

    %MATRIZES QUE DEVEM SER RECALCULADAS A CADA ITERAÇÃO

    %matriz de potencias para calcular os valores do gradiente e da Hessiana
    %o valor inicializado de potencia é o verificado em cada barra e depois é
    %atualizado a cada iteração
    count_int = 1;
    grad = zeros(1,length(Var));
    while run
        
        %Se chegar ao número de 30 iterações a carga total é dividida
        %igualmente para todas as usinas
        if count_int == 30 || sum(Plim.max(1:N_bus_ger)) < Pload || sum(Plim.min(1:N_bus_ger)) > Pload     
            for k = 1:N_bus_ger 
             Var(k) = Pload/N_bus_ger;
             Custo_atual = 9999999;
             Perda_final_dinheiro = 9999999;
            end
            Var(N_bus_ger+1) = 999999;
            %Escrever arquivo dizendo qual cdf nao convergiu          
            break
        end
        
        
        y = Var(N_bus_ger + 1);
        for i = 2:grau_max 
            for j=1:N_bus_ger
                Pcalc(i,j) = Var(j)^(i-1);
            end
        end
        
         
        
         %calculo das perdas do sistema com as potencias atuais
         %Perda_final_dinheiro é o valor da perda multiplicado pelo
         %lamda de cada iteração, para saber o custo da perda.
            
        [Custo_atual, P_loss(count_int),Perda_final_dinheiro] = calcula_custo_perda(Pcalc,f_custo,f_perda,N_bus_ger,y);
        
        
        %geração do gradiente 
        
        count_aux2 = 0;
        
        for i = 1:N_bus_ger+1
            if i<= N_bus_ger 
            %calculo da parcela derivada de custos
            aux = circshift(f_custo.coefs_deriv(i,:),-1) * Pcalc(:,i);
            %calculo da parcela derivada de perdas
            aux_perda = circshift(f_perda.coefs_deriv(i,:),-1) * Pcalc(:,i);
            
            %calculo da parcela (i) do gradiente dFi(Pi)/dPi - y*(1 -
            %dPloss/dPi)
            
            %Soma das parcelas mi e delta
            aux_mi_delta = Var(N_bus_ger + 2 + count_aux2) - Var(N_bus_ger + 4 + count_aux2);
            grad(i) = aux - (Var(N_bus_ger + 1) * (1 - aux_perda)) + aux_mi_delta;
            
            count_aux2 = count_aux2 + 4;
            end
            %calculo da parcela de derivada de lambda
            if i == N_bus_ger+1
                grad(i) = Pload - sum(Var(1:N_bus_ger)) + P_loss(count_int);
            end
        end
        
        %Geração dos termos referentes a ui
        count_aux2 = 0;
        count_P = 1; %variavel para auxiliar a escolha da barra de geração para calcular o gradiente
        for i = N_bus_ger + 2:4:length(Var)
            grad(i) = Var(count_P) - Plim.max(count_P) + Var(N_bus_ger + 3 + count_aux2)^2;
            count_P = count_P + 1;
            count_aux2 = count_aux2 + 4;
        end
        
        %Geração dos termos referentes a si
        count_aux2 = 0;
        count_P = 1;
        for i = N_bus_ger + 3:4:length(Var)
            grad(i) = 2 * Var(N_bus_ger + 2 + count_aux2) * Var(N_bus_ger + 3 + count_aux2);
            count_P = count_P + 1;
            count_aux2 = count_aux2 + 4;
        end
        
        %Geração dos termos referentes a di
        count_aux2 = 0;
        count_P = 1;
        for i = N_bus_ger + 4:4:length(Var)
            grad(i) = -Var(count_P) + Plim.min(count_P) + Var(N_bus_ger + 5 + count_aux2)^2;
            count_P = count_P + 1;
            count_aux2 = count_aux2 + 4;
        end
        
        %Geração dos termos referentes a ki
        count_aux2 = 0;
        count_P = 1;
        for i = N_bus_ger + 5:4:length(Var)
            grad(i) = 2 * Var(N_bus_ger + 4 + count_aux2) * Var(N_bus_ger + 5 + count_aux2);
            count_P = count_P + 1;
            count_aux2 = count_aux2 + 4;
        end
              
            

        %Calculo da Matriz Hessiana 
        for i = 1:N_bus_ger + 1
            if i ~= (N_bus_ger + 1)
             %aux1 é o termo referente à derivada do custo
             %aux2 é o termo referente à derivada da perda
             %f_busger.MW(N_bus_ger + 1) é o valor atual de lambda
             aux1 = circshift(coefs_Hess(i,:),-2) * Pcalc(:,i);
             aux2 = circshift(coefs_Hess_perda(i,:),-2) * Pcalc(:,i);
             H(i,i) = aux1 + (Var(N_bus_ger + 1) * aux2);
             
             %nas ultimas linhas e colunas o termo derivado é igual a:
             %-1 + dPloss/dPi
             H(i,N_bus_ger+1) = -1 +  circshift(f_perda.coefs_deriv(i,:),-1) * Pcalc(:,i);
             H(N_bus_ger+1,i) = -1 +  circshift(f_perda.coefs_deriv(i,:),-1) * Pcalc(:,i);
            else
             H(i,i) = 0.0;
            end 
        end
        %preenche os campos da hessiana referentes às derivadas de ui, si, di, ki
        %termos deferentes a ui, si
        count_aux = 0;
        for i = N_bus_ger+2:4:length(H)
             H(i+1, i) = 2 * Var(N_bus_ger + 3 + count_aux);
             H(i, i+1) = 2 * Var(N_bus_ger + 3 + count_aux);
             H(i+1, i+1) = 2 * Var(N_bus_ger + 2 + count_aux);
             count_aux = count_aux + 4;
        end  
        %termos referentes a di, ki
         count_aux = 0;
        for i = N_bus_ger+4:4:length(H)
             H(i+1, i) = 2 *  Var(N_bus_ger + 5 + count_aux);
             H(i, i+1) = 2 *  Var(N_bus_ger + 5 + count_aux);
             H(i+1, i+1) = 2 *  Var(N_bus_ger + 4 + count_aux);
             count_aux = count_aux + 4;
        end

        %----------------------------------------------------------------
        
   
        
        DELTA_X = -inv(H) * grad';

        if max(DELTA_X) < erro
            break
        else
            Var = Var + DELTA_X';
             
            
            count_int = count_int + 1;
        end
%retorna f_busger com os valores das gerações despachadas considerando o
%menor custo e o valor de lambda na ultima posição, que não será utilizado.

    end
    
    if run == 0   
         for k = 1:N_bus_ger 
             Var(k) = 0;
             Custo_atual = 9999999;
             Perda_final_dinheiro = 9999999;
         end
         Var(N_bus_ger+1) = 999999;
    end
   f_busger.MW = Var(1:N_bus_ger + 1);
    
end
