% show all port
allports=instrhwinfo('serial');
%%
s = serial('COM5');
%%
fopen(s);
set(s,'timeout',0.01);
%%
fprintf(s,'%s\r','ERRORSTAT');
out = fscanf(s)
fprintf(s,'%s\r','?');
out = fscanf(s)
fprintf(s,'%s\r','=');
out = fscanf(s)
%%
fprintf(s,'%s\r','STAGE');
out = fscanf(s)
%%
fprintf(s,'%s\r','PS');
out = fscanf(s)
fprintf(s,'%s\r','PS,0,0');
out = fscanf(s)
fprintf(s,'%s\r','PS');
out = fscanf(s)
%%
fprintf(s,'%s\r','G,-14500,-14500');
out = fscanf(s)
fprintf(s,'%s\r','PS');
out = fscanf(s)
%%
fclose(s);
