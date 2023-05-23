% GERADOR DE CONTINGÊNCIA

% Neste programa o usuário irá escolher qual tipo de carga deseja em cada barra;
% A barra 1 é a barra de referência;
% As barras poderão ter cargas RESIDENCIAIS e COMERCIAIS;
% No Menu Inicial:
% a) Digite 1 para carga residencial;
% b) Digite 2 para carga comercial;

clear

% Título:
disp('-----------------------------------------------');
disp('|            GERADOR DE CONTINGÊNCIA          |');
disp('-----------------------------------------------');
disp('-----------------------------------------------');
disp('|Para barra com carga RESIDENCIAL: | digite 1 |');
disp('|Para barra com carga COMERCIAL  : | digite 2 |');
disp('-----------------------------------------------');
disp('-----------------------------------------------');
disp('|-------- AVISO: barra 1 é a referência ------|');
disp('-----------------------------------------------');

% Menu:
tipo_carga2 = 'Tipo de carga da barra 2';
tipo_carga3 = 'Tipo de carga da barra 3';
tipo_carga4 = 'Tipo de carga da barra 4';
tipo_carga5 = 'Tipo de carga da barra 5';
tipo_carga6 = 'Tipo de carga da barra 6';
tipo_carga7 = 'Tipo de carga da barra 7';
tipo_carga8 = 'Tipo de carga da barra 8';
tipo_carga9 = 'Tipo de carga da barra 9';
tipo_carga10 = 'Tipo de carga da barra 10';
tipo_carga11 = 'Tipo de carga da barra 11';
tipo_carga12 = 'Tipo de carga da barra 12';
tipo_carga13 = 'Tipo de carga da barra 13';
tipo_carga14 = 'Tipo de carga da barra 14';

menu = inputdlg({tipo_carga2, tipo_carga3, tipo_carga4, tipo_carga5, tipo_carga6, tipo_carga7, tipo_carga8, tipo_carga9, tipo_carga10, tipo_carga11, tipo_carga12, tipo_carga13, tipo_carga14});

passo = 1;
hora = zeros(1,24/passo);
for ii = 1:length(hora)-1
    hora(1) = 1;
    hora(ii+1) = (ii*passo)+1;
end

t_vet = size(hora);
matriz_carga = zeros(13,t_vet(2)); % essa matriz armazena em suas linhas as cargas referente a cada barra
matriz_aux = zeros(14,t_vet(2)); % A coluna "Barra.carga_MW" da matriz "N BUS" será substituida pelas colunas da "matriz_aux" 

for zz = 1:24/passo
    vet_aux(zz) = zz + (zz-1);
end

linha = 0*vet_aux;

NB=14;
a = 2;
b = 3;
r = (b-a).*rand (100,1) + a; % "r" retorna números aleatórios entre o limite mínimo "a" e limite máximo "b"
aux = 2; % é o número da barra que aparece no título dos gráficos que serão mostrados na tela
ampli1 = 0.4; % variável de controle da amplitude das curvas de cargas
ampli2 = 0.7; % variável de controle da amplitude das curvas de cargas


for kk = 1:NB-1; 
    carga(kk+1) = str2num(char(menu(kk))); % carga2 = str2num(char(menu(1)));
    h = figure;
    
    
    if carga(kk+1) == 1;
        contador=1;
        for jj = 1:passo:24;
            if jj < 6
                linha(1,contador) = ampli1*rand(1);
                contador=contador+1;
            end
            if jj >= 6  && jj < 9
                linha(1,contador) = 0.2 + ampli2*rand(1);
                contador=contador+1;
            end
            if jj >= 9 && jj < 16
                linha(1,contador) = ampli1*rand(1);
                contador=contador+1;
            end
            if jj >= 16 && jj < 22
                linha(1,contador) = r(kk) + rand(1);
                contador=contador+1;
            end
            if jj >= 22 && jj < 25
                linha(1,contador) = ampli1*rand(1);
                contador=contador+1;
            end
        end               
                  
        matriz_carga(kk,:) = linha;
        plot(hora,matriz_carga(kk,:));
        title(['CURVA DE CARGA BARRA' num2str(aux) '- RESIDENCIAL']);
        xlabel('Horas');
        ylabel('MW');
        axis([1 24 0 6]);
        saveas(h,sprintf('FIG%d.png',kk)); % will create FIG1, FIG2,...
        aux = aux+1;
     
    else
    
        contador = 1;
        for jj = 1:passo:24;
            if jj < 8
                linha(1,contador) = ampli1*rand(1);
                contador=contador+1;             
            end
            if jj >= 9 && jj < 22
                linha(1,contador) = 2*(r(kk) + rand(1));
                contador=contador+1;                
            end
            if jj >= 23 && jj < 25
                linha(1,contador) = ampli1*rand(1);
                contador=contador+1;               
            end            
        end
    
        matriz_carga(kk,:) = linha;
        plot(hora,matriz_carga(kk,:));
        title(['CURVA DE CARGA BARRA' num2str(aux) '- COMERCIAL']);
        xlabel('Horas');
        ylabel('MW');
        axis([1 24 0 10]);
        saveas(h,sprintf('FIG%d.png',kk)); % will create FIG1, FIG2,...
        aux = aux+1;
    end    
end


% Preenchimento da "matriz_aux"
for jj = 1:24;
    for ii = 2:14;
        matriz_aux(1,jj) = 0;
        matriz_aux(ii,jj) = matriz_carga(ii-1,jj);
    end
end





    


















