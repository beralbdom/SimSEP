% ----------------------------------------------------------------------- %
% ------------------------------ ger_carga ------------------------------ %
% ----------------------------------------------------------------------- %

% GERADOR DE CURVAS DE CARGAS

% Neste programa o usu�rio ir� escolher qual tipo de carga deseja em cada barra;
% A barra 1 � a barra de refer�ncia;
% As barras poder�o ter cargas RESIDENCIAIS e COMERCIAIS;
% No Menu Inicial:
% a) Digite 1 para carga residencial;
% b) Digite 2 para carga comercial;


% -------------------------------- T�TULO ------------------------------- %
disp('-----------------------------------------------');
disp('|         GERADOR DE CURVAS DE CARGAS         |');
disp('-----------------------------------------------');
disp('-----------------------------------------------');
disp('|Para barra com carga RESIDENCIAL: | digite 1 |');
disp('|Para barra com carga COMERCIAL  : | digite 2 |');
disp('-----------------------------------------------');
disp('-----------------------------------------------');
disp('|-------- AVISO: barra 1 � a refer�ncia ------|');
disp('-----------------------------------------------');

% ------------------------------ MENU ----------------------------------- %
dlg_title = 'MENU';

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

menu = inputdlg({tipo_carga2, tipo_carga3, tipo_carga4, tipo_carga5, tipo_carga6, tipo_carga7, tipo_carga8, tipo_carga9, tipo_carga10, tipo_carga11, tipo_carga12, tipo_carga13, tipo_carga14},'Menu');

passo = 1;
hora = zeros(1,24/passo);
for ii = 1:length(hora)-1
    hora(1) = 1;
    hora(ii+1) = (ii*passo)+1;
end

t_vet = size(hora);
matriz_carga = zeros(13,t_vet(2)); % essa matriz armazena em suas linhas as Pot�ncias Ativas referente a cada barra
matriz_aux = zeros(14,t_vet(2)); % A coluna "Barra.carga_MW" da matriz "N BUS" ser� substituida pelas colunas da "matriz_aux" 
matriz_carga_MVAR = zeros(14,t_vet(2)); % essa matriz armazena em suas linhas as Pot�ncias Reativas referente a cada barra

for zz = 1:24/passo
    vet_aux(zz) = zz + (zz-1);
end

linha = 0*vet_aux; 
linha_reat = 0*vet_aux;

NB=14;
aux = 2; % � o n�mero da barra que aparece no t�tulo dos gr�ficos que ser�o mostrados na tela

lin_MW = 1;
for kk = 1:NB-1; 
    carga(kk+1) = str2num(char(menu(kk))); % carga2 = str2num(char(menu(1)));
    h = figure;
    angulo = atand(Barra.carga_MVAR(kk+1,1)/Barra.carga_MW(kk+1,1));
    
    if (Barra.carga_MVAR(kk+1,1) == 0)
        angulo = 0;
    end
    if (Barra.carga_MW(kk+1,1) == 0)
        angulo = 0;
    end
    
    
    % -------------------------- UC Residencial ------------------------- %    
    if carga(kk+1) == 1;
        contador=1;
        
        for jj = 1:passo:24;
            if jj >= 1 && jj< 2
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.15;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 2  && jj < 3
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.07;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 3  && jj < 4
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.04;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 4  && jj < 5
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.06;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 5  && jj < 6
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.05;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 6  && jj < 7
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.3;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 7  && jj < 8
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.36;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 8  && jj < 9
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.49;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 9  && jj < 10
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.36;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 10  && jj < 11
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.21;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 11  && jj < 12
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.14;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 12  && jj < 13
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.17;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 13  && jj < 14
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.17;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 14  && jj < 15
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.18;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 15  && jj < 16
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.26;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 16  && jj < 17
                linha(1,contador) = ((Barra.carga_MW(lin_MW+1,1))*0.82);%+5;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 17  && jj < 18
                linha(1,contador) = ((Barra.carga_MW(lin_MW+1,1))*0.86);%+5;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 18  && jj < 19
                linha(1,contador) = ((Barra.carga_MW(lin_MW+1,1))*0.91);%+10;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
% --------------------- arquivo de refer�ncia: 19h ---------------------- %
            if jj == 19 
%                linha(1,contador) = Barra.carga_MW(lin_MW+1 , 1);
                linha(1,contador) = Barra.carga_MW(kk+1,1);
%                linha_reat(1,contador) = (Barra.carga_MVAR(lin_MW+1 , 1))+10;
                linha_reat(1,contador) = Barra.carga_MVAR(kk+1,1);
                contador=contador+1;
            end   
% ----------------------------------------------------------------------- %
            if jj >= 20 && jj < 21
                linha(1,contador) = ((Barra.carga_MW(lin_MW+1,1))*0.95);%+10;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
           
            if jj>=21 && jj<22
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.91;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 22  && jj < 23
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.72;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            if jj >= 23  && jj < 24
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.54;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
             if jj >= 24  && jj < 25
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.31;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;
            end
            
        end  
        
        matriz_carga_MVAR(kk+1,:) = linha_reat;        
        matriz_carga(kk,:) = linha;
        plot(hora,matriz_carga(kk,:));
        title(['CURVA DE CARGA BARRA' num2str(aux) '- RESIDENCIAL']);
        xlabel('Horas');
        ylabel('MW');
        axis([1 24 0 115]);
        saveas(h,sprintf('FIG%d.png',kk)); % will create FIG1, FIG2,...
        aux = aux+1;
        lin_MW = lin_MW+1;
              
    else
 
% ------------------------------ UC Comercial --------------------------- %        
        contador=1;    
        for jj = 1:passo:24;
            if jj >= 1 && jj < 2
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.15;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 2 && jj < 3
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.14;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 3 && jj < 4
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.15;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
           if jj >= 4 && jj < 5
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.31;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 5 && jj < 6
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.47;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 6 && jj < 7
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.79;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end 
            if jj >= 7 && jj < 8
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*1.22;%+10+rand;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 8 && jj < 9
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*1.27;%+10+rand;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 9 && jj < 10
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*1.32;%+10+rand;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 10 && jj < 11
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*1.33;%+10+rand;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 11 && jj < 12
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*1.32;%+10+rand;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 12 && jj < 13
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*1.33;%+10+rand;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 13 && jj < 14
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*1.32;%+10+rand;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 14 && jj < 15
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*1.32;%+10+rand;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 15 && jj < 16
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*1.33;%+10+rand;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 16 && jj < 17
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*1.27;%+10+rand;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 17 && jj < 18
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*1.22;%+10+rand;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 18 && jj < 19
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*1.11;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
% -------------------------------------------------------------------------
            if jj == 19
%               linha(1,contador) = Barra.carga_MW(lin_MW+1 , 1);
                linha(1,contador) = Barra.carga_MW(kk+1,1);
%               linha_reat(1,contador) = Barra.carga_MVAR(lin_MW+1 , 1);
                linha_reat(1,contador) = Barra.carga_MVAR(kk+1,1);
               contador=contador+1;
            end
% -------------------------------------------------------------------------            
            if jj >= 20 && jj < 21
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.68;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 21 && jj < 22
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.57;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 22 && jj < 23
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.46;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 23 && jj < 24
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.35;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
            if jj >= 24 && jj < 25
                linha(1,contador) = (Barra.carga_MW(lin_MW+1,1))*0.25;
                linha_reat(1,contador) = (linha(1,contador))*tand(angulo);
                contador=contador+1;             
            end
        end
        
        matriz_carga_MVAR(kk+1,:) = linha_reat;
        matriz_carga(kk,:) = linha;
        plot(hora,matriz_carga(kk,:));
        title(['CURVA DE CARGA BARRA' num2str(aux) '- COMERCIAL']);
        xlabel('Horas');
        ylabel('MW');
        axis([1 24 0 140]);
        saveas(h,sprintf('FIG%d.png',kk)); 
        aux = aux+1;
        lin_MW = lin_MW+1;
        
    end    
   
end


% ------------------ Preenchimento da "matriz_aux" ---------------------- %
for jj = 1:24;
    for ii = 2:14;
        matriz_aux(1,jj) = 0;
        matriz_aux(ii,jj) = matriz_carga(ii-1,jj);
    end
end





    


















