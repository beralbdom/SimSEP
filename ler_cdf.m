function [D_BUS,k_BUS,D_BRANCH,k_BRANCH,Sb,accry,maxiter,NLO,Vb,horas,mins]=ler_cdf(DirCDF,im,NB,qi_dia)
   % Inicializa��es
   k_BRANCH=0;k_BUS=0;wh=0;
   accry=1e-4;maxiter=20;Vb=132e3;
   %********** Cerrega Dados das Barras (BUS)
   hora=(im*24/qi_dia);horaf=fix(hora);
   min=(hora-fix(hora))*60;minr=round(min);
   if horaf <10
      horas=strcat('0',int2str(horaf));
   else
      horas=int2str(horaf);
   end
   if minr <10
      mins=strcat('0',int2str(minr));
   else
      mins=int2str(minr);
   end
   Arq_CDF=fopen(strcat(DirCDF,'ieee',int2str(NB),'_',int2str(im),'_',horas,mins,'.txt'),'r');
   while ~feof(Arq_CDF)
       wh=wh+1;
       Lin=fgetl(Arq_CDF);%LinD=regexp(Lin,'[-.\d]{3,7}','match');
       if wh==1
           Sb=str2double(Lin(32:37));                               % SB - Pot�ncia de Base em MVA
       end
       if ~isempty(strfind(Lin,'BUS DATA'))                     % Incia a Captura de Dados se encontra 'BUS DATA' (isempty=0 - Inicia Captura) ) 
           while isempty(strfind(Lin,'-999'))                   % Continua Captura de Dados enquanto n�o encontra '-999' (isempty=0 - sai do loop))
               Lin=fgetl(Arq_CDF);
               if length(Lin)>100
                   k_BUS=k_BUS+1;
%                    LinD=regexp(Lin,'[a-z,A-Z,-.\d]{1,8}','match');
                   D_BUS(k_BUS,1)=str2double(Lin(1:4));               %Barra (BUS)
                   D_BUS(k_BUS,2)=str2double(Lin(25:26));             %Tipo Barra
                   D_BUS(k_BUS,3)=str2double(Lin(28:33));             %Vf - Tens�o fluxo em pu
                   D_BUS(k_BUS,4)=str2double(Lin(34:40));             %Angf - �ngulo fluxo em graus
                   D_BUS(k_BUS,5)=str2double(Lin(41:49));             %PL - Pot�ncia Ativa Carga em MW
                   D_BUS(k_BUS,6)=str2double(Lin(50:59));             %QL - Pot�ncia Reativa Carga em MVar
                   D_BUS(k_BUS,7)=str2double(Lin(60:67));             %PG - Pot�ncia Ativa Gerador MW
                   D_BUS(k_BUS,8)=str2double(Lin(68:75));             %QG - Pot�ncia Reativa Gerador em MVar
                   D_BUS(k_BUS,9)=str2double(Lin(77:83));             %VB - Tens�o Base
                   D_BUS(k_BUS,10)=str2double(Lin(91:98));            %Qmax - Reativo m�ximo barra PV
                   D_BUS(k_BUS,11)=str2double(Lin(99:106));           %Qmin - Reativo m�nimo barra PV
                   D_BUS(k_BUS,12)=str2double(Lin(107:114));          %G - Condutancia Shunt em pu
                   D_BUS(k_BUS,13)=str2double(Lin(115:122));          %B - Suscept�ncia Shunt em pu
                   D_BUS(k_BUS,14)=1;                                 %a - ZIP
                   D_BUS(k_BUS,15)=0;                                 %b - ZIP
                   D_BUS(k_BUS,16)=0;                                 %c - ZIP
                   D_BUS(k_BUS,17)=str2double(Lin(85:90));            %Tens�o Barra PV
               end
           end
       end
   %end
   %fclose(Arq_CDF);
   %********** Cerrega Dados das Linhas (BRANCH)
   %Arq_CDF=fopen(strcat(DirCDF,'ieee',int2str(NB),'_',int2str(im),'_',horas,mins,'.txt'),'r');
   %while ~feof(Arq_CDF)
       %Lin=fgetl(Arq_CDF);
       if strfind(Lin,'BRANCH')>0
           while isempty(strfind(Lin,'-999'))
               Lin=fgetl(Arq_CDF);
               if length(Lin)>80
                   k_BRANCH=k_BRANCH+1;
%                    LinD=regexp(Lin,'[-.\d]{1,10}','match');
                   D_BRANCH(k_BRANCH,1)=str2double(Lin(1:4));                  %Barra de Origem
                   D_BRANCH(k_BRANCH,2)=str2double(Lin(6:9));                  %Barra de Destino
                   D_BRANCH(k_BRANCH,3)=str2double(Lin(20:29));                  %R - Resist�ncia Linha (pu)
                   D_BRANCH(k_BRANCH,4)=str2double(Lin(30:40));                  %X - Reat�ncia Linha (pu)
                   D_BRANCH(k_BRANCH,5)=str2double(Lin(41:50))/2;                 %B - Suscept�ncia Linha (pu)
                   D_BRANCH(k_BRANCH,6)=str2double(Lin(77:82));                 %TAP
                   if D_BRANCH(k_BRANCH,6)==0
                       D_BRANCH(k_BRANCH,6)=1;
                   end
                   D_BRANCH(k_BRANCH,7)=str2double(Lin(84:90))*pi/180;           %�ngulo TAP (graus)
               end
           end
       end
   end
   NLO=k_BRANCH;
   for m=1:k_BUS
     if D_BUS(m,12) ~= 0 || D_BUS(m,13) ~= 0
         k_BRANCH=k_BRANCH+1;
         D_BRANCH(k_BRANCH,1)=D_BUS(m,1);                           % Inser��o da Barra
         D_BRANCH(k_BRANCH,2)=0;                                    % Inserc�o da Refer�ncia
         Y=(D_BUS(m,12)+1i*D_BUS(m,13));                            % Adimit�ncia em pu
         Z=1/Y;
         D_BRANCH(k_BRANCH,3)=real(Z);                              % Inserc�o da Resist�ncia Shunt       
         D_BRANCH(k_BRANCH,4)=imag(Z);                              % Inserc�o da Reat�ncia Shunt
         D_BRANCH(k_BRANCH,5)=0;
         D_BRANCH(k_BRANCH,6)=1;
         D_BRANCH(k_BRANCH,7)=0;
     end
  end
  fclose(Arq_CDF);
end