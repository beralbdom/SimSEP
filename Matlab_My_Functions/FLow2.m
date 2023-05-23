function [Caso, Barra, Ramo] = Flow2(M,N)

% --------------------------------------------------- %
%%% -------------------- F L O W ------------------ %%%
% --------------------------------------------------- %

%%% Entrada de dados: leitura da matriz M - RAMOS  %%%%
 

M=[Ramo.de Ramo.para Ramo.area Ramo.zona Ramo.circuito Ramo.tipo Ramo.r Ramo.x Ramo.b Ramo.rat_1 Ramo.rat_2 Ramo.rat_3 Ramo.barra_ctrl Ramo.lado Ramo.rel_tr Ramo.ang_tr Ramo.tap_min Ramo.tap_max Ramo.step Ramo.lim_min Ramo.lim_max];
    
NR=size(M);
B=zeros(NR(1),4); % B é uma matriz de dimensão "NR(1)x4", onde NR(1) corresponde ao número de linhas da matriz M
for ii=1:NR(1)
  if M(ii,15)==0 
    M(ii,15)=1;
    B(ii,1)=M(ii,7)+M(ii,8)*i;
  else
    B(ii,1)=1/((1/(M(ii,7)+M(ii,8)*i))/M(ii,15));                          %% ORIGINAL TAP CONSIDERATION (t) on M(i,15) Modeled with 1:a on i bus
    B(ii,4)=(1/(M(ii,7)+M(ii,8)*i))*(1-1/M(ii,15));                        %% j
    B(ii,3)=(1/(M(ii,7)+M(ii,8)*i))*(1/M(ii,15)-1)/M(ii,15);               %% i
  end
  B(ii,2)=1/B(ii,1);
end

%%% Entrada de dados: leitura da matriz N "BUS" %%%%

N=[Barra.num Barra.T Barra.area Barra.zona Barra.tipo Barra.tensao Barra.angulo Barra.carga_MW Barra.carga_MVAR Barra.ger_MW Barra.ger_MVAR Barra.kVBase Barra.tensao_inic Barra.lim_max Barra.lim_min Barra.g Barra.b Barra.ctrl_rem];

NBaux=size(N);NB=NBaux(1);tolerancia=0.0001;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% MONTANDO A Ybus %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ybus=zeros(NB(1),NB(1));bsh=Ybus;TAP=Ybus+1;
for jj=1:NR(1)
  bsh(M(jj,1),M(jj,2))=M(jj,9)/2;                                          %%  Shunt Linha ?
  bsh(M(jj,2),M(jj,1))=M(jj,9)/2;                                          %%  Shunt Linha ?
  TAP(M(jj,1),M(jj,2))=M(jj,15);
  TAP(M(jj,2),M(jj,1))=M(jj,15);  
  Ybus(M(jj,1),M(jj,2))=-B(jj,2);                                          %%  Elementos fora da Diagonal
  Ybus(M(jj,2),M(jj,1))=-B(jj,2);                                          %%  Elementos fora da Diagonal
  Ybus(M(jj,1),M(jj,1))=Ybus(M(jj,1),M(jj,1))+B(jj,2)+(M(jj,9)/2)*i+B(jj,3);   %%  soma das y chegando na barra + Shunt Linha + tap
  Ybus(M(jj,2),M(jj,2))=Ybus(M(jj,2),M(jj,2))+B(jj,2)+(M(jj,9)/2)*i+B(jj,4);   %%  soma das y chegando na barra + Shunt Linha + tap
end
for k=1:NB(1)
  Ybus(k,k)=Ybus(k,k)+(N(k,16)+N(k,17)*i);                                 %%  Aterramento de Barras
end
Gbus=real(Ybus);Bbus=imag(Ybus);Sbase=100;                                 %% Gbus = parte real dos elementos da Ybus; Bbus = parte imaginária da Ybus

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% PREPARANDO NEWTON RAPHSON DESACOPLADO %%%%%%%%%%%%%%%%%%%%%
% P em N col 10-8 // Q col 11-9 ?? // v col 13 // t col 7 // tipo barra col 5 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nt=0;nv=0;cont=0;
for k=1:NB
  if N(k,5)==3 
    v(k)=N(k,13);t(k)=N(k,7);P(k)=0;Q(k)=0;
  else
    if N(k,5)==2 
      v(k)=N(k,13);t(k)=0;P(k)=(N(k,10)-N(k,8))/Sbase;Q(k)=0;
      nt=nt+1;indice(nt)=N(k,1);
    else
      v(k)=1;t(k)=0;P(k)=(N(k,10)-N(k,8))/Sbase;Q(k)=(N(k,11)-N(k,9))/Sbase;
      nt=nt+1;nv=nv+1;indice(nt)=N(k,1);
    end
  end
end
for k = 1:NB
  if N(k,5)==0 
    cont=cont+1;
    indice(nt+cont)=N(k,1);
  end
end
Pca=zeros(NB,1); Qca=zeros(NB,1);
dt=zeros(NB,1); dv=zeros(NB,1);
teta=zeros(NB,1); tensao=zeros(NB,1); potat=zeros(NB,1); potre=zeros(NB,1);
iter=0 ; saida=0;
dP=zeros(nt,1); dQ=zeros(nv,1);
dpotat=zeros(nt,1); dpotre=zeros(nv,1); deltateta=zeros(nt,1); deltatensao=zeros(nv,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% NEWTON RAPHSON DESACOPLADO %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

relogio = clock;
inicio_NRD = sprintf('%dh%dmin',relogio(4),relogio(5));  % essa linha corresponde ao comando "getdate()" no scilab

while (saida==0)
  iter=iter+1;
  H1=zeros(nt,nt);
  L1=zeros(nv,nv);
% inicio_H(iter,:)=getdate();
inicio_H = sprintf('%dh%dmin',relogio(4),relogio(5)); % essa linha corresponde ao comando "getdate()" no scilab
% H e dP %
  for linha = 1:nt
      for coluna = 1:nt
        if linha == coluna 
          for jj=1:NB
          H1(linha,coluna)=H1(linha,coluna)+v(jj)*(-Gbus(indice(linha),jj)*sin(t(indice(linha))-t(jj))+Bbus(indice(linha),jj)*cos(t(indice(linha))-t(jj)));
          end
          H1(linha,coluna)=H1(linha,coluna)*v(indice(linha))-(v(indice(linha))^2)*Bbus(indice(linha),indice(linha));
        else
          H1(linha,coluna)=v(indice(linha))*v(indice(coluna))*(Gbus(indice(linha),indice(coluna))*sin(t(indice(linha))-t(indice(coluna)))-Bbus(indice(linha),indice(coluna))*cos(t(indice(linha))-t(indice(coluna))));
        end
      end
    end
  %fim_H(iter,:)=getdate();
   fim_H = sprintf('%dh%dmin',relogio(4),relogio(5)); 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for linha=1:nt
    Pca(indice(linha))=0;
    for jj=1:NB
      Pca(indice(linha))=Pca(indice(linha))+v(jj)*(Gbus(indice(linha),jj)*cos(t(indice(linha))-t(jj))+Bbus(indice(linha),jj)*sin(t(indice(linha))-t(jj)));
    end
    Pca(indice(linha))=Pca(indice(linha))*v(indice(linha));
    dP(linha)=P(indice(linha))-Pca(indice(linha));
  end
  dt=inv(H1)*dP;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Q(v) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %inicio_L(iter,:)=getdate();
  inicio_L = sprintf('%dh%dmin',relogio(4),relogio(5));
  for linha = 1:nv
    for coluna = 1:nv
      if linha== coluna 
        for jj = 1:NB
          L1(linha,coluna)=L1(linha,coluna)+v(jj)*(Gbus(indice(linha+nt),jj)*sin(t(indice(linha+nt))-t(jj))-Bbus(indice(linha+nt),jj)*cos(t(indice(linha+nt))-t(jj)));
        end
        L1(linha,coluna)=L1(linha,coluna)-v(indice(linha+nt))*Bbus(indice(linha+nt),indice(linha+nt));
      else
        L1(linha,coluna)=(Gbus(indice(linha+nt),indice(coluna+nt))*sin(t(indice(linha+nt))-t(indice(coluna+nt)))-Bbus(indice(linha+nt),indice(coluna+nt))*cos(t(indice(linha+nt))-t(indice(coluna+nt))));
        L1(linha,coluna)=L1(linha,coluna)*v(indice(linha+nt));
      end
    end
  end
  %fim_L(iter,:)=getdate();
  fim_L = sprintf('%dh%dmin',relogio(4),relogio(5));
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for linha=1:nv
    Qca(indice(linha+nt))=0;
    for jj=1:NB
      Qca(indice(linha+nt))=Qca(indice(linha+nt))+v(jj)*(Gbus(indice(linha+nt),jj)*sin(t(indice(linha+nt))-t(jj))-Bbus(indice(linha+nt),jj)*cos(t(indice(linha+nt))-t(jj)));
    end
    Qca(indice(linha+nt))=Qca(indice(linha+nt))*v(indice(linha+nt));
    dQ(linha)=Q(indice(linha+nt))-Qca(indice(linha+nt));
  end
  dv=inv(L1)*dQ;

%%%%%%%%%%%%%%%%%%%% Armazenamento das iterações %%%%%%%%%%%%%%%%%%%%%%%%%%
  teta(:,iter)=t;  tensao(:,iter)=v;  potat(:,iter)=Pca;  potre(:,iter)=Qca;  dpotat(:,iter)=dP;
  dpotre(:,iter)=dQ;  deltateta(:,iter)=dt;  deltatensao(:,iter)=dv;
  
%%%%%%%%%%%%%%%%%%%%%%%% Atualização do Estado %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for ii=1:nt
    t(indice(ii))=t(indice(ii))+dt(ii);
  end
  for jj=1:nv
    v(indice(jj+nt))=v(indice(jj+nt))+dv(jj);
  end
  
%%%%%%%%%%%%%%%%%%%%%%%%%% Critério de parada %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (max(abs(dP))<tolerancia) 
    if (max(abs(dQ))<tolerancia) 
     saida=1;
    end
  end
  if iter==100  
    saida=1;
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% SAÍDA DE DADOS DO ESTADO %%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%fim_NRD=getdate();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LOAD FLOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for linha=1:NB
  Pca(linha)=0;
  Qca(linha)=0;
  for jj=1:NB
    Pca(linha)=Pca(linha)+v(jj)*(Gbus(linha,jj)*cos(t(linha)-t(jj))+Bbus(linha,jj)*sin(t(linha)-t(jj)));
    Qca(linha)=Qca(linha)+v(jj)*(Gbus(linha,jj)*sin(t(linha)-t(jj))-Bbus(linha,jj)*cos(t(linha)-t(jj)));
  end
  Pca(linha)=Pca(linha)*v(linha);
  Qca(linha)=Qca(linha)*v(linha);
end
IlinhaA=zeros(14,14);
for ii=1:NB
  for jj=ii:NB
    fluxosP(ii,jj)=-(Gbus(ii,jj)/TAP(ii,jj))*(v(ii)^2)-v(ii)*v(jj)*(-Gbus(ii,jj)*cos(t(ii)-t(jj))-Bbus(ii,jj)*sin(t(ii)-t(jj)));
    fluxosP(jj,ii)=-(Gbus(jj,ii)*TAP(jj,ii))*(v(jj)^2)-v(jj)*v(ii)*(-Gbus(jj,ii)*cos(t(jj)-t(ii))-Bbus(jj,ii)*sin(t(jj)-t(ii)));
    fluxosQ(ii,jj)=-((-Bbus(ii,jj)/TAP(ii,jj))+bsh(ii,jj))*(v(ii)^2)-v(ii)*v(jj)*(-Gbus(ii,jj)*sin(t(ii)-t(jj))+(Bbus(ii,jj))*cos(t(ii)-t(jj)));
    fluxosQ(jj,ii)=-((-Bbus(jj,ii)*TAP(jj,ii))+bsh(jj,ii))*(v(jj)^2)-v(jj)*v(ii)*(-Gbus(jj,ii)*sin(t(jj)-t(ii))+(Bbus(jj,ii))*cos(t(jj)-t(ii)));
    IlinhaM(ii,jj)=((fluxosP(ii,jj)^2+fluxosQ(ii,jj)^2)^0.5)/(v(ii));
    IlinhaM(jj,ii)=((fluxosP(jj,ii)^2+fluxosQ(jj,ii)^2)^0.5)/(v(jj));
    if fluxosQ(ii,jj)>=0                                                            %% Quadrantes 1 e 2
      if IlinhaM(ii,jj)~=0
        IlinhaA(ii,jj)=-acos(fluxosP(ii,jj)/(IlinhaM(ii,jj)*v(ii)))+(t(ii));
      end
    end
    if fluxosQ(ii,jj)<0                                                             %% Quadrante 3 e 4
        %if fluxosP(i,j)<=0
          if IlinhaM(ii,jj)~=0
            IlinhaA(ii,jj)=acos(fluxosP(ii,jj)/(IlinhaM(ii,jj)*v(ii)))+(t(ii));
          end
        %end
    end
    if fluxosQ(jj,ii)>=0                                                            %% Quadrantes 1 e 2
      if IlinhaM(jj,ii)~=0
        IlinhaA(jj,ii)=-acos(fluxosP(jj,ii)/(IlinhaM(jj,ii)*v(jj)))+(t(jj));
      end
    end
    if fluxosQ(jj,ii)<0                                                             %% Quadrante 3 e 4
        %if fluxosP(j,i)<=0
          if IlinhaM(jj,ii)~=0
            IlinhaA(jj,ii)=acos(fluxosP(jj,ii)/(IlinhaM(jj,ii)*v(jj)))+(t(jj));
          end
        %end
    end
    Ilinha(ii,jj)=IlinhaM(ii,jj)*cos(IlinhaA(ii,jj))+IlinhaM(ii,jj)*sin(IlinhaA(ii,jj))*i;
    Ilinha(jj,ii)=IlinhaM(jj,ii)*cos(IlinhaA(jj,ii))+IlinhaM(jj,ii)*sin(IlinhaA(jj,ii))*i;
  end
end
Qa=sum(fluxosQ,2);
Pa=sum(fluxosP,2);
for ii=1:NR(1)
  fluxo(ii,1)=M(ii,1);                     %% de
  fluxo(ii,2)=M(ii,2);                     %% para
  fluxo(ii,3)=fluxosP(M(ii,1),M(ii,2));    %% Pij
  fluxo(ii,4)=fluxosQ(M(ii,1),M(ii,2));    %% Qij
  fluxo(ii,5)=fluxosP(M(ii,2),M(ii,1));    %% Pji
  fluxo(ii,6)=fluxosQ(M(ii,2),M(ii,1));    %% Qji
  fluxo(ii,7)=IlinhaM(M(ii,1),M(ii,2));    %% IijMODULO
  fluxo(ii,8)=IlinhaA(M(ii,1),M(ii,2));    %% IijANGULO
  fluxo(ii,9)=IlinhaM(M(ii,2),M(ii,1));    %% IjiMODULO
  fluxo(ii,10)=IlinhaA(M(ii,2),M(ii,1));   %% IjiANGULO
  fluxo(ii,11)=Ilinha(M(ii,1),M(ii,2));    %% IijCARTESIANO
  fluxo(ii,12)=Ilinha(M(ii,2),M(ii,1));    %% IjiCARTESIANO
end
I=sum(Ilinha,2);