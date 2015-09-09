h = gcf; %current figure handle
axesObjs = get(h, 'Children');  %axes handles
dataObjs = get(axesObjs, 'Children'); %handles to low-level graphics objects in axes

objTypes = get(dataObjs, 'Type');  %type of low-level 
xdata = get(dataObjs, 'XData');  %data from low-level grahics objects
ydata = get(dataObjs, 'YData');
% zdata = get(dataObjs, 'ZData');graphics object
x1= xdata;
y1=ydata;
%%
h = gcf; %current figure handle
axesObjs = get(h, 'Children');  %axes handles
dataObjs = get(axesObjs, 'Children'); %handles to low-level graphics objects in axes

objTypes = get(dataObjs, 'Type');  %type of low-level 
xdata = get(dataObjs, 'XData');  %data from low-level grahics objects
ydata = get(dataObjs, 'YData');
% zdata = get(dataObjs, 'ZData');graphics object
x2= xdata;
y2=ydata;

%%

plot(x1,y1,'o',x2,y2,'*');hold on;
xlabel('cell length (microns)')
ylabel('number of fluorecent dots');
legend('5X 60min','5X 90min');
axis([0 6 0 6])

%%

h1=hist(y1,0:8);
N1=sum(h1(1:7));
h2=hist(y2,0:8);
N2=sum(h2(1:7));
bar((0:6)',[h1(1:7)'/N1,h2(1:7)'/N2])
xlabel('number of fluorescent dot')
ylabel('percentage');
legend('5X 60min','5X 90min');
