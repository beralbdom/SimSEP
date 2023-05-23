function[] = gera_med(DirD,k_BUS,NLO,D_BRANCH,Vt,Pt,Qt,DirM,NB,im,Sfdt,Sfit,Sb,horas,mins)
fileID = strcat(DirD,'Sistemas_de_Medicao.xlsx');
Sheets = strcat('ieee',int2str(NB));
med_total = 3*k_BUS + 4*(NLO);
coluna = strcat('E2:E',int2str(med_total+1));
ok_med = xlsread(fileID, Sheets,coluna);
    de_med = zeros(1,med_total);
    PMU_med = zeros(1,med_total);
    circ_med = ones(1,med_total);
    fs_med = ones(1,med_total);
    acc_med(1:med_total) = 0.020;
    dp_med = zeros(1,med_total);
    valor_med = zeros(1,med_total);
    for i=1:k_BUS
        num_med(i) = i;
        num_med(k_BUS + i) = k_BUS + i;
        num_med(2*k_BUS +i) = 2*k_BUS + i;
        tipo_med(i) = 6; %medidas de tensão
        tipo_med(k_BUS + i) = 2; %injeção de pot ativa
        tipo_med(2*k_BUS + i) = 5; %injeção de pot reativa
        para_med(i) = i;
        para_med(k_BUS + i) = i;
        para_med(2*k_BUS+i)=i;
        fs_med(i)= 1.1; %fundo escala para V = 1.1
        acc_med(i)= 0.015; %precisão de V = 0.015
        ref_med(i) = abs(Vt(i,im));
        ref_med(k_BUS + i) = Pt(i,im);
        ref_med(2*k_BUS + i) = Qt(i,im);
        dp_med(i)=((acc_med(i)*abs(ref_med(i)))/3);
        dp_med(k_BUS + i) = ((acc_med(k_BUS + i)*abs(ref_med(k_BUS + i))+0.0052*fs_med(k_BUS + i))/3);
        dp_med(2*k_BUS + i) = ((acc_med(2*k_BUS + i)*abs(ref_med(2*k_BUS + i))+0.0052*fs_med(2*k_BUS + i))/3);
        %dp_med(k_BUS + i) = abs(ref_med (k_BUS + i))/100;  
        %dp_med(2*k_BUS + i) = abs(ref_med (2*k_BUS + i))/100;  
    end
    for i=3*k_BUS+1:(3*k_BUS + NLO)
        ik = 3*k_BUS;
        num_med(i) = i;
        num_med(NLO + i) = NLO + i;
        num_med(2*NLO + i) = 2*NLO +i;
        num_med(3*NLO + i) = 3*NLO+i;
        tipo_med(i) = 1; %fluxo de potencia ativa direto
        tipo_med(NLO + i) = 4; %fluxo de potencia reativa direto
        tipo_med(2*NLO + i) = 1; %fluxo de potencia ativa reverso
        tipo_med(3*NLO + i) = 4; %fluxo de potencia reativa reverso
        de_med(i) = D_BRANCH(i-ik,1);
        de_med(NLO + i) = D_BRANCH(i-ik,1);
        de_med(2*NLO + i) = D_BRANCH(i-ik,2);
        de_med(3*NLO + i) = D_BRANCH(i-ik,2);
        para_med(i) = D_BRANCH(i-ik,2);
        para_med(NLO + i) = D_BRANCH(i-ik,2);
        para_med(2*NLO + i) = D_BRANCH(i-ik,1);
        para_med(3*NLO + i) = D_BRANCH(i-ik,1);
        ref_med(i) = real(Sfdt(i-ik,im))/Sb;
        ref_med(NLO + i) = imag(Sfdt(i-ik,im))/Sb;
        ref_med(2*NLO + i) = real(Sfit(i-ik,im))/Sb;
        ref_med(3*NLO + i) = imag(Sfit(i-ik,im))/Sb; 
        dp_med(i)=((acc_med(i)*abs(ref_med(i))+0.0052*fs_med(i))/3);
        dp_med(NLO + i) = ((acc_med(NLO + i)*abs(ref_med(NLO + i))+0.0052*fs_med(NLO + i))/3);
        dp_med(2*NLO + i) = ((acc_med(2*NLO + i)*abs(ref_med(2*NLO + i))+0.0052*fs_med(2*NLO + i))/3);
        dp_med(3*NLO + i) = ((acc_med(3*NLO + i)*abs(ref_med(3*NLO + i))+0.0052*fs_med(3*NLO + i))/3);
%         dp_med(i)=abs(ref_med(i))/100;
%         dp_med(NLO + i) = abs(ref_med(NLO + i))/100;
%         dp_med(2*NLO + i) = abs(ref_med(2*NLO + i))/100;
%         dp_med(3*NLO + i) = abs(ref_med(3*NLO + i))/100;    
    end
%     for i=1:length(dp_med)
%         if abs(dp_med(i)) <= 0.001733
%             dp_med(i) = 0.001733;
%         end
%    end
    valor_med = 3*dp_med.*random('unif',-1,1,1,length(dp_med)); %rand uniforme entre 98%-102%
    valor_med =  valor_med+ref_med;   
    Arq_CDF_Med=fopen(strcat(DirM,'ieee',int2str(NB),'_',int2str(im),'_',horas,mins,'.med'),'wt');
    for m=1:med_total
        fprintf(Arq_CDF_Med,'%04d %04d %04d %02d %02d %03d %01d %5.3f %5.3f %10.6f %+10.5f %+10.5f \n',num_med(m),de_med(m),para_med(m),circ_med(m),tipo_med(m),PMU_med(m),ok_med(m),acc_med(m),fs_med(m),dp_med(m),ref_med(m),valor_med(m)');
    end 
    fclose(Arq_CDF_Med);
    