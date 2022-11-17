%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   Código explicativo de como é feita a correção nos microfones da B&K   %
%   considerando os campo sonoros                                         % 
%                                                                         %
%   Autor: Leonardo Filgueira (10/11/2022)                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Limpeza
ccx;
%% Curvas de resposta do microfone B&K
load('mic_data.mat'); % importa as curvas do microfone retiradas do Microphone Viewer da B&K

% Plot das respostas do microfone sem grid e sem correção, com grid e cor-
% reção para campo livre e com grid e correção para campo difuso. Note que
% as respostas são iguais abaixo de uma certa frequência (aproximadamente 
% 199,5 Hz)
figure(1)
semilogx(actuator_response(:,1),actuator_response(:,2),'lineWidth',2); grid on; hold on;
semilogx(ff_response(:,1),ff_response(:,2),'lineWidth',2);
semilogx(df_response(:,1),df_response(:,2),'lineWidth',2);
title('Respostas em frequência do microfone B&K');
legend('Sem grid - Sem correção', 'Com grid - Com correção p/ Campo Livre','Com grid - Com correção p/ Campo Difuso','location','best')
%% Curvas de correção do microfone

% Primeiro vamos encontrar em qual posição do vetor com a resposta completa
% do microfone equivale a primeira frequência do vetor da correção.
idx = dsearchn(actuator_response(:,1),ff_correction(1,1));

% Para obter a resposta de campo livre do microfone com o grid, basta somar
% a curva da resposta do microfone sem grid (actuator_response) e sem corre-
% ção com a curva de correção para campo livre com grid (ff_correction) pa-
% ra os valores nas posições do vetor que corresponsem às mesmas frequências.
ff = actuator_response(idx:end,2) + ff_correction(:,2);

% Para obter a resposta de campo difuso do microfone com o grid, basta somar
% a curva da resposta do microfone sem grid (actuator_response) e sem corre-
% ção com a curva de correção para campo difuso com grid (df_correction).
df = actuator_response(idx:end,2) + df_correction(:,2);

% Plot
figure(2)
subplot(2,1,1)
semilogx(actuator_response(:,1),actuator_response(:,2),'lineWidth',2); grid on; hold on;
semilogx(ff_correction(:,1),ff_correction(:,2),'lineWidth',2);
semilogx(ff_correction(:,1),ff,'lineWidth',2); ylim([-15 15]);
title('Correção do microfone B&K para campo livre (com grid)');
legend('Resposta do mic sem correção (sem grid)','Curva de correção para campo livre (com grid)','Soma das duas curvas = Resposta de campo livre','location','northwest')
subplot(2,1,2)
semilogx(actuator_response(:,1),actuator_response(:,2),'lineWidth',2); grid on; hold on;
semilogx(df_correction(:,1),df_correction(:,2),'lineWidth',2,'color','magenta');
semilogx(df_correction(:,1),df,'lineWidth',2,'color','green');ylim([-15 15]);
title('Correção do microfone B&K para campo difuso (com grid)');
legend('Resposta do mic sem correção (sem grid)','Curva de correção para campo difuso (com grid)', 'Soma das duas curvas = Resposta de campo difuso','location','northwest')
set(gcf, 'Position',  [350, 70, 800, 700])
%% Correção de campo livre para campo difuso e vice-versa

% Para realizar a correção do microfone de campo livre para campo difuso, 
% basta retirar a correção de campo livre com grid (ff_correction) e depois 
% adicionar a correção de campo difuso com grid (df_correction) para os va-
% lores nas posições do vetor que correspondem às mesma frequências.

% Aqui temos a parte acima de 199,5 Hz sem a correção de campo livre com 
% grid, ou seja, apenas a resposta do mic sem grid e sem correção 
act_response_1 = ff_response(idx:end,2) - ff_correction(:,2);

% Aqui temos a parte acima de 199,5 Hz com a correção de campo difuso com
% grid
df_response_1 = act_response_1 + df_correction(:,2);

% Agora vamos concatenar a parte que é comum para todas as respostas com a
% parte corrigida acima de 199,5 Hz.
df_response_2 = [ff_response(1:(idx-1),2); df_response_1];

figure(3)
subplot(2,2,1)
semilogx(ff_response(:,1),ff_response(:,2),'-.','lineWidth',2,'color','blue'); hold on; grid on
semilogx(ff_correction(:,1),-ff_correction(:,2),'-.','lineWidth',2,'color','cyan')
semilogx(ff_correction(:,1),act_response_1,'lineWidth',2,'color','green');ylim([-15 15])
title('Retirando a correção de campo livre')
legend('Resposta de campo livre com grid','Correção de campo livre com grid (invertida)','Soma das curvas azul e ciano = Resposta sem correção e sem grid','location','northwest')
subplot(2,2,3)
semilogx(ff_correction(:,1),act_response_1,'-.','lineWidth',2,'color','green');hold on; grid on
semilogx(df_correction(:,1),df_correction(:,2),'-.','lineWidth',2,'color','#EDB120');
semilogx(ff_response(:,1),df_response_2,'lineWidth',2,'color','#7E2F8E'); ylim([-15 15])
title('Correção para campo difuso')
legend('Resposta sem correção e sem grid','Correção de campo difuso com grid','Soma das duas curvas = Resposta de campo difuso com grid','location','northwest');
set(gcf, 'Position',  [350, 70, 800, 700])


% Aqui temos a parte acima de 199,5 Hz sem a correção de campo livre com 
% grid, ou seja, apenas a resposta do mic sem grid e sem correção 
act_response_2 = df_response(idx:end,2) - df_correction(:,2);

% Aqui temos a parte acima de 199,5 Hz com a correção de campo difuso com
% grid
ff_response_1 = act_response_2 + ff_correction(:,2);

% Agora vamos concatenar a parte que é comum para todas as respostas com a
% parte corrigida acima de 199,5 Hz.
ff_response_2 = [ff_response(1:(idx-1),2); ff_response_1];

subplot(2,2,2)
semilogx(df_response(:,1),df_response(:,2),'-.','lineWidth',2,'color','#7E2F8E'); hold on; grid on
semilogx(df_correction(:,1),-df_correction(:,2),'-.','lineWidth',3,'color','red')
semilogx(df_correction(:,1),act_response_2,'lineWidth',2,'color','green');ylim([-15 15])
title('Retirando a correção de campo difuso')
legend('Resposta de campo difuso com grid','Correção de campo difuso com grid (invertida)','Soma das curvas roxa e vermelha = Resposta sem correção e sem grid','location','northwest')
subplot(2,2,4)
semilogx(df_correction(:,1),act_response_2,'-.','lineWidth',2,'color','green');hold on; grid on
semilogx(ff_correction(:,1),ff_correction(:,2),'-.','lineWidth',2,'color','magenta');
semilogx(ff_response(:,1),ff_response_2,'lineWidth',2,'color','blue'); ylim([-15 15])
title('Correção para campo livre')
legend('Resposta sem correção e sem grid','Correção de campo livre com grid','Soma das duas curvas = Resposta de campo livre com grid','location','northwest');
set(gcf, 'Position', get(0, 'Screensize'));
