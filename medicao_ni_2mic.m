%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   Disciplina de Instrumentação em Acústica e Vibrações (EAC) - 2022.2   %
%   Professor: Will Fonseca                                               %
%                                                                         %
%   Código para medição de Pressão Sonora na câmara reverberante utili-   %
%   zando uma placa de aquisição da National Instruments  (NI) e 2  mi-   % 
%   cionados  próximo  e  distante da fonte aerodinâmica de referência,   %
%   com e sem protetor de vento, para posteriormente  se  obter o Nível   %
%   de Pressão Sonora (NPS) e realizar a correção do microfone de campo   %
%   livre  para campo difuso.  O intuito do código é ser interativo, em   %
%   que o usuário executa o código (pressionando F5)  e vai interagindo   %
%   e recebendo instruções pelo  Command Window.  Este código utiliza o   %
%   ITAtoolbox, então certifique-se que esteja instalado e funcionando!   %
%   Certifique-se também que o driver da NI esteja instalado.             %
%                                                                         %
%   Autor: Leonardo Filgueira                                             %
%   Última atualização: 10/11/2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%% LISTA DE EQUIPAMENTOS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   - 1 Placa de aquisição da NI 9234
%   - 1 Cabo USB-A <-> USB-B
%   - 2 Cabos BNC <-> BNC
%   - 1 Microfone B&K Tipo 4189 (Campo Livre)
%   - 1 Microfone B&K Tipo 4942 (Campo Difuso)
%   - 2 tripés de microfone
%   - 1 Calibrador sonoro B&K Tipo 4231 
%   - 1 Espuma de proteção contra vento B&K Tipo 2250
%   - 1 Fonte aerodinâmica de referência B&K Tipo 4204
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Limpeza
clear all; format long; clc; close all; %#ok<CLALL>
%% CONFIGURAÇÃO DA AQUISIÇÃO DE DADOS
d = daqlist("ni")         % Mostra todos os dispositivos conectados da NI 
s.daqObj = daq('ni');     % Inicia conexão com a placa de aq. conectada
s.daqObj.Rate = 51200; Fs=s.daqObj.Rate;  % Frequência de amostragem da medição

% Definição dos canais
[s.inChannel1,idx1] = addinput(s.daqObj,'cDAQ2Mod1','ai0','Microphone');
[s.inChannel2,idx2] = addinput(s.daqObj,'cDAQ2Mod1','ai1','Microphone');

% Sensibilidade dos microfones 
s.inChannel1.Sensitivity = 1; % 1 para adquirir o sinal em Volt
s.inChannel2.Sensitivity = 1; 

%% SENSIBILIDADE DOS MICROFONES (1 Pa = 93,9794 dB ~ref.20µPa @1kHz)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Na medição da sensibilidade, o microfone é inserido no calibrador sonoro
% ligado emitindo 1 Pa, o que é equivalente a 93,9794 dB, em 1 kHz. O sinal
% é medido em Volts e transformado em um itaAudio para faciltar a manipula-
% ção dos dados (certifique-se de que o itaToolbox está instalado e funcio-
% nando). Para encontrar a sensibilidade [Volt/Pascal], basta pegar o máxi-
% mo do valor absoluto dos componentes de frequência do sinal (.freqData). 
% Com isso determinado, iremos dividir os sinais que queremos avaliar (em 
% Volts) por essa sensibilidade para obtermos a pressão sonora [V/(V/Pa)=Pa].
% Iremos chamar o inverso da sensibiliade [Pa/V] de Fator de Correção (FC),
% em que, ao invés de dividir os sinais pela sensibilidade, iremos multi-
% plicá-los pelo FC.

i=1;numbOfMics=2;
msNI = cell(1,numbOfMics);
clc;
prompt = 'O microfone no canal ai0 é de campo difuso ou campo livre? [difuso/livre]\nMic 1 = ';
msNI{1}.micFieldType = input(prompt, 's');
prompt = 'E o microfone no canal ai1? [difuso/livre]\nMic 2 = ';
msNI{2}.micFieldType = input(prompt, 's');

clc;
prompt = 'Agora vamos achar o Fator de Correção (FC) para cada microfone.\nInsira o calibrador sonoro no microfone 1 (ai0), ligue-o e aperte ENTER para começar\n';
input(prompt);

validate = 'n';
while i <= numbOfMics
    
    clc;
    fprintf('▬ Calibração do Microfone %d ▬\n', i);
    
    while strcmp(validate, 'n')
        disp('• REC')
        daqData = read(s.daqObj, seconds(10));
        disp('◘ END')

            if i==1
                msNI{i}.calib = itaAudio(daqData.cDAQ2Mod1_ai0, Fs, 'time');
            else
                msNI{i}.calib = itaAudio(daqData.cDAQ2Mod1_ai1, Fs, 'time');
            end
        msNI{i}.calib.channelUnits = 'Volt';
        msNI{i}.calib.comment = 'Sinal do calibrador sonoro'
        msNI{i}.calib.channelNames{1} = 'Calibrador'
        msNI{i}.calib.plot_time;
        msNI{i}.calib.plot_freq;
 
        prompt = 'Tá tudo certo? Quer validar a calibração? [s/n]\n';
        validate = input(prompt, 's');
    end
    
    clear daqData

    msNI{i}.FC =  1 / max(abs(msNI{i}.calib.freqData));
    
    if i < numbOfMics
        input('Coloque o calibrador no outro microfone e aperte enter para começar:\n');
    end
    
    validate = 'n';
    i = i + 1;
    
end
%% INICIANDO A MEDIÇÃO
clc;
prompt = 'Qual o tempo da medição?\nValor em segundos = ';
trec = input(prompt);

clc;
prompt = 'Posicione o microfone 1 próximo da fonte sonora com o protetor de vento e outro distante e sem protetor.\n\n► Pressione ENTER para começar a medição ◄';
input(prompt);

j=1;validate='n';
while j <= 4
    fprintf('▬ Medição número %d ▬\n', j);
    
    while strcmp(validate, 'n')
        disp('• REC')
        daqData = read(s.daqObj, seconds(trec));
        disp('◘ END')

        if j==1
            msNI{1}.PressaoSonora.prox.comPV = itaAudio(daqData.cDAQ2Mod1_ai0, Fs, 'time') * msNI{1}.FC;
            msNI{1}.PressaoSonora.prox.comPV.channelUnits = 'Pa'; msNI{1}.PressaoSonora.prox.comPV.channelNames{1}='Mic 1';msNI{1}.PressaoSonora.prox.comPV.comment='Mic 1 próximo da fonte com protetor de vento';
            msNI{2}.PressaoSonora.dist.semPV = itaAudio(daqData.cDAQ2Mod1_ai1, Fs, 'time') * msNI{2}.FC;
            msNI{2}.PressaoSonora.dist.semPV.channelUnits = 'Pa'; msNI{2}.PressaoSonora.dist.semPV.channelNames{1}='Mic 2';msNI{2}.PressaoSonora.dist.semPV.comment='Mic 2 distante da fonte sem protetor de vento';
            msNI{1}.PressaoSonora.prox.comPV.plot_time; msNI{1}.PressaoSonora.prox.comPV.plot_freq;
            msNI{2}.PressaoSonora.dist.semPV.plot_time; msNI{2}.PressaoSonora.dist.semPV.plot_freq;
            prompt = '\n\nTudo certo com a medição? Deseja prosseguir? [s/n] - ';
            validate = input(prompt, 's');
            if strcmp(validate,'s')    
                prompt = '\nAgora coloque o protetor de vento no microfone 2\n\n► Pressione ENTER para continuar a medição ◄';
                input(prompt);
            end
        elseif j==2
            msNI{1}.PressaoSonora.prox.semPV = itaAudio(daqData.cDAQ2Mod1_ai0, Fs, 'time') * msNI{1}.FC;
            msNI{1}.PressaoSonora.prox.semPV.channelUnits = 'Pa';msNI{1}.PressaoSonora.prox.semPV.channelNames{1}='Mic 1';msNI{1}.PressaoSonora.prox.semPV.comment='Mic 1 próximo da fonte sem protetor de vento';
            msNI{2}.PressaoSonora.dist.comPV = itaAudio(daqData.cDAQ2Mod1_ai1, Fs, 'time') * msNI{2}.FC;
            msNI{2}.PressaoSonora.dist.comPV.channelUnits = 'Pa';msNI{2}.PressaoSonora.dist.comPV.channelNames{1}='Mic 2';msNI{2}.PressaoSonora.dist.comPV.comment='Mic 2 distante da fonte com protetor de vento';
            msNI{1}.PressaoSonora.prox.semPV.plot_time; msNI{1}.PressaoSonora.prox.semPV.plot_freq;
            msNI{2}.PressaoSonora.dist.comPV.plot_time; msNI{2}.PressaoSonora.dist.comPV.plot_freq;
            prompt = '\n\nTudo certo com a medição? Deseja prosseguir? [s/n] - ';
            validate = input(prompt, 's');
            if strcmp(validate,'s') 
                prompt = '\nAgora troque os microfones de posição sem mover o tripé do lugar e\ncoloque o protetor de vento no microfone 2 que está próximo da fonte.\n\n► Pressione ENTER para continuar a medição ◄';
                input(prompt);
            end
        elseif j==3
            msNI{1}.PressaoSonora.dist.semPV = itaAudio(daqData.cDAQ2Mod1_ai0, Fs, 'time') * msNI{1}.FC;
            msNI{1}.PressaoSonora.dist.semPV.channelUnits = 'Pa';msNI{1}.PressaoSonora.dist.semPV.channelNames{1}='Mic 1';msNI{1}.PressaoSonora.dist.semPV.comment='Mic 1 distante da fonte sem protetor de vento';
            msNI{2}.PressaoSonora.prox.comPV = itaAudio(daqData.cDAQ2Mod1_ai1, Fs, 'time') * msNI{2}.FC;
            msNI{2}.PressaoSonora.prox.comPV.channelUnits = 'Pa';msNI{2}.PressaoSonora.prox.comPV.channelNames{1}='Mic 2';msNI{2}.PressaoSonora.prox.comPV.comment='Mic 2 próximo da fonte com protetor de vento';
            msNI{1}.PressaoSonora.dist.semPV.plot_time; msNI{1}.PressaoSonora.dist.semPV.plot_freq;
            msNI{2}.PressaoSonora.prox.comPV.plot_time; msNI{2}.PressaoSonora.prox.comPV.plot_freq;
            prompt = '\n\nTudo certo com a medição? Deseja prosseguir? [s/n] - ';
            validate = input(prompt, 's');
            if strcmp(validate,'s')             
                prompt = '\nAgora coloque o protetor de vento no microfone 1 que está distante da fonte.\n\n► Pressione ENTER para continuar a medição ◄';
                input(prompt);
            end
        else
            msNI{1}.PressaoSonora.dist.comPV = itaAudio(daqData.cDAQ2Mod1_ai0, Fs, 'time') * msNI{1}.FC;
            msNI{1}.PressaoSonora.dist.comPV.channelUnits = 'Pa';msNI{1}.PressaoSonora.dist.comPV.channelNames{1}='Mic 1';msNI{1}.PressaoSonora.dist.comPV.comment='Mic 1 distante da fonte com protetor de vento';
            msNI{2}.PressaoSonora.prox.semPV = itaAudio(daqData.cDAQ2Mod1_ai1, Fs, 'time') * msNI{2}.FC;
            msNI{2}.PressaoSonora.prox.semPV.channelUnits ='Pa';msNI{2}.PressaoSonora.prox.semPV.channelNames{1}='Mic 2';msNI{2}.PressaoSonora.prox.semPV.comment='Mic 2 próximo da fonte sem protetor de vento';
            msNI{1}.PressaoSonora.dist.comPV.plot_time; msNI{1}.PressaoSonora.dist.comPV.plot_freq;
            msNI{2}.PressaoSonora.prox.semPV.plot_time; msNI{2}.PressaoSonora.prox.semPV.plot_freq;
            prompt = '\n\nTudo certo com a medição? Deseja prosseguir? [s/n] - ';
            validate = input(prompt, 's');
        end
    end
    validate = 'n';
    clear daqData
    clc;
    j = j+1;         
end       

%% Salvando tudo

fileName = sprintf(['medNI_',datestr(now, 'dd-mmm-yyyy'),'.mat']);
save(fileName, 'msNI','trec','Fs');

disp(['Seus dados foram devidamente salvos! O nome do arquivo é ', fileName])
