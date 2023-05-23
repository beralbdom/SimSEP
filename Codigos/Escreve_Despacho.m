function [] = Escreve_Despacho(Barra,hora_tot)
    %hora apenas para testar
   
  sis_file = strcat('Carga\ieee',hora_tot,'.txt');
  fid = fopen(sis_file, 'r');

  count = 1;  
  
  new_file=strcat('Despacho\ieee',hora_tot,'.txt');
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
            if Barra.ger_MW(count) < 0.5 
                fprintf(filen,'%s\n',tline);
            else
            temp = num2str(Barra.ger_MW(count),'%.1f');
            tline(59:67) = '         ';
            tline(59+8-length(temp):66) = temp;
            
            fprintf(filen,'%s\n',tline);    
            end
            count = count + 1;
          end   
       else
         fprintf(filen,'%s\n',tline);
       end
   end
    fclose(fid);
    fclose(filen);
     
end
   


