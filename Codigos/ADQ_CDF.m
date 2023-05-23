function [D_BUS,k_BUS,D_BRANCH,k_BRANCH,Sb]=ADQ_CDF(Arq_CDF)
   % Inicializações
   k_BRANCH=0;k_BUS=0;
   %********** Cerrega Dados das Barras (BUS)
   %ArqE1 = fopen(strcat(Pth,Arq_CDF), 'r');
   ArqE1=Arq_CDF;wh=0;
   while ~feof(ArqE1)
       wh=wh+1;
       Lin=fgetl(ArqE1);LinD=regexp(Lin,'[-.\d]{3,7}','match');
       if wh==1
           Sb=str2double(LinD(1));                               % SB - Potência de Base em MVA
       end
       if ~isempty(strfind(Lin,'BUS DATA'))                     % Incia a Captura de Dados se encontra 'BUS DATA' (isempty=0 - Inicia Captura) ) 
           while isempty(strfind(Lin,'-999'))                   % Continua Captura de Dados enquanto não encontra '-999' (isempty=0 - sai do loop))
               Lin=fgetl(ArqE1);
               if length(Lin)>80
                   k_BUS=k_BUS+1;
                   LinD=regexp(Lin,'[-.\d]{1,8}','match');
                   for m=1:length(LinD)
                       switch m
                           case 1
                               D_BUS(k_BUS,1)=str2double(LinD(m));            %Barra (BUS)
                           case 6
                               D_BUS(k_BUS,2)=str2double(LinD(m));            %Vf - Tensão Final em pu
                           case 7
                               D_BUS(k_BUS,3)=str2double(LinD(m));            %Angf - Ângulo Final em graus
                           case 8
                               D_BUS(k_BUS,4)=str2double(LinD(m));            %PL - Potência Ativa Carga em MW
                           case 9
                               D_BUS(k_BUS,5)=str2double(LinD(m));            %QL - Potência Reativa Carga em MVar
                           case 10
                               D_BUS(k_BUS,6)=str2double(LinD(m));            %PG - Potência Ativa Gerador MW
                           case 11
                               D_BUS(k_BUS,7)=str2double(LinD(m));            %PQ - Potência Reativa Gerador em MVar
                           case 12
                               D_BUS(k_BUS,8)=str2double(LinD(m));            %VB - Tensão de Base em KV
                           case 16
                               D_BUS(k_BUS,9)=str2double(LinD(m));            %G - Condutancia Shunt em pu
                           case 17
                               D_BUS(k_BUS,10)=str2double(LinD(m));           %B - Susceptância Shunt em pu
                       end
                   end
               end
           end
       end
   %end
   %fclose(ArqE1);
   %********** Cerrega Dados das Linhas (BRANCH)
   %ArqE1 = fopen(strcat(Pth,Arq_CDF), 'r');
   %while ~feof(ArqE1)
       %Lin=fgetl(ArqE1);
       if strfind(Lin,'BRANCH')>0
           while ~feof(ArqE1)
               Lin=fgetl(ArqE1);
               if length(Lin)>80
                   k_BRANCH=k_BRANCH+1;
                   LinD=regexp(Lin,'[-.\d]{1,10}','match');
                   for m=1:length(LinD)
                       switch m
                           case 1
                               D_BRANCH(k_BRANCH,1)=str2double(LinD(m));                  %Barra de Origem
                           case 2
                               D_BRANCH(k_BRANCH,2)=str2double(LinD(m));                  %Barra de Destino
                           case 7
                               D_BRANCH(k_BRANCH,3)=str2double(LinD(m));                  %R - Resistência Linha (pu)
                           case 8
                               D_BRANCH(k_BRANCH,4)=str2double(LinD(m));                  %X - Reatância Linha (pu)
                           case 9
                               D_BRANCH(k_BRANCH,5)=str2double(LinD(m));                  %B - Susceptância Linha (pu)
                       end 
                   end
               end
           end
       end
   end
   fclose(ArqE1);
end