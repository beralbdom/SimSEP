tic
clc
clear
DirDesp = strcat(pwd,'\Despacho\');
DirD = strcat(pwd,'\Dados\');DirCDF =strcat(pwd,'\Carga\');DirR = strcat(pwd,'\Flow\');DirF = strcat(pwd,'\Falta\');
DirM = strcat(pwd,'\Med\');DirEE = strcat(pwd,'\EE\');ArqDI = fopen(strcat(DirD,'Dados_Iniciais.txt'), 'r');
tline = fgetl(ArqDI);tline = fgetl(ArqDI);tlineN = regexp(tline,'[-.\d]{1,10}','match');
NB = str2double(tlineN(1));step = str2double(tlineN(2));
qi_hora=60/step;                    % Quantidade de instantes em uma hora, em relação ao step selecionado
qi_dia=qi_hora*24;                  % Quantidade de instantes em um dia
x_pc=0;
tline = fgetl(ArqDI);tline = fgetl(ArqDI);tline = fgetl(ArqDI);
Carga=0;
while ~feof(ArqDI)
    tline = fgetl(ArqDI);
    x_pc=x_pc+1;
    NB_TC(x_pc,:) = regexp(tline,'[a-z,A-Z,\d]{1,15}','match');
    TipoDeCarga=char(NB_TC(x_pc,2));
    [Carga] = GeraPerfil(DirD,TipoDeCarga,qi_hora,qi_dia,x_pc,Carga);
end
%[Carga] = GeraPerfil(DirD,TipoDeCarga,qi_hora,qi_dia);
GeraCdf(Carga,DirCDF,NB,qi_dia,NB_TC,x_pc);
fclose(ArqDI);
ArqSF=fopen(strcat(DirR,'FLUXO_NWT_RPHSN_',num2str(NB),'.txt'), 'wt');
ArqEVT=fopen(strcat(DirR,'EVT_',num2str(NB),'.txt'), 'wt');
%%%%%%%Cálculo do Despacho econômico%%%%%%%%%
Main_Despacho
clear horas
for im=1:qi_dia
    [D_BUS,k_BUS,D_BRANCH,k_BRANCH,Sb,accry,maxiter,NLO,Vb,horas,mins]=ler_cdf(DirDesp,im,NB,qi_dia);
    if im ==1
        [YB]=Y_BUS(D_BUS,k_BUS,D_BRANCH,k_BRANCH);
        ZB=inv(YB);
    end
  
    %%%%%%%%%%%%%%Cálculo do Fluxo%%%%%%%%%%%%%%%
    NWT_RPHSN
    %%%%%%%%%%%%%%Escreve Fluxo%%%%%%%%%%%%%%%%%%%
    escreve_flow(DirDesp,DirR,NB,im,horas,mins,V,Pt,Qt,Sb,D_BUS);
    %%%%%%%%%%%%%%Verifica Falta%%%%%%%%%%%%%%%%%%
    Verf_falta=random('unif',0,1,1);
    if Verf_falta<=0.15     % Falta detectada
        fprintf('\n### FALTA DETECTADA');
        Bf=fix(random('unif',1,NB,1));
        Vf=abs(Vt(Bf,im));
        Tetaf=angle(Vt(Bf,im));
        Tipo_Falta=random('unif',0,1,1);
        if Tipo_Falta>0.3
            Tf=2;
        else
            Tf=3;
        end
        [ZB1,NB1,ZB0,NB0,Ifabcpu,Vabcpu,Iabcpu,Iseq0,Iseq1,Iseq2]=CALC_FALTA_Z(Bf,Vf,Tetaf,DirCDF,DirF,im,NB,qi_dia,ZB,D_BUS,k_BUS,D_BRANCH,k_BRANCH,Tf);
    else                  % Falta não detectada
        %%%%%% gera arquivo de medidas para cada instante de tempo a partir do flow%%%%%%%%%%%%%
        gera_med(DirD,k_BUS,NLO,D_BRANCH,Vt,Pt,Qt,DirM,NB,im,Sfdt,Sfit,Sb,horas,mins);
        %%%%%%%%%%%%%%% EE %%%%%%%%%%%%%%
        Arq_CDF = strcat(DirCDF,'ieee',int2str(NB),'_',int2str(im),'_',horas,mins,'.txt');
        Arq_CDF_ee = strcat(DirEE,'ieee',int2str(NB),'_',int2str(im),'_',horas,mins,'_EE.txt'); %salva resultados
        Arq_CDF_Med = strcat(DirM,'ieee',int2str(NB),'_',int2str(im),'_',horas,mins,'.med');
        [V_ee, Vref_ee, conv_ee,Ybus ] = ee(Arq_CDF_Med, Arq_CDF, 0.0001, 100, 1, Arq_CDF_ee,1,0);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end
fclose('all');
toc