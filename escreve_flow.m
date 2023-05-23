function[] = escreve_flow(DirDesp,DirR,NB,im,horas,mins,V,Pt,Qt,Sb,D_BUS)
Arq_CDF=fopen(strcat(DirDesp,'ieee',int2str(NB),'_',int2str(im),'_',horas,mins,'.txt'),'r');
    Arq_CDF_Flx=fopen(strcat(DirR,'ieee',int2str(NB),'_',int2str(im),'_',horas,mins,'_Flow.txt'),'wt');
    while ~feof(Arq_CDF)
        Lin=fgetl(Arq_CDF);
        if ~isempty(strfind(Lin,'BUS DATA'))                     % Incia a Captura de Dados se encontra 'BUS DATA' (isempty=0 - Inicia Captura) ) 
           while isempty(strfind(Lin,'-999'))                   % Continua Captura de Dados enquanto não encontra '-999' (isempty=0 - sai do loop))
               Lin=fgetl(Arq_CDF);
               if length(Lin)>100
                   Barra=str2double(Lin(1:4));
                   Tipo=str2double(Lin(25:26));
                   Vcdf=abs(V(Barra));Tetacdf=angle(V(Barra))*180/pi;
                   Vcdfs = num2str(Vcdf,'%.3f');
                   Tetacdfs = num2str(Tetacdf,'%.2f');
                   Lin(28+6-length(Vcdfs):33) = Vcdfs;         %escreve V
                   Lin(28:28+5-length(Vcdfs)) = ' ';           %escreve V
                   Lin(34+7-length(Tetacdfs):40) = Tetacdfs;   %escreve Teta
                   Lin(34:34+6-length(Tetacdfs)) = ' ';        %escreve Teta
                   if Tipo==3
                       PGMW=Pt(Barra,im)*Sb+D_BUS(Barra,5);
                       PGMWs=num2str(PGMW,'%.1f');
                       Lin(59+8-length(PGMWs):66) = PGMWs;         %escreve PG
                       %Lin(60:60+7-length(PGMWs)) = ' ';
                       PGMVar=Qt(Barra,im)*Sb+D_BUS(Barra,6);
                       PGMVars=num2str(PGMVar,'%.1f');
                       Lin(68+8-length(PGMVars):75) = PGMVars;     %escreve QG
                       Lin(68:68+7-length(PGMVars)) = ' ';
                   elseif Tipo==2
                       PGMVar=Qt(Barra,im)*Sb+D_BUS(Barra,6);
                       PGMVars=num2str(PGMVar,'%.1f');
                       Lin(68+8-length(PGMVars):75) = PGMVars;     %escreve QG
                       Lin(68:68+7-length(PGMVars)) = ' ';
                   end
                   fprintf(Arq_CDF_Flx,'%s\n',Lin);
               end
           end
           fprintf(Arq_CDF_Flx,'%s\n',Lin);
        else
           fprintf(Arq_CDF_Flx,'%s\n',Lin); 
        end
    end
    fclose(Arq_CDF);
    fclose(Arq_CDF_Flx);
    