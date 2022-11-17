~DESCRIÇÃO DA PASTA~

A pasta 'Dados dos Mics' são os dados dos microfones obtidos do CD que vem com cada microfone da Brüel.

A pasta 'mic data sheets' são as planilhas com os dados das curvas das respostas e de correção do microfone (de campo livre Type 4189) utilizado na medição.

O arquivo 'mic_data.mat' são as curvas de resposta e de correção para o microfone de campo livre (as mesmas das planilhas contidas na pasta 'mic data sheets', porém importados para o matlab e transformados em uma matriz numérica). 


O arquivo 'medicao_ni_2mic.m' é a rotina para medição de pressão sonora e 'medNI_09-Nov-2022.mat' é o arquivo com os dados da medição.

O arquivo 'mic_correction_explained.m' é um código que explica como é feita a correção dos microfones da B&K e plota as curvas para melhor entendimento.

O arquivo 'processamento_NPS.m' é o código que realiza a correção de campo livre para campo difuso dos dados obtidos na medição e plota o resultado para fins de comparação. 

OBS* Em 'processamento_NPS_testes.m' foram realizados alguns testes utilizando a função de interpolação makima do Matlab e a função 'ameliorate_vec_modified.m', do professor Will. Acrescentei mais dois argumentos na função (n e beta da função 'resample') para retirar uma oscilação que ocorria no fim da curva.

At.te,

Leo.
