function status= barra_val(Bnum, Barra)
% Verifica se Bnum � uma barra v�lida
% function status= barra_val(Bnum, Barra)
val = Barra.num;
if ismember(Bnum, val)
    status = 1;
else
    status = 0;
end
return