function [] = GeraCdf(Carga,DirCDF,NB,qi_dia,NB_TC,x_pc)
%nb = 14;
% Abre o arquivo para leitura
for i = 1: qi_dia
  sis_file = strcat(DirCDF,'ieee',int2str(NB),'.cdf');
  fid = fopen(sis_file, 'r');
  hora=(i*24/qi_dia);horaf=fix(hora);
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
  new_file=strcat(DirCDF,'ieee',int2str(NB),'_',int2str(i),'_',horas,mins,'.txt');
  filen=fopen(new_file,'wt');
  while ~feof(fid)
    tline=fgetl(fid);
    if  ~isempty(strfind(tline, 'BUS DATA FOLLOWS'))
      fprintf(filen,'%s\n',tline);
      while 1
        tline = fgetl(fid);
        if  strcmp(tline(1:4), '-999')
            fprintf(filen,'%s\n',tline);
            break
        end
        Barra = str2double(tline(1:4));
        PMW = str2double(tline(41:49));
        QMVar = str2double(tline(50:58));
        for m=1:x_pc
            if Barra==str2double(NB_TC(m,1))
                PMW = Carga(i,m)*PMW;
                QMVar = Carga(i,m)*QMVar;
                break
            elseif m==x_pc
                PMW = Carga(i,m)*PMW;
                QMVar = Carga(i,m)*QMVar;
            end
        end
        PMWs = num2str(PMW,'%.1f');
        QMVars = num2str(QMVar,'%.1f');
        tline(41+9-length(PMWs):49) = PMWs;       %escreve PMW
        tline(41:41+8-length(PMWs)) = ' ';        %escreve PMW
        tline(50+9-length(QMVars):58) = QMVars;   %escreve QMVars
        tline(50:50+8-length(QMVars)) = ' ';      %escreve QMVars
        fprintf(filen,'%s\n',tline);
      end 
    else
      fprintf(filen,'%s\n',tline);
    end
 end
 fclose(fid);
 fclose(filen);
end

end