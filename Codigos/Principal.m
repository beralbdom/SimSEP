clear
DirD = 'C:\Users\lenovo\Documents\Operação SimSEP\Dados\';
DirCDF = 'C:\Users\lenovo\Documents\Operação SimSEP\CDF\';
DirR = 'C:\Users\lenovo\Documents\Operação SimSEP\Resultados\';
ArqDI = fopen(strcat(DirD,'Dados_Iniciais.txt'), 'r');
tline = fgetl(ArqDI);tline = fgetl(ArqDI);
TipoDeCarga = char(regexp(tline,'[a-z,A-Z]{3,15}','match'));
tlineN = regexp(tline,'[-.\d]{1,10}','match');
NB = str2double(tlineN(1));
step = str2double(tlineN(2));
qi_hora=60/step;               % Quantidade de instantes em uma hora, em relação ao step selecionado
qi_dia=qi_hora*24;                 % Quantidade de instantes em um dia
[Carga] = GeraPerfil(DirD,TipoDeCarga,qi_hora,qi_dia);
GeraCdf(Carga,DirCDF,NB);