%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Código para corrigir os sinais do microfone da B&K de campo livre para
%   campo difuso obtidos na medição com a NI.
%
%   Autor: Leonardo Filgueira 
%% Limpeza
ccx;
%% Carrega os dados da medição
load('medNI_09-Nov-2022.mat');
%% Correção do microfone de campo livre para campo difuso

mic_data = load('mic_data.mat'); % importa os dados de correção do microfone

%% REAMOSTRANDO AS CURVAS DE CORREÇÃO

% Aqui é feita uma interpolação dos vetores de magnitude da correção do 
% microfone para ter o mesmo tamanho do vetor de frequência dos sinais gravados 

% Vamos encontrar quais as posições do vetor de frequência do sinal a ser
% corrigido correspondem às frequências iniciais e finais dos vetores da
% correção. Como os vetores de correção possuem os mesmos valores de
% frequência, podemos buscar esse índice em apenas um deles que servirá
% para as duas correções (isso pode ser conferido com a função:
% isequal(mic_data.ff_correction(:,1),mic_data.df_correction(:,1))

idx_low = dsearchn(msNI{1, 1}.PressaoSonora.dist.semPV.freqVector, mic_data.ff_correction(1,1));
idx_hi = dsearchn(msNI{1, 1}.PressaoSonora.dist.semPV.freqVector, mic_data.ff_correction(end,1));

% Interpolação dos vetores de correção para ter o mesmo número de amostras 
% da parte do espectro do sinal a ser corrigido 
ff_corr_rs = makima(mic_data.ff_correction(:,1),mic_data.ff_correction(:,2), msNI{1, 1}.PressaoSonora.prox.semPV.freqVector(idx_low:idx_hi))';
df_corr_rs = makima(mic_data.df_correction(:,1),mic_data.df_correction(:,2), msNI{1, 1}.PressaoSonora.prox.semPV.freqVector(idx_low:idx_hi))';

% Plot das correções reamostradas
figure(1)
semilogx(msNI{1, 1}.PressaoSonora.dist.semPV.freqVector(idx_low:idx_hi),ff_corr_rs);hold on;grid on;
semilogx(msNI{1, 1}.PressaoSonora.dist.semPV.freqVector(idx_low:idx_hi),df_corr_rs); ylim([-10 15]); xlim([100 25000])
title('Curvas de correção'); legend('Campo livre','Campo difuso');
%% Correção dos sinais

% Agora com os vetores de magnitude interpolados, podemos aplicar a
% correção dos sinais. Para isso, iremos subtrair do espectro a influência
% da correção de campo livre com grid e depois iremos somar a correção de
% campo difuso.

% Aqui é feita a correção do espectro para os dados obtidos com o microfone
% de campo livre (para campo difuso)
Lp.prox.comPV = 20*log10(abs(msNI{1,1}.PressaoSonora.prox.comPV.freqData(idx_low:idx_hi)./2e-5)) - ff_corr_rs + df_corr_rs;
Lp.prox.semPV = 20*log10(abs(msNI{1,1}.PressaoSonora.prox.semPV.freqData(idx_low:idx_hi)./2e-5)) - ff_corr_rs + df_corr_rs;
Lp.dist.comPV = 20*log10(abs(msNI{1,1}.PressaoSonora.dist.comPV.freqData(idx_low:idx_hi)./2e-5)) - ff_corr_rs + df_corr_rs;
Lp.dist.semPV = 20*log10(abs(msNI{1,1}.PressaoSonora.dist.semPV.freqData(idx_low:idx_hi)./2e-5)) - ff_corr_rs + df_corr_rs;

% Aqui estamos concatenando a parte do espectro que não precisa de correção
% com a parte corrigida
Lp.prox.comPV = [20*log10(abs(msNI{1,1}.PressaoSonora.prox.comPV.freqData(1:(idx_low-1)))./2e-5); Lp.prox.comPV];
Lp.prox.semPV = [20*log10(abs(msNI{1,1}.PressaoSonora.prox.semPV.freqData(1:idx_low-1))./2e-5); Lp.prox.semPV];
Lp.dist.comPV = [20*log10(abs(msNI{1,1}.PressaoSonora.dist.comPV.freqData(1:idx_low-1))./2e-5); Lp.dist.comPV];
Lp.dist.semPV = [20*log10(abs(msNI{1,1}.PressaoSonora.dist.semPV.freqData(1:idx_low-1))./2e-5); Lp.dist.semPV];

%% PLOT 

% Plot de um sinal para comparação
msNI{1,1}.PressaoSonora.prox.comPV.plot_freq
semilogx(msNI{1,1}.PressaoSonora.prox.comPV.freqVector(1:idx_hi),Lp.prox.comPV)


%semilogx(msNI{1,2}.PressaoSonora.prox.comPV.freqVector,20*log10(abs(msNI{1,2}.PressaoSonora.prox.comPV.freqData./2e-5)))
%semilogx(msNI{1, 1}.PressaoSonora.dist.semPV.freqVector(idx_low:idx_hi),-ff_corr_rs)
