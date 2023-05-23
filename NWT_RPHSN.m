% Desenvolvido por: Wellyngton Soares e Daniel Veloso
% Email: wsoares@id.uff.br
% Inicialização das Potências e Tensões nas Barras
clear('Vm');clear('Vang');clear('J');clear('P');clear('DP');clear('V');
clear('Q');clear('DQ');clear('J11');clear('J12');clear('J21');clear('J22');
clear('BDP');clear('BDQ');
k=1;
%Ssch(1:k_BUS,k)=((D_BUS(1:k_BUS,7)+1i*D_BUS(1:k_BUS,8))-(D_BUS(1:k_BUS,5)+1i*D_BUS(1:k_BUS,6)))/Sb;
%Ssch(1:k_BUS,k)=(-(D_BUS(1:k_BUS,5)+1i*D_BUS(1:k_BUS,6)))/Sb;
% Tensão e Ângulo de Referência
for m=1:k_BUS
    if D_BUS(m,2)==3
        Vref=D_BUS(m,17);
        Aref=D_BUS(m,4)*pi/180;
    end
end
% Potências esperadas, Tensões e Ângulos iniciais das Barras 
for m=1:k_BUS
    if D_BUS(m,2)==2
        Ssch(m,1)=((D_BUS(m,7))-(D_BUS(m,5)))/Sb;
        Vm(m,k)=D_BUS(m,17);
        Vang(m,k)=Aref;
    elseif D_BUS(m,2)==3
        Ssch(m,1)=0;
        Vm(m,k)=D_BUS(m,17);
        Vang(m,k)=Aref;
    else
        Ssch(m,1)=((D_BUS(m,7)+1i*D_BUS(m,8))-(D_BUS(m,5)+1i*D_BUS(m,6)))/Sb;
        Vm(m,k)=Vref;
        Vang(m,k)=Aref;
    end
end
% Cálculo Newton Raphson
vls(1:k_BUS)=0;vli(1:k_BUS)=0;
while k<=maxiter
    ap=0;aq=0;
    NPQ=0;NPV=0;
    clear('aDQ');clear('aDP');
    for m=1:k_BUS
        a=D_BUS(m,14);b=D_BUS(m,15);c=D_BUS(m,16);
        Pzip=(a+b*Vm(m,k)+c*(Vm(m,k))^2)*real(Ssch(m,1));
        Qzip=(a+b*Vm(m,k)+c*(Vm(m,k))^2)*imag(Ssch(m,1));
        Psom=0;
        for n=1:k_BUS
            if n~=m
                Psom=Psom+Vm(m,k)*Vm(n,k)*abs(YB(m,n))*cos(angle(YB(m,n))+Vang(n,k)-Vang(m,k));
            end
        end
        P(m,k)=(Vm(m,k)^2)*real(YB(m,m))+Psom;
        DP(m,k)=Pzip-P(m,k);
        Qsom=0;
        for n=1:k_BUS
            if n~=m
                Qsom=Qsom+Vm(m,k)*Vm(n,k)*abs(YB(m,n))*sin(angle(YB(m,n))+Vang(n,k)-Vang(m,k));
            end
        end
        Q(m,k)=-(Vm(m,k)^2)*imag(YB(m,m))-Qsom;
        % Verificação dos limites de reativos das Barras PV
        if (Q(m,k)+D_BUS(m,6)/Sb)>(D_BUS(m,10)/Sb) && D_BUS(m,2)==2 && k>2 && vls(m)~=2
            Qzip=(D_BUS(m,10)/Sb)-(D_BUS(m,6)/Sb);
            Ssch(m,1)=Ssch(m,1)+1i*Qzip;
            D_BUS(m,2)=1;
            vls(m)=1;
        elseif (Q(m,k)+D_BUS(m,6)/Sb)<(D_BUS(m,11)/Sb) && D_BUS(m,2)==2 && k>2 && vli(m)~=2
            Qzip=(D_BUS(m,11)/Sb)-(D_BUS(m,6)/Sb);
            Ssch(m,1)=Ssch(m,1)+1i*Qzip;
            D_BUS(m,2)=1;
            vli(m)=1;
        end
        if D_BUS(m,2)==1 && Vm(m,k)>D_BUS(m,17) && vls(m)==1
            Vm(m,k)=D_BUS(m,17);
            Qzip=imag(Ssch(m,1));
            D_BUS(m,2)=2;
            vls(m)=2;
        elseif D_BUS(m,2)==1 && Vm(m,k)<D_BUS(m,17) && vli(m)==1
            Vm(m,k)=D_BUS(m,17);
            Qzip=imag(Ssch(m,1));
            D_BUS(m,2)=2;
            vli(m)=2;
        end
        DQ(m,k)=Qzip-Q(m,k);
        if D_BUS(m,2)==0 || D_BUS(m,2)==1
            NPQ=NPQ+1;
            ap=ap+1;aq=aq+1;
            aDP(ap)=DP(m,k);aDQ(aq)=DQ(m,k);
        elseif D_BUS(m,2)==2
            NPV=NPV+1;
            ap=ap+1;
            aDP(ap)=DP(m,k);
        end
    end
    if NPQ~=0
       if max(abs(aDP))<accry && max(abs(aDQ))<accry
           break
       end
    else
        if max(abs(aDP))<accry
           break
       end
    end
    mj11=0;
    for m=1:k_BUS
        if D_BUS(m,2)~=3
            mj11=mj11+1;
            BDP(mj11,1)=DP(m,k);
            nj11=0;
            for n=1:k_BUS
                if n~=m && D_BUS(n,2)~=3
                    nj11=nj11+1;
                    J11(mj11,nj11)=-Vm(m,k)*Vm(n,k)*abs(YB(m,n))*sin(angle(YB(m,n))+Vang(n,k)-Vang(m,k));
                elseif n==m && D_BUS(n,2)~=3
                    nj11=nj11+1;
                    J11(mj11,nj11)=-Q(m,k)-(Vm(m,k)^2)*imag(YB(m,n));   
                end
            end
        end
    end
    mj12=0;
    for m=1:k_BUS
        if D_BUS(m,2)~=3
            b=D_BUS(m,15);c=D_BUS(m,16);
            mj12=mj12+1;
            nj12=0;
            for n=1:k_BUS                
                if n~=m && D_BUS(n,2)~=3 && D_BUS(n,2)~=2
                    nj12=nj12+1;
                    J12(mj12,nj12)=Vm(m,k)*abs(YB(m,n))*cos(angle(YB(m,n))+Vang(n,k)-Vang(m,k));
                elseif n==m && D_BUS(n,2)~=3 && D_BUS(n,2)~=2
                    nj12=nj12+1;
                    dzip12=-(b+2*c*Vm(m,k))*real(Ssch(m));
                    J12(mj12,nj12)=dzip12+(P(m,k)/Vm(m,k))+Vm(m,k)*real(YB(m,n));   
                end
            end
        end
    end
    mj21=0;
    for m=1:k_BUS
        if D_BUS(m,2)~=3 && D_BUS(m,2)~=2
            mj21=mj21+1;
            BDQ(mj21,1)=DQ(m,k);
            nj21=0;
            for n=1:k_BUS
                if n~=m && D_BUS(n,2)~=3
                    nj21=nj21+1;
                    J21(mj21,nj21)=-Vm(m,k)*Vm(n,k)*abs(YB(m,n))*cos(angle(YB(m,n))+Vang(n,k)-Vang(m,k));
                elseif n==m && D_BUS(n,2)~=3
                    nj21=nj21+1;
                    J21(mj21,nj21)=P(m,k)-(Vm(m,k)^2)*real(YB(m,n));
                end
            end
        end
    end               
    mj22=0;
    for m=1:k_BUS
        if D_BUS(m,2)~=2 && D_BUS(m,2)~=3
            b=D_BUS(m,15);c=D_BUS(m,16);
            mj22=mj22+1;
            nj22=0;
            for n=1:k_BUS
                if n~=m && D_BUS(n,2)~=2 && D_BUS(n,2)~=3
                    nj22=nj22+1;
                    J22(mj22,nj22)=-Vm(m,k)*abs(YB(m,n))*sin(angle(YB(m,n))+Vang(n,k)-Vang(m,k));
                elseif n==m && D_BUS(n,2)~=2 && D_BUS(n,2)~=3
                    nj22=nj22+1;
                    dzip22=-(b+2*c*Vm(m,k))*imag(Ssch(m));
                    J22(mj22,nj22)=dzip22+(Q(m,k)/Vm(m,k))-Vm(m,k)*imag(YB(m,n));
                end
            end
        end
    end
    mdp=0;
    if NPQ==0
        J(:,:)=[J11(1:mj11,1:nj11)];
        B=[BDP];
    else
        J(:,:)=[J11(1:mj11,1:nj11) J12(1:mj12,1:nj12);J21(1:mj21,1:nj21) J22(1:mj22,1:nj22)];
        B=[BDP;BDQ];
    end
    clear('L');clear('D');clear('U');clear('X');
    [L,D,U]=FAT_LDU (J);
    [X]=SOLVE_LDU(L,D,U,B);
    clear('J');
    mx=0;
    for m=1:k_BUS
        if D_BUS(m,2)==3
            Vang(D_BUS(m,1),k+1)=Aref;
        else
            mx=mx+1;
            Vang(m,k+1)=Vang(m,k)+X(mx);
        end
    end
    for m=1:k_BUS
        if D_BUS(m,2)==2 || D_BUS(m,2)==3
            Vm(D_BUS(m,1),k+1)=D_BUS(m,17);
        elseif D_BUS(m,2)==0 || D_BUS(m,2)==1
            mx=mx+1;
            Vm(m,k+1)=Vm(m,k)+X(mx);
        end
    end
   k=k+1;
end
% Cálculo das Potências de Carga e Gerador
if k>maxiter
    pk=k-1;
    fprintf('\n## NÃO CONVERGIU EM 20 ITERAÇÕES');
    fprintf('\n## HORÁRIO => %s:%s\n',horas,mins);
else
    pk=k;
end
% Tensão Complexa
V(1:k_BUS)=Vm(1:k_BUS,k).*(cos(Vang(1:k_BUS,k))+1i*sin(Vang(1:k_BUS,k)));
% EVT, SL e SG
PG(1:k_BUS)=0;PL(1:k_BUS)=0;
QG(1:k_BUS)=0;QL(1:k_BUS)=0;
for m=1:k_BUS
    Vcdf(m)=D_BUS(m,3)*exp(1i*(D_BUS(m,4)*pi/180));
    EVT(m)=100*sqrt((((real(V(m))-real(Vcdf(m)))^2)+((imag(V(m))-imag(Vcdf(m)))^2))/((real(Vcdf(m))^2)+(imag(Vcdf(m))^2)));
    if D_BUS(m,2)==3
        PL(m)=D_BUS(m,5);
        PG(m)=P(m,pk)*Sb+PL(m);
        QL(m)=D_BUS(m,6);
        QG(m)=Q(m,pk)*Sb+QL(m);
    elseif D_BUS(m,2)==2
        PL(m)=D_BUS(m,5);
        PG(m)=abs(P(m,pk)*Sb+PL(m));
        QL(m)=D_BUS(m,6);
        QG(m)=Q(m,pk)*Sb+QL(m);
    elseif (D_BUS(m,2)==0 || D_BUS(m,2)==1)
        PL(m)=D_BUS(m,5);
        PG(m)=P(m,pk)*Sb+PL(m);
        QL(m)=D_BUS(m,6);
        QG(m)=Q(m,pk)*Sb+QL(m);
    end
end
% Cálculo das Correntes de Linha e Fluxo de Potência
for m=1:k_BRANCH
    if D_BRANCH(m,1)~=0 && D_BRANCH(m,2)~=0
        t=D_BRANCH(m,6);fi=D_BRANCH(m,7);
        ykm=1/(D_BRANCH(m,3)+1i*D_BRANCH(m,4));
        tap=t*exp(1i*fi);
        Ifd(m)=(ykm/(t^2))*V(D_BRANCH(m,1))-(ykm/tap)*V(D_BRANCH(m,2))+V(D_BRANCH(m,1))*1i*D_BRANCH(m,5);
        Ifi(m)=-(ykm/conj(tap))*V(D_BRANCH(m,1))+ykm*V(D_BRANCH(m,2))+V(D_BRANCH(m,2))*1i*D_BRANCH(m,5);
        Sfd(m)=V(D_BRANCH(m,1))*conj(Ifd(m))*Sb;
        Sfi(m)=V(D_BRANCH(m,2))*conj(Ifi(m))*Sb;
        Sloss(m)=Sfd(m)+Sfi(m);
    end
end
% Grandezas temporais complexas
Vt(1:k_BUS,im)=V(1:k_BUS); %tensão
Ifdt(1:NLO,im)=Ifd(1:NLO);Ifit(1:NLO,im)=Ifi(1:NLO); %corrente
Pt(1:k_BUS,im)=P(1:k_BUS,pk);Qt(1:k_BUS,im)=Q(1:k_BUS,pk); %injeção
Sfdt(1:NLO,im)=Sfd(1:NLO);Sfit(1:NLO,im)=Sfi(1:NLO); %flow
% Relatório
fprintf(ArqSF,'\n  ***************** RESULTADOS - FLUXO DE POTÊNCIA **********************\n');
fprintf(ArqSF,'\n                      MÉTODO NEWTON RAPHSON              \n');
fprintf(ArqSF,'\n\n#####   HORÁRIO   => %s:%s\n',horas,mins);
    fprintf(ArqSF,'#####   INTERVALO => %i\n',im);
fprintf(ArqSF,'\n  NUMEROS DE BARRAS:\t%i\n',k_BUS);
fprintf(ArqSF,'  NUMEROS DE LINHAS:\t%i\n',NLO);
fprintf(ArqSF,'  QT. ITERAÇÕES:\t%i\n\n',k-1);
fprintf(ArqSF,'  TENSÃO E POTÊNCIA POR BARRA\n');

fprintf(ArqSF,' -----------------------------------------------------------\n');
fprintf(ArqSF,' Barra Tensão  Ângulo      --Carga--       --Gerador-- \n');
fprintf(ArqSF,'       (pu)    (grau)      MW      MVar     MW      MVar  \n');
fprintf(ArqSF,' ------------------------------------------------------------\n');
for m=1:k_BUS
 fprintf(ArqSF,' %4i  %5.3f  %7.2f  %7.2f  %7.2f  %7.2f  %7.2f\n',m,Vm(m,k),Vang(m,k)*180/pi,PL(m),QL(m),PG(m),QG(m));
end 
fprintf(ArqSF,'\n             Total->   %7.2f  %7.2f  %7.2f  %7.2f\n',sum(PL),sum(QL),sum(PG),sum(QG));
fprintf(ArqSF,'\n  CORRENTE e FLUXO DE POTÊNCIA POR LINHA\n');                                                    
fprintf(ArqSF,'-----------------------------------------------------------------------------------------\n');
fprintf(ArqSF,' De Para  I(pu) Ângulo     FLUXO DIRETO     FLUXO INVERSO      PERDAS\n'); 
fprintf(ArqSF,'                (grau)     MW   -> MVar     MW   <- MVar    MW      MVar \n');
fprintf(ArqSF,'-----------------------------------------------------------------------------------------\n');
for m=1:k_BRANCH
 if D_BRANCH(m,1)~=0 && D_BRANCH(m,2)~=0
  fprintf(ArqSF,'%3i %3i %7.3f %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f\n',D_BRANCH(m,1),D_BRANCH(m,2),abs(Ifd(m)),angle(Ifd(m))*180/pi,real(Sfd(m)),imag(Sfd(m)),real(Sfi(m)),imag(Sfi(m)),real(Sloss(m)),imag(Sloss(m)));
 end
end
  fprintf(ArqSF,'                                        Total Perdas -> %7.2f %7.2f\n',sum(real(Sloss)),sum(imag(Sloss)));
if strcmp(horas,'19') && strcmp(mins,'00')
  fprintf(ArqEVT,'### EVT (%%) - ENTRE CDF E FLUXO CALCULADO DAS 19 hrs\n');
  fprintf(ArqEVT,'------------------------------------------------------------\n');
  fprintf(ArqEVT,'         CDF          Calculado\n');
  fprintf(ArqEVT,'Barra  V     Ângulo   V     Ângulo EVT(%%)\n');
  fprintf(ArqEVT,'      (pu)   (grau)  (pu)   (grau)\n');
  fprintf(ArqEVT,'------------------------------------------------------------\n');
  for m=1:k_BUS
    fprintf(ArqEVT,'%3i  %5.3f %7.2f  %5.3f %7.2f %5.2f\n',m,Vm(m,k),Vang(m,k)*180/pi,D_BUS(m,3),D_BUS(m,4),EVT(m));
  end
    fprintf(ArqEVT,'                  EVT(%%) MÉDIO -> %5.2f',sum(EVT)/k_BUS);
end
        
    