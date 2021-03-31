clc;
clear all;
close all;


Table = readtable('TestUnits.xls','PreserveVariableNames', true);

headers = string(Table.Properties.VariableNames);

onlyunits = string(table2cell(Table(1,:)));

onlyunits(1) = "";

Table([1],:) = [];


x = Table.Fmin;
y = Table.Node;

x = categorical(x);
y = categorical(y);

scatter(x,y);

title('F-av = f(P-sat)','FontWeight','normal')

xlabel(headers(7)+", "+onlyunits(7))

ylabel(headers(6)+", "+onlyunits(6))

figure

xx = str2double(Table.Fmin);
y1 = str2double(Table.Psat);
y2 = str2double(Table.PAEmax);

yyaxis left
scatter(xx,y1);
xlabel(headers(7)+", "+onlyunits(7))
ylabel(headers(12)+", "+onlyunits(12))
yyaxis right
scatter(xx,y2);
ylabel(headers(13)+", "+onlyunits(13))


scatter(xx,y1,'none');

% if (handles.NewAxisWindow.Value == true)
%     figure;
% else(handles.NewAxisWindow.Value == false)
%     figure;
% end



grid minor
grid on

TTT = readtable('TestUnits.xls','PreserveVariableNames', true);

headers = TTT.Properties.VariableNames;

onlyunits = TTT(1,:);

TTT([1],:) = [];


NewHeaders(1) = cellstr(string(headers(1)+","+onlyunits(1)));


ggg = cellstr("sss"+","+"sdas");

ss = table2cell(onlyunits(1,1))

ss = string(ss);


FirstHeader = cellstr((headers(1))+", "+string(table2cell(onlyunits(1,6))));




for i=1:length(headers)   
   FirstHeader(i) = cellstr((headers(i))+" "+string(table2cell(onlyunits(1,i))));
end


NewT = TTT;


uni = table2cell(onlyunits);

uni = string(uni);

NewT.Properties.VariableUnits = uni;




TTT.Properties.VariableNames;


NewHeaders = cellstr(NewHeaders);

TTT(1,:) = [];

TTT.Properties.VariableNames = NewHeaders;


headers = TTT.Properties.VariableNames;

for  i=1:length(headers)
           handles.OriginalStructure.(headers{i}) = table2array(TTT(:,i));
end

for i=1:length(headers)
        if (iscell(TTT.(headers{i})(1)))
        handles.OriginalStructure.(headers{i}) = categorical(handles.OriginalStructure.(headers{i})); %make cells - categorical
        end
end
handles.OriginalStructure.(headers{1}) = categorical(handles.OriginalStructure.(headers{1})); % Make year - categorical


