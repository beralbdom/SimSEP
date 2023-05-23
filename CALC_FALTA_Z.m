function [ZB1,NB1,ZB0,NB0,Ifabcpu,Vabcpu,Iabcpu,Iseq0,Iseq1,Iseq2]=CALC_FALTA_Z(Bf,Vf,Tetaf,DirCDF,DirF,im,NB,qi_dia,ZB1,D_BUS1,k_BUS1,D_BRANCH1,k_BRANCH1,Tf)
 %tic
 % Inserção de caminho dos diretórios e nomes dos arquivos
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
 Arq_CDF_1=fopen(strcat(DirCDF,'ieee',int2str(NB),'_',int2str(im),'_',horas,mins,'.txt'),'r');
 PthD='D:\_UFF\2017.2\Analise de Defeitos\Projeto Disciplina\Dados\';       % Caminho para os arquivos com dados
 PthR='D:\_UFF\2017.2\Analise de Defeitos\Projeto Disciplina\Resultados\';  % Caminho para arquivo com Resultado
 %Arq_ENT='ARQ_ENTRADA.txt';                                                 % Arquivo com Dados de Entrada
 Arq_SAIDA=strcat('RELATORIO_FALTA_',int2str(NB),'_',horas,mins,'.txt');     % Arquivo com Resultados
 %Arq_CDF_1='ieee300cdf.txt';                                                % Arquivo CDF com sequências 1 e 2
 Arq_CDF_0='T2cdf_0.txt';                                                   % Arquivo CDF com sequência 0
 % Leitura e carga dos Dados de Entrada
 %ArqE1 = fopen(strcat(PthD,Arq_ENT), 'r');
 %Lin=fgetl(ArqE1);Lin=fgetl(ArqE1);Lin=fgetl(ArqE1);Lin=fgetl(ArqE1);Lin=fgetl(ArqE1);
 %LinD=regexp(Lin,'[-.\d]{1,7}','match');
 D_ENT(1)=Tf;                            % Tipo Falta (Falta Trifásicaou Bifásica)
 D_ENT(2)=Bf;                           % Barra Falta
 D_ENT(3)=0;                            % Resistência Falta
 D_ENT(4)=0;                            % Reatância Falta
 D_ENT(5)=Vf;                           % Módulo Tensão na Barra no momento da Falta
 D_ENT(6)=Tetaf*180/pi;                 % Ângulo Tensão na Barra no momento da Falta
 % Inicialização de constantes das componetes simétricas e Barras
 a=-.5+(1i*sqrt(3)/2);
 T=[1 1 1;1 a^2 a;1 a a^2];
 ZB0=[];NB0=[];
 % Cálculo das grandezas elétricas associadas ao tipo de Falta
 % ***** Falta Monofásica
 if D_ENT(1)==1                                                           
    Tip_Falta='FALTA MONOFÁSICA (FASE A)';
    [D_BUS1,k_BUS1,D_BRANCH1,k_BRANCH1,Sb1]=ADQ_CDF(PthD,Arq_CDF_1);     % Pega dados das sequência 1
    [ZB1,Zth1,NB1]=Z_BUS(D_BUS1,k_BUS1,D_BRANCH1,k_BRANCH1);             % Gera Zbus e Zth da sequência 1
    ZB2=ZB1;Zth2=Zth1;                                                   % Gera Zbus e Zth da sequência 2 (igual a 1)
    for kf1=1:k_BUS1
        if NB1(kf1)==D_ENT(2)                                            % Índice da barra com falta Seq. 1
            break
        elseif kf1==k_BUS1
            fprintf('\n *** BARRA NÃO ENCONTRADA! ***\n\n');
            ZB1=0;NB1=0;ZB0=0;NB0=0;Ifabcpu=0;Vabcpu=0;Iabcpu=0;Iseq0=0;Iseq1=0;Iseq2=0;
            return
        end
    end
    [D_BUS0,k_BUS0,D_BRANCH0,k_BRANCH0,Sb0]=ADQ_CDF(PthD,Arq_CDF_0);     % Pega dados da sequência 0
    [ZB0,Zth0,NB0]=Z_BUS(D_BUS0,k_BUS0,D_BRANCH0,k_BRANCH0);             % Gera Zbus e Zth da sequencia 0
    for kf0=1:k_BUS0
        if NB0(kf0)==D_ENT(2)                                            % Índice da barra com falta Seq. 0
            break
         elseif kf0==k_BUS0
            fprintf('\n *** BARRA NÃO ENCONTRADA! ***\n\n');
            ZB1=0;NB1=0;ZB0=0;NB0=0;Ifabcpu=0;Vabcpu=0;Iabcpu=0;Iseq0=0;Iseq1=0;Iseq2=0;
            return
        end
    end
    Zthr=Zth1(kf1,1)+Zth2(kf1,1)+Zth0(kf0,1);                            % Cálculo Zth resultante
    Zf=D_ENT(3)+1i*D_ENT(4);                                             % Impedância de Falta
    Vf1=D_ENT(5)*(cos(D_ENT(6)*pi/180)+1i*sin(D_ENT(6)*pi/180));         % Tensão de Falta (Seq. 1 - Complexa)
    Vf2=0;Vf0=0;                                                         % Tensões de Falta Seqs. 0 e 2
    If1=Vf1/(Zthr+3*Zf);                                                 % Corrente de Falta Seq. 1
    If0=If1;If2=If1;                                                     % Correntes de Falta Seqs. 0 e 2
    % Cálculo da Corrente de Falta Trifásica - fases a, b e c
    Ifabcpu=T*[If0;If1;If2];
    % Cálculo das Tensões por Barra Seqs. 1 e 2
    for m=1:k_BUS1
        Vb1(m)=Vf1-ZB1(m,kf1)*If1;                                         
        Vb2(m)=Vf2-ZB2(m,kf1)*If2;
    end
    % Cálculo das Tensões por Barra Seq. 0
    for m=1:k_BUS0
        Vb0(m)=Vf0-ZB0(m,kf0)*If0;                                         
    end
    % Cálculo das Tensões Trifásicas - fases a, b e c
    for m=1:k_BUS1
        Vabcpu(m,1:3)=T*[Vb0(m);Vb1(m);Vb2(m)];
    end
    % Cálculo das Correntes nos Ramos
    i_seq=0;
    for m=1:k_BRANCH1
        i_seq=i_seq+1;
        Nbrch(m,1)=D_BRANCH1(m,1);                 % Barra de Origem
        Nbrch(m,2)=D_BRANCH1(m,2);                 % Barra de Destino
        for n=1:k_BUS1                             % Índice barra Seqs. 1 e 2
            if Nbrch(m,1)==NB1(n)
                p=n;
            elseif Nbrch(m,2)==NB1(n)
                q=n;
            end
        end
        for n=1:k_BUS0                             % Índice barra Seq. 0
            if Nbrch(m,1)==NB0(n)
                p0=n;
            elseif Nbrch(m,2)==NB0(n)
                q0=n;
            end
        end
        if  Nbrch(m,1)~=0 && Nbrch(m,2)~=0
            Iseq1(m)=If1*((ZB1(q,kf1)-ZB1(p,kf1))/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
            Iseq2(m)=If2*((ZB1(q,kf1)-ZB1(p,kf1))/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
        elseif Nbrch(m,1)==0
            Iseq1(m)=If1*(ZB1(q,kf1)/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
            Iseq2(m)=If2*(ZB1(q,kf1)/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
        elseif Nbrch(m,2)==0
            Iseq1(m)=If1*(-ZB1(p,kf1)/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
            Iseq2(m)=If2*(-ZB1(p,kf1)/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
        end
        auxbr=0;
        for n=1:k_BRANCH0
            if Nbrch(m,1)==D_BRANCH0(n,1) && Nbrch(m,2)==D_BRANCH0(n,2)
                if  Nbrch(m,1)~=0 && Nbrch(m,2)~=0
                    Iseq0(m)=If0*((ZB0(q0,kf1)-ZB0(p0,kf1))/(D_BRANCH0(n,3)+1i*D_BRANCH0(n,4)));
                elseif Nbrch(m,1)==0
                    Iseq0(m)=If0*(ZB0(q0,kf1)/(D_BRANCH0(n,3)+1i*D_BRANCH0(n,4)));
                elseif Nbrch(m,2)==0
                    Iseq0(m)=If0*(-ZB0(p0,kf1)/(D_BRANCH0(n,3)+1i*D_BRANCH0(n,4)));
                end
                auxbr=1;
            elseif Nbrch(m,1)==D_BRANCH0(n,2) && Nbrch(m,2)==D_BRANCH0(n,1)
                if  Nbrch(m,1)~=0 && Nbrch(m,2)~=0
                    Iseq0(m)=-If0*((ZB0(q0,kf1)-ZB0(p0,kf1))/(D_BRANCH0(n,3)+1i*D_BRANCH0(n,4)));
                elseif Nbrch(m,1)==0
                    Iseq0(m)=-If0*(ZB0(q0,kf1)/(D_BRANCH0(n,3)+1i*D_BRANCH0(n,4)));
                elseif Nbrch(m,2)==0
                    Iseq0(m)=-If0*(-ZB0(p0,kf1)/(D_BRANCH0(n,3)+1i*D_BRANCH0(n,4)));
                end
                auxbr=1;
            elseif n==k_BRANCH0 && auxbr==0
                Iseq0(m)=0;
            end
        end
    end
    for m=1:k_BRANCH0
        for n=1:k_BRANCH1
            if (D_BRANCH0(m,1)==D_BRANCH1(n,1) && D_BRANCH0(m,2)==D_BRANCH1(n,2)) || (D_BRANCH0(m,1)==D_BRANCH1(n,2) && D_BRANCH0(m,2)==D_BRANCH1(n,1))
                break
            elseif n==k_BRANCH1
                i_seq=i_seq+1;
                Nbrch(i_seq,1)=D_BRANCH0(m,1);                 % Barra de Origem
                Nbrch(i_seq,2)=D_BRANCH0(m,2);                 % Barra de Destino
                Iseq1(i_seq)=0;Iseq2(i_seq)=0;
                for a=1:k_BUS0                                  % Índice barra Seq. 0
                    if D_BRANCH0(m,1)==NB0(a)
                        p0=a;
                    elseif D_BRANCH0(m,2)==NB0(a)
                        q0=a;
                    end
                end
                if  D_BRANCH0(m,1)~=0 && D_BRANCH0(m,2)~=0
                    Iseq0(i_seq)=If0*((ZB0(q0,kf1)-ZB0(p0,kf1))/(D_BRANCH0(m,3)+1i*D_BRANCH0(m,4)));
                elseif D_BRANCH0(m,1)==0
                    Iseq0(i_seq)=If0*(ZB0(q0,kf1)/(D_BRANCH0(m,3)+1i*D_BRANCH0(m,4)));
                elseif D_BRANCH0(m,2)==0
                    Iseq0(i_seq)=If0*(-ZB0(p0,kf1)/(D_BRANCH0(m,3)+1i*D_BRANCH0(m,4)));
                end
            end
        end    
    end
    for m=1:i_seq
        Iabcpu(m,1:3)=T*[Iseq0(m);Iseq1(m);Iseq2(m)];
    end
 % ***** Falta Trifásica    
 elseif D_ENT(1)==2                                                       
    Tip_Falta='FALTA TRIFÁSICA'; 
    fprintf('\n### CURTO CIRCUITO - %s NA BARRA %3i  as %s:%s',Tip_Falta,Bf,horas,mins);
    %[D_BUS1,k_BUS1,D_BRANCH1,k_BRANCH1,Sb1]=ADQ_CDF(Arq_CDF_1);     % Pega dados das sequência 1
    %[ZB1,Zth1,NB1]=Z_BUS(D_BUS1,k_BUS1,D_BRANCH1,k_BRANCH1);             % Gera Zbus e Zth da sequência 1
    NB1(1:k_BUS1)=D_BUS1(1:k_BUS1,1);
    for kf1=1:k_BUS1
        if NB1(kf1)==D_ENT(2)                                            % Índice da barra com falta Seq. 1
            break
         elseif kf1==k_BUS1
            fprintf('\n *** BARRA NÃO ENCONTRADA! ***\n\n');
            ZB1=0;NB1=0;ZB0=0;NB0=0;Ifabcpu=0;Vabcpu=0;Iabcpu=0;Iseq0=0;Iseq1=0;Iseq2=0;
            return           
        end
    end
    Zthr=ZB1(kf1,kf1);                                                    % Cálculo Zth resultante
    Zf=D_ENT(3)+1i*D_ENT(4);                                             % Impedância de Falta
    Vf1=D_ENT(5)*(cos(D_ENT(6)*pi/180)+1i*sin(D_ENT(6)*pi/180));         % Tensão de Falta (Seq. 1 - Complexa)
    Vf2=0;Vf0=0;                                                         % Tensões de Falta Seqs. 0 e 2
    If1=Vf1/(Zthr+Zf);                                                   % Corrente de Falta Seq. 1
    If0=0;If2=0;                                                         % Correntes de Falta Seqs. 0 e 2
    % Cálculo da Corrente de Falta Trifásica - fases a, b e c
    Ifabcpu=T*[If0;If1;If2];
    % Cálculo das Tensões por Barra Seqs. 0, 1 e 2
    for m=1:k_BUS1
        Vb0(m)=0;Vb2(m)=0;
        Vb1(m)=Vf1-ZB1(m,kf1)*If1;                                         
    end
    % Cálculo das Tensões Trifásicas Fases a, b e c
    for m=1:k_BUS1
        Vabcpu(m,1:3)=T*[Vb0(m);Vb1(m);Vb2(m)];
    end
    % Cálculo das Correntes nos Ramos
    i_seq=0;
    for m=1:k_BRANCH1
        i_seq=i_seq+1;
        Nbrch(m,1)=D_BRANCH1(m,1);                 % Barra de Origem
        Nbrch(m,2)=D_BRANCH1(m,2);                 % Barra de Destino
        for n=1:k_BUS1                             % Índice barra Seq. 1
            if Nbrch(m,1)==NB1(n)
                p=n;
            elseif Nbrch(m,2)==NB1(n)
                q=n;
            end
        end
        if  Nbrch(m,1)~=0 && Nbrch(m,2)~=0
            Iseq1(m)=If1*((ZB1(q,kf1)-ZB1(p,kf1))/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
        elseif Nbrch(m,1)==0
            Iseq1(m)=If1*(ZB1(q,kf1)/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
        elseif Nbrch(m,2)==0
            Iseq1(m)=If1*(-ZB1(p,kf1)/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
        end
        Iseq0(m)=0;
        Iseq2(m)=0;
    end
    for m=1:i_seq
        Iabcpu(m,1:3)=T*[Iseq0(m);Iseq1(m);Iseq2(m)];
    end
 % *****  Falta Bifásica
 elseif D_ENT(1)==3                                                       %Falta Bifásica
    Tip_Falta='FALTA BIFÁSICA (FASES B e C)';
    fprintf('\n### CURTO CIRCUITO - %s NA BARRA %3i  as %s:%s',Tip_Falta,Bf,horas,mins);
    %[D_BUS1,k_BUS1,D_BRANCH1,k_BRANCH1,Sb1]=ADQ_CDF(PthD,Arq_CDF_1);     % Pega dados das sequência 1
    %[ZB1,Zth1,NB1]=Z_BUS(D_BUS1,k_BUS1,D_BRANCH1,k_BRANCH1);             % Gera Zbus e Zth da sequência 1
    NB1(1:k_BUS1)=D_BUS1(1:k_BUS1,1);
    ZB2=ZB1;%Zth2=Zth1;                                                   % Gera Zbus e Zth da sequência 2 (igual a 1)
    for kf1=1:k_BUS1
        if NB1(kf1)==D_ENT(2)                                            % Índice da barra com falta Seq. 1
            break
         elseif kf1==k_BUS1
            fprintf('\n *** BARRA NÃO ENCONTRADA! ***\n\n');
            ZB1=0;NB1=0;ZB0=0;NB0=0;Ifabcpu=0;Vabcpu=0;Iabcpu=0;Iseq0=0;Iseq1=0;Iseq2=0;
            return
        end
    end
    Zthr=ZB1(kf1,kf1)+ZB2(kf1,kf1);                                       % Cálculo Zth resultante
    Zf=D_ENT(3)+1i*D_ENT(4);                                             % Impedância de Falta
    Vf1=D_ENT(5)*(cos(D_ENT(6)*pi/180)+1i*sin(D_ENT(6)*pi/180));         % Tensão de Falta (Seq. 1 - Complexa)
    Vf2=0;Vf0=0;                                                         % Tensões de Falta Seqs. 0 e 2
    If1=Vf1/(Zthr+Zf);                                                   % Corrente de Falta Seq. 1
    If0=0;If2=-If1;                                                      % Correntes de Falta Seqs. 0 e 2
    % Cálculo da Corrente de Falta Trifásica - fases a, b e c
    Ifabcpu=T*[If0;If1;If2];
    % Cálculo das Tensões por Barra Seqs. 0, 1 e 2
    for m=1:k_BUS1
        Vb0(m)=0;
        Vb1(m)=Vf1-ZB1(m,kf1)*If1;
        Vb2(m)=Vb1(m)-If1*Zf;
    end
    % Cálculo das Tensões Trifásicas fases a, b e c
    for m=1:k_BUS1
        Vabcpu(m,1:3)=T*[Vb0(m);Vb1(m);Vb2(m)];
    end
    % Cálculo das Correntes nos Ramos
    i_seq=0;
    for m=1:k_BRANCH1
        i_seq=i_seq+1;
        Nbrch(m,1)=D_BRANCH1(m,1);                 % Barra de Origem
        Nbrch(m,2)=D_BRANCH1(m,2);                 % Barra de Destino
        for n=1:k_BUS1                             % Índice barra Seq. 1
            if Nbrch(m,1)==NB1(n)
                p=n;
            elseif Nbrch(m,2)==NB1(n)
                q=n;
            end
        end
        if  Nbrch(m,1)~=0 && Nbrch(m,2)~=0
            Iseq1(m)=If1*((ZB1(q,kf1)-ZB1(p,kf1))/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
        elseif Nbrch(m,1)==0
            Iseq1(m)=If1*(ZB1(q,kf1)/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
        elseif Nbrch(m,2)==0
            Iseq1(m)=If1*(-ZB1(p,kf1)/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
        end
        Iseq0(m)=0;
        Iseq2(m)=-Iseq1(m);
    end
    for m=1:i_seq
        Iabcpu(m,1:3)=T*[Iseq0(m);Iseq1(m);Iseq2(m)];
    end
 % ***** Falta Bifásica Terra
 elseif D_ENT(1)==4                                                       
    Tip_Falta='FALTA BIFÁSICA TERRA (FASES B e C)';
    [D_BUS1,k_BUS1,D_BRANCH1,k_BRANCH1,Sb1]=ADQ_CDF(PthD,Arq_CDF_1);     % Pega dados das sequência 1
    [ZB1,Zth1,NB1]=Z_BUS(D_BUS1,k_BUS1,D_BRANCH1,k_BRANCH1);             % Gera Zbus e Zth da sequência 1
    ZB2=ZB1;Zth2=Zth1;                                                   % Gera Zbus e Zth da sequência 2 (igual a 1)
    for kf1=1:k_BUS1
        if NB1(kf1)==D_ENT(2)                                            % Índice da barra com falta Seq. 1
            break
        elseif kf1==k_BUS1
            fprintf('\n *** BARRA NÃO ENCONTRADA! ***\n\n');
            ZB1=0;NB1=0;ZB0=0;NB0=0;Ifabcpu=0;Vabcpu=0;Iabcpu=0;Iseq0=0;Iseq1=0;Iseq2=0;
            return            
        end
    end
    [D_BUS0,k_BUS0,D_BRANCH0,k_BRANCH0,Sb0]=ADQ_CDF(PthD,Arq_CDF_0);     % Pega dados da sequência 0
    [ZB0,Zth0,NB0]=Z_BUS(D_BUS0,k_BUS0,D_BRANCH0,k_BRANCH0);             % Gera Zbus e Zth da sequencia 0
    for kf0=1:k_BUS0
        if NB0(kf0)==D_ENT(2)                                            % Índice da barra com falta Seq. 0
            break
         elseif kf0==k_BUS0
            fprintf('\n *** BARRA NÃO ENCONTRADA! ***\n\n');
            ZB1=0;NB1=0;ZB0=0;NB0=0;Ifabcpu=0;Vabcpu=0;Iabcpu=0;Iseq0=0;Iseq1=0;Iseq2=0;
            return
        end
    end
    Zf=D_ENT(3)+1i*D_ENT(4);                                             % Impedância de Falta
    Vf1=D_ENT(5)*(cos(D_ENT(6)*pi/180)+1i*sin(D_ENT(6)*pi/180));         % Tensão de Falta (Seq. 1 - Complexa)
    Vf2=0;Vf0=0;                                                         % Tensões de Falta Seqs. 0 e 2
    aux=Zth2(kf1,1)+Zth0(kf0,1)+3*Zf;                                    % Inicio Cálculo Corrente
    If1=Vf1/(Zth1(kf1,1)+((Zth2(kf1,1)*(Zth0(kf0,1)+3*Zf))/aux));        % Corrente de Falta Seq. 1
    If2=-If1*((Zth0(kf0,1)+3*Zf)/aux);                                   % Corrente de Falta Seq. 2
    If0=-If1*(Zth2(kf1,1)/aux);                                          % Corrente de Falta Seq. 0
    % Cálculo da Corrente de Falta Trifásica - fases a, b e c
    Ifabcpu=T*[If0;If1;If2];
    % Cálculo das Tensões por Barra Seqs. 1 e 2
    for m=1:k_BUS1
        Vb1(m)=Vf1-ZB1(m,kf1)*If1;                                         
        Vb2(m)=Vf2-ZB2(m,kf1)*If2;
    end
    % Cálculo das Tensões por Barra Seq. 0
    for m=1:k_BUS0
        Vb0(m)=Vf0-ZB0(m,kf0)*If0;                                         
    end
    % Cálculo das Tensões Trifásicas fases a, b e c
    for m=1:k_BUS1
        Vabcpu(m,1:3)=T*[Vb0(m);Vb1(m);Vb2(m)];
    end
    % Cálculo das Correntes nos Ramos
    i_seq=0;
    for m=1:k_BRANCH1
        i_seq=i_seq+1;
        Nbrch(m,1)=D_BRANCH1(m,1);                 % Barra de Origem
        Nbrch(m,2)=D_BRANCH1(m,2);                 % Barra de Destino
        for n=1:k_BUS1                             % Índice barra Seqs. 1 e 2
            if Nbrch(m,1)==NB1(n)
                p=n;
            elseif Nbrch(m,2)==NB1(n)
                q=n;
            end
        end
        for n=1:k_BUS0                             % Índice barra Seq. 0
            if Nbrch(m,1)==NB0(n)
                p0=n;
            elseif Nbrch(m,2)==NB0(n)
                q0=n;
            end
        end
        if  Nbrch(m,1)~=0 && Nbrch(m,2)~=0
            Iseq1(m)=If1*((ZB1(q,kf1)-ZB1(p,kf1))/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
            Iseq2(m)=If2*((ZB1(q,kf1)-ZB1(p,kf1))/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
        elseif Nbrch(m,1)==0
            Iseq1(m)=If1*(ZB1(q,kf1)/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
            Iseq2(m)=If2*(ZB1(q,kf1)/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
        elseif Nbrch(m,2)==0
            Iseq1(m)=If1*(-ZB1(p,kf1)/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
            Iseq2(m)=If2*(-ZB1(p,kf1)/(D_BRANCH1(m,3)+1i*D_BRANCH1(m,4)));
        end
        auxbr=0;
        for n=1:k_BRANCH0
            if Nbrch(m,1)==D_BRANCH0(n,1) && Nbrch(m,2)==D_BRANCH0(n,2)
                if  Nbrch(m,1)~=0 && Nbrch(m,2)~=0
                    Iseq0(m)=If0*((ZB0(q0,kf1)-ZB0(p0,kf1))/(D_BRANCH0(n,3)+1i*D_BRANCH0(n,4)));
                elseif Nbrch(m,1)==0
                    Iseq0(m)=If0*(ZB0(q0,kf1)/(D_BRANCH0(n,3)+1i*D_BRANCH0(n,4)));
                elseif Nbrch(m,2)==0
                    Iseq0(m)=If0*(-ZB0(p0,kf1)/(D_BRANCH0(n,3)+1i*D_BRANCH0(n,4)));
                end
                auxbr=1;
            elseif Nbrch(m,1)==D_BRANCH0(n,2) && Nbrch(m,2)==D_BRANCH0(n,1)
                if  Nbrch(m,1)~=0 && Nbrch(m,2)~=0
                    Iseq0(m)=-If0*((ZB0(q0,kf1)-ZB0(p0,kf1))/(D_BRANCH0(n,3)+1i*D_BRANCH0(n,4)));
                elseif Nbrch(m,1)==0
                    Iseq0(m)=-If0*(ZB0(q0,kf1)/(D_BRANCH0(n,3)+1i*D_BRANCH0(n,4)));
                elseif Nbrch(m,2)==0
                    Iseq0(m)=-If0*(-ZB0(p0,kf1)/(D_BRANCH0(n,3)+1i*D_BRANCH0(n,4)));
                end
                auxbr=1;
            elseif n==k_BRANCH0 && auxbr==0
                Iseq0(m)=0;
            end
        end
    end
    for m=1:k_BRANCH0
        for n=1:k_BRANCH1
            if (D_BRANCH0(m,1)==D_BRANCH1(n,1) && D_BRANCH0(m,2)==D_BRANCH1(n,2)) || (D_BRANCH0(m,1)==D_BRANCH1(n,2) && D_BRANCH0(m,2)==D_BRANCH1(n,1))
                break
            elseif n==k_BRANCH1
                i_seq=i_seq+1;
                Nbrch(i_seq,1)=D_BRANCH0(m,1);                 % Barra de Origem
                Nbrch(i_seq,2)=D_BRANCH0(m,2);                 % Barra de Destino
                Iseq1(i_seq)=0;Iseq2(i_seq)=0;
                for a=1:k_BUS0                                  % Índice barra Seq. 0
                    if D_BRANCH0(m,1)==NB0(a)
                        p0=a;
                    elseif D_BRANCH0(m,2)==NB0(a)
                        q0=a;
                    end
                end
                if  D_BRANCH0(m,1)~=0 && D_BRANCH0(m,2)~=0
                    Iseq0(i_seq)=If0*((ZB0(q0,kf1)-ZB0(p0,kf1))/(D_BRANCH0(m,3)+1i*D_BRANCH0(m,4)));
                elseif D_BRANCH0(m,1)==0
                    Iseq0(i_seq)=If0*(ZB0(q0,kf1)/(D_BRANCH0(m,3)+1i*D_BRANCH0(m,4)));
                elseif D_BRANCH0(m,2)==0
                    Iseq0(i_seq)=If0*(-ZB0(p0,kf1)/(D_BRANCH0(m,3)+1i*D_BRANCH0(m,4)));
                end
            end
        end    
    end
    for m=1:i_seq
        Iabcpu(m,1:3)=T*[Iseq0(m);Iseq1(m);Iseq2(m)];
    end
 end
 % ***** Relatório
 ArqS1 = fopen(strcat(DirF,Arq_SAIDA),'wt');
 fprintf(ArqS1,'\n  **********   RELATÓRIO - %s    ->   BARRA - %d   **********\n',Tip_Falta,D_ENT(2));
 fprintf(ArqS1,'\n  CORRENTE DE FALTA: \n');
 fprintf(ArqS1,'  -----------------------------------------------------------------------------------------\n');
 fprintf(ArqS1,'            FASE A                        FASE B                        FASE C\n');                             
 fprintf(ArqS1,'   Módulo(pu)    Ângulo(grau)    Módulo(pu)    Ângulo(grau)    Módulo(pu)    Ângulo(grau)\n');
 fprintf(ArqS1,'  ------------------------------------------------------------------------------------------\n');
 fprintf(ArqS1,'   %8.4f        %7.2f          %8.4f     %7.2f        %8.4f       %7.2f\n',abs(Ifabcpu(1)),angle(Ifabcpu(1))*180/pi,abs(Ifabcpu(2)),angle(Ifabcpu(2))*180/pi,abs(Ifabcpu(3)),angle(Ifabcpu(3))*180/pi);
 fprintf(ArqS1,'\n\n  TENSÕES NAS BARRAS: \n');
    fprintf(ArqS1,'  -----------------------------------------------------------------------------------------------\n');
    fprintf(ArqS1,'  BARRA             FASE A                        FASE B                        FASE C\n');                             
    fprintf(ArqS1,'           Módulo(pu)    Ângulo(grau)    Módulo(pu)    Ângulo(grau)    Módulo(pu)    Ângulo(grau)\n');
    fprintf(ArqS1,'  -----------------------------------------------------------------------------------------------\n');
 for m=1:k_BUS1
    Vamod=abs(Vabcpu(m,1));Vaang=angle(Vabcpu(m,1))*180/pi;
    Vbmod=abs(Vabcpu(m,2));Vbang=angle(Vabcpu(m,2))*180/pi;
    Vcmod=abs(Vabcpu(m,3));Vcang=angle(Vabcpu(m,3))*180/pi;
    fprintf(ArqS1,'%4i      %8.4f        %7.2f        %8.4f        %7.2f       %8.4f        %7.2f\n',NB1(m),Vamod,Vaang,Vbmod,Vbang,Vcmod,Vcang);
 end
 fprintf(ArqS1,'\n\n  CORRENTES NOS RAMOS: \n');
    fprintf(ArqS1,'  -----------------------------------------------------------------------------------------------------\n');
    fprintf(ArqS1,'  DE     PARA              FASE A                        FASE B                        FASE C\n');                             
    fprintf(ArqS1,'                  Módulo(pu)    Ângulo(grau)    Módulo(pu)    Ângulo(grau)    Módulo(pu)    Ângulo(grau)\n');
    fprintf(ArqS1,'  -----------------------------------------------------------------------------------------------------\n');
 for m=1:i_seq
    Iamod=abs(Iabcpu(m,1));Iaang=angle(Iabcpu(m,1))*180/pi;
    Ibmod=abs(Iabcpu(m,2));Ibang=angle(Iabcpu(m,2))*180/pi;
    Icmod=abs(Iabcpu(m,3));Icang=angle(Iabcpu(m,3))*180/pi;
    fprintf(ArqS1,'%3i    %3i       %8.4f        %7.2f        %8.4f         %7.2f        %8.4f        %7.2f\n',Nbrch(m,1),Nbrch(m,2),Iamod,Iaang,Ibmod,Ibang,Icmod,Icang);
 end
 fprintf('\n### RELATÓRIO DA FALTA GERADO\n');
 fclose(ArqS1);
 %toc
end