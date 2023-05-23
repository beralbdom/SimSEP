%Desenvolvido por: Gabriel dos Santos Vieira Nascimento
%Email: gabrieldos@id.uff.br
%programa principal que chama as funções para fazer o despacho economico

    
 %[qi_hora, qi_dia, NB] = Le_Dados('Dados\Dados_Iniciais.txt');
 
 [Custo, Plim] = ler_custo('Dados\custo_MW.txt');
 
 Perda = ler_perdas('Dados\perdas_MW.txt');

 Prioridades = ler_prioridade('Dados\Lista_Prioridade.txt');

 numero_de_teste = length(Prioridades(:,1));

   %tolerancia para convergencia
   tolerancia = 0.1;
   
for i = 1: qi_dia
    
      hora=(i*24/qi_dia);horaf=fix(hora);
      minuto=(hora-fix(hora))*60;minr=round(minuto);
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
     
      hora_tot = strcat(int2str(NB),'_',int2str(i),'_',horas,mins);
   

     [Caso Barra Ramo M N] = ler_sistema(strcat('Carga\ieee',hora_tot,'.txt'));

   if hora ~= 19

     Busger = identifica_busger(Barra);

     
     teste.Despacho = [];
     teste.Custo = [];
    for i = 1:numero_de_teste

     [Busger_despacho, Custo_atual, Perda_atual] = minimiza_custo(Custo,Busger,Barra,Perda,tolerancia,Plim,Prioridades(i,:));
         for k = 1:length(Busger_despacho.MW)
             teste.Despacho(i,k) = Busger_despacho.MW(k);        
         end
         teste.Custo(i) = Custo_atual + Perda_atual;
    end

    %Verifica a posição e o valor do custo minimo

    [Custo_min position] = min(teste.Custo);

    %Despacho minimo com o comissionamento
    format short
     Despacho_min_com = teste.Despacho(position,1:length(Busger_despacho.numbar))';
     [Busger_despacho.numbar' Despacho_min_com];


     %Atualiza o Barra.ger_MW com o despacho ótimo obtido
     for i = 1:length(Barra.num)
        procura_bus = find(Busger_despacho.numbar == Barra.num(i));
         if ~isempty(procura_bus)
             Barra.ger_MW(i) = Despacho_min_com(procura_bus);
         else
             Barra.ger_MW(i) = 0.0;
         end    
     end
   end
     Escreve_Despacho(Barra,hora_tot)
     
     
end
 
 