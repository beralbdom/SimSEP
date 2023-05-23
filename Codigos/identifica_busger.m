function [busger] = identifica_busger(barra)

busger.numbar = [];
busger.MW = [];

position = find(barra.ger_MW > 0);

for i = 1:length(position)
    busger.numbar(i) = barra.num(position(i));
    busger.MW(i) = barra.ger_MW(position(i));
end
return;
end