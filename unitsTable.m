
handles.SourceFile = uigetfile('.xls'); %


handles.OriginalDataTable = readtable(handles.SourceFile, 'PreserveVariableNames', false);

headers = handles.OriginalDataTable.Properties.VariableNames;

T = handles.OriginalDataTable;
T.Properties.VariableUnits = {'y','source','name','title','tech','nm','GHz','GHz','GHz','mm.sq', 'mW', 'dBm','%','dBm','1dB', 'dB', 'V','class'};

x = table2array(T(:,7));
y = table2array(T(:,9));


units = T.Properties.VariableUnits;


scatter(x,y);
xlabel('F^{min} (GHz)');





t0=1000^(-8);
t=linspace(t0,t0*10,100)
y=sin(t/t0)
t1=t;tm=max(t1)
unit='s'
if tm<10^(-6)
    t1=t*10^6
    unit='t(\mus)'
elseif tm>10^(-6) & tm <10^-(3)
    t1=t*10^3
    unit='t(ms)'
end
plot(t1,y)
set(gca,'xtick',round(linspace(min(t1),max(t1),10)*100)/100)
xlabel(unit)
























for  i=1:length(headers)
           handles.OriginalStructure.(headers{i}) = table2array(handles.OriginalDataTable(:,i));
end

for i=1:length(headers)
        if (iscell(handles.OriginalDataTable.(headers{i})(1)))
        handles.OriginalStructure.(headers{i}) = categorical(handles.OriginalStructure.(headers{i})); %make cells - categorical
        end
end
handles.OriginalStructure.(headers{1}) = categorical(handles.OriginalStructure.(headers{1})); % Make year - categorical