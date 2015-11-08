a=serial('COM4');
% a.OutputBufferSize=1;
fopen(a);
%% fprintf(a,'%s','*OA');
fprintf(a,'%s\r','*OA');
%%
% a.Terminator='CR/LF';
% a.Terminator='LF/CR';
a.Terminator='';
% a.Terminator=13;
% fprintf(a,'');
% fprintf(a,'%s\r','*FW');
% fprintf(a,'%s\r','*OA');
fprintf(a,'%s\r','*OT');
% fprintf(a,'%s\r','*OR');
% fprintf(a,'%s\r','*D1');
%%
fprintf(a,'%s\r','*FT');
%%
fprintf(a,'%s\r','*OR');
%%
fprintf(a,'%s\r','*OG');
%%
fprintf(a,'%s\r','*FB');


%%
%%
fprintf(a,'%s\r','*D9');

%%
fclose(a);
clear all;
clc