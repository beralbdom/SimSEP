function [custo_final,perda_final, perda_final_din] = calcula_custo_perda(Pcalc,f_custo,f_perda,N_bus_ger,y)


 
 
 perda_final = 0.0;
 for u = 1:N_bus_ger
     perda_final = perda_final + (f_perda.coefs(u,:) * Pcalc(:,u));
 end
    perda_final_din = perda_final * y;
 custo_final = 0.0;
 
 for u = 1:N_bus_ger
     custo_final = custo_final + (f_custo.coefs(u,:) * Pcalc(:,u));
 end
 
end

