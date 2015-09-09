% show all port
allports=instrhwinfo('serial');
%%
s = serial('COM4');
fopen(s);
fprintf(s,'ERRORSTAT <CR>')
out = fscanf(s)
fclose(s);