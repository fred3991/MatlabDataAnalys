function varargout = RFDataAnalys(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RFDataAnalys_OpeningFcn, ...
                   'gui_OutputFcn',  @RFDataAnalys_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%========================================================================
% --- Executes just beforef ds RFDataAnalys is made visible.
function RFDataAnalys_OpeningFcn(hObject, eventdata, handles, varargin)

set(gcf,'toolbar','figure');

handles.ZDataPopUpAxes_1.Visible = 'off';
handles.ZDataPopUpAxes_2.Visible = 'off';
handles.LogZ_Axes1.Visible = 'off';
handles.LogZ_Axes2.Visible = 'off';
handles.InvZ_Axes1.Visible = 'off';
handles.InvZ_Axes2.Visible = 'off';
handles.Z1Label.Visible = 'off';
handles.Z2Label.Visible = 'off';
handles.PopUpGroupAxes_1.Visible = 'off';
handles.PopUpGroupAxes_2.Visible = 'off';

handles.output = hObject;
guidata(hObject, handles);

%=======================================================================
% --- Executes on button press in LoadDataButton.
function LoadDataButton_Callback(hObject, eventdata, handles)

handles.SourceFile = uigetfile('.xls'); %
set(handles.FileNameText,'String',handles.SourceFile);

handles.OriginalDataTable = readtable(handles.SourceFile, 'PreserveVariableNames', false);

headers = handles.OriginalDataTable.Properties.VariableNames;

for  i=1:length(headers)
           handles.OriginalStructure.(headers{i}) = table2array(handles.OriginalDataTable(:,i));
end

for i=1:length(headers)
        if (iscell(handles.OriginalDataTable.(headers{i})(1)))
        handles.OriginalStructure.(headers{i}) = categorical(handles.OriginalStructure.(headers{i})); %make cells - categorical
        end
end
handles.OriginalStructure.(headers{1}) = categorical(handles.OriginalStructure.(headers{1})); % Make year - categorical
%===================================================================================================================  

handles.FilteredDataTable = handles.OriginalDataTable;
handles.FilteredStructure =  handles.OriginalStructure;

%========================================

% Creatin UItable with selecting
selector = table2cell(array2table(true(height(handles.OriginalDataTable),1)));
uitable_headers = ['X' headers]; 
table_cell = table2cell(handles.OriginalDataTable); 

data_table = [selector table_cell];

handles.UIDataTable.Data = data_table;
handles.UIDataTable.ColumnName = uitable_headers;

mtable = handles.UIDataTable; % makeing uitable sortable
jscrollpane = findjobj(mtable); % add findjobj.m to folder
jtable = jscrollpane.getViewport.getView;
jtable.setSortable(true);		% or: set(jtable,'Sortable','on');
jtable.setColumnAutoResizable(true);

SetGroups(handles.PopUpMenuFilter1,eventdata, handles); %fill categorical filters 1
SetGroups(handles.PopUpMenuFilter2,eventdata, handles);%  2
SetGroups(handles.PopUpMenuFilter3,eventdata, handles);% 3

SetFilterNumber(handles.PopUpNumFilter1,eventdata, handles);% fill number filters 1
SetFilterNumber(handles.PopUpNumFilter2,eventdata, handles);% 2
SetFilterNumber(handles.PopUpNumFilter3,eventdata, handles);%  3

SetChartTypes(handles.ChartTypesAxes_1,eventdata, handles); % chart types 1
SetChartTypes(handles.ChartTypesAxes_2,eventdata, handles); % 2

SetDataToAxis(handles.XDataPopUpAxes_1, eventdata, handles); %set variables 1 to XYZ selector
SetDataToAxis(handles.YDataPopUpAxes_1, eventdata, handles); % 
SetDataToAxis(handles.ZDataPopUpAxes_1, eventdata, handles); %

SetDataToAxis(handles.XDataPopUpAxes_2, eventdata, handles); % set variables 1 to XYZ selector
SetDataToAxis(handles.YDataPopUpAxes_2, eventdata, handles); %
SetDataToAxis(handles.ZDataPopUpAxes_2, eventdata, handles); %

SetGroups(handles.PopUpGroupAxes_1, eventdata, handles);
SetGroups(handles.PopUpGroupAxes_2, eventdata, handles);

handles.output = hObject;
guidata(hObject, handles);
% handles    structure with handles and user data (see GUIDATA)
%================================================================================================
%====================Chart Types=================================================================
function SetChartTypes(hObject,~, handles)  % Function Set Chart Types
ChartTypes = {'Scatter','Scatter Groupe','Pie chart',...
              'Spider Plot' , 'GScatter' , 'GScatter 3D',...
              'Stem','GStem', 'GStem 3D',...
              'Simple Bar chart','Horz Bar chart',...
              'Bar Multi-Param.', 'Horz Bar Multi-Param.',...
              'Parallel Coordinates'}
set(hObject, 'string', ChartTypes);
%================================================================================================

%=============Set Data To axes ==================================================================
function SetDataToAxis(hObject,~, handles) % Set data to XYZ from struct - all   
set(hObject, 'string', fieldnames(handles.OriginalStructure));
%================================================================================================

%=============Set Groups to Grouped Data ========================================================
function SetGroups(hObject,~, handles)  % Set Group categorical for group scatter plot and filters
fn = fieldnames(handles.OriginalStructure); % fieldnames of structure
names = cell(length(fieldnames(handles.OriginalStructure)),1); 
for k=1:length(fieldnames(handles.OriginalStructure))
    if(iscategorical(handles.OriginalStructure.(fn{k})) )
         names{k} = [fn{k}];
    end
end
names = names(~cellfun('isempty',names));
set(hObject, 'string', names);
%================================================================================================

%=============Set Numbered Data==================================================================
function SetFilterNumber(hObject,~, handles)
fn = fieldnames(handles.OriginalStructure);
filter_num_names = cell(length(fieldnames(handles.OriginalStructure)),1);
for k=1:length(fieldnames(handles.OriginalStructure))
    if(isnumeric(handles.OriginalStructure.(fn{k})))      
         filter_num_names{k} = [fn{k}];
    end
end
filter_num_names = filter_num_names(~cellfun('isempty',filter_num_names))
filter_num_names = flip(filter_num_names);
set(hObject, 'string', filter_num_names);

%================================================================================================
%===================== Select Chart Types Axes_1 ======================================================
function ChartTypesAxes_1_Callback(hObject, eventdata, handles)

spider_param_list = handles.OriginalDataTable.Properties.VariableNames;   
handles.jListAxes1 = java.util.ArrayList;  % any java.util.List will be ok
for  i=1:length(spider_param_list)
    handles.jListAxes1.add(i-1, char(spider_param_list(i)));
end
handles.jCBListAxes1 = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.jListAxes1);
ChartTypeSelectIndex = get(handles.ChartTypesAxes_1, 'Value');

switch ChartTypeSelectIndex
case 1 %Scatter Plot - X, Y, Only
%Off       
set(handles.ZDataPopUpAxes_1, 'Visible',false);
set(handles.InvZ_Axes1, 'Visible',false);
set(handles.LogZ_Axes1, 'Visible',false);
set(handles.Z1Label,'Visible', false); 
set(handles.PopUpGroupAxes_1, 'Visible' ,false);
%On
set(handles.XDataPopUpAxes_1, 'Visible',true); 
set(handles.YDataPopUpAxes_1, 'Visible',true); 
set(handles.InvX_Axes1, 'Visible',true);
set(handles.InvY_Axes1, 'Visible',true);  
set(handles.LogX_Axes1, 'Visible',true);  
set(handles.LogY_Axes1, 'Visible',true);
set(handles.X1Label,'Visible', true);
set(handles.Y1Label,'Visible', true);
%CheckBoxList
handles.jScrollPane1Axes1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes1);
[~,~] = javacomponent(handles.jScrollPane1Axes1,[330,4,150,105],gcf);
handles.jScrollPane1Axes1.setVisible(false)
refresh(gcf)

case 2 % Group Scatter Plot
%Off   
set(handles.ZDataPopUpAxes_1, 'Visible',false);
set(handles.InvZ_Axes1, 'Visible',false);
set(handles.LogZ_Axes1, 'Visible',false);
set(handles.Z1Label,'Visible', false);
%on
set(handles.PopUpGroupAxes_1, 'Visible', true);  
set(handles.XDataPopUpAxes_1, 'Visible',true);
set(handles.YDataPopUpAxes_1, 'Visible',true);   
set(handles.InvX_Axes1, 'Visible',true);
set(handles.InvY_Axes1, 'Visible',true);  
set(handles.LogX_Axes1, 'Visible',true);  
set(handles.LogY_Axes1, 'Visible',true);
set(handles.X1Label,'Visible', true);
set(handles.Y1Label,'Visible', true); 
%CheckBoxList
handles.jScrollPane1Axes1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes1);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes1,[330,4,150,105],gcf);
handles.jScrollPane1Axes1.setVisible(false)
refresh(gcf)

case 3 % Pie
%Off    
set(handles.ZDataPopUpAxes_1, 'Visible',false);
set(handles.InvZ_Axes1, 'Visible',false);
set(handles.LogZ_Axes1, 'Visible',false);
set(handles.Z1Label,'Visible', false);
set(handles.PopUpGroupAxes_1, 'Visible' ,false);
set(handles.Y1Label, 'Visible', false);
set(handles.YDataPopUpAxes_1, 'Visible',false);   
set(handles.InvX_Axes1, 'Visible',false);
set(handles.InvY_Axes1, 'Visible',false);   
set(handles.LogX_Axes1, 'Visible',false);  
set(handles.LogY_Axes1, 'Visible',false);
%On
set(handles.X1Label, 'Visible', true); 
set(handles.XDataPopUpAxes_1, 'Visible',true);
%CheckBoxList
handles.jScrollPane1Axes1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes1);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes1,[330,4,150,105],gcf);
handles.jScrollPane1Axes1.setVisible(false)
refresh(gcf)
    
case 4 %Spider Chart
%Off       
set(handles.ZDataPopUpAxes_1, 'Visible',false);
set(handles.InvZ_Axes1, 'Visible',false);
set(handles.LogZ_Axes1, 'Visible',false);
set(handles.Z1Label, 'Visible', false);      
set(handles.PopUpGroupAxes_1,'Visible', false);
set(handles.XDataPopUpAxes_1, 'Visible',false);
set(handles.X1Label, 'Visible',false);     
set(handles.XDataPopUpAxes_1, 'Visible',false);
set(handles.YDataPopUpAxes_1, 'Visible',false);    
set(handles.InvX_Axes1, 'Visible',false);
set(handles.InvY_Axes1, 'Visible',false);   
set(handles.LogX_Axes1, 'Visible',false);  
set(handles.LogY_Axes1, 'Visible',false);
set(handles.Y1Label, 'Visible', false);
%CheckBoxList On
handles.jScrollPane1Axes1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes1);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes1,[330,4,150,105],gcf);
handles.jScrollPane1Axes1.setVisible(true)        
refresh(gcf)
    
case 5 %
%On
set(handles.PopUpGroupAxes_1, 'Visible', true);
set(handles.XDataPopUpAxes_1, 'Visible',true);
set(handles.YDataPopUpAxes_1, 'Visible',true);   
set(handles.InvX_Axes1, 'Visible',true);
set(handles.InvY_Axes1, 'Visible',true);    
set(handles.LogX_Axes1, 'Visible',true);  
set(handles.LogY_Axes1, 'Visible',true);
set(handles.X1Label,'Visible', true);
set(handles.Y1Label,'Visible', true)

set(handles.Z1Label, 'Visible', false);
set(handles.LogZ_Axes1, 'Visible',false);
set(handles.InvZ_Axes1, 'Visible',false);  
set(handles.ZDataPopUpAxes_1, 'Visible',false); 

%CheckBoxList
handles.jScrollPane1Axes1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes1);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes1,[330,4,150,105],gcf);
handles.jScrollPane1Axes1.setVisible(false)
refresh(gcf)
    
case 6
%On         
set(handles.PopUpGroupAxes_1, 'Visible', true);            
set(handles.XDataPopUpAxes_1, 'Visible',true);
set(handles.YDataPopUpAxes_1, 'Visible',true);
set(handles.ZDataPopUpAxes_1, 'Visible',true);  
set(handles.InvX_Axes1, 'Visible',true);
set(handles.InvY_Axes1, 'Visible',true);
set(handles.InvZ_Axes1, 'Visible',true);   
set(handles.LogX_Axes1, 'Visible',true);  
set(handles.LogY_Axes1, 'Visible',true);
set(handles.LogZ_Axes1, 'Visible',true);   
set(handles.X1Label, 'Visible', true);
set(handles.Y1Label, 'Visible', true);
set(handles.Z1Label, 'Visible', true);
%CheckBoxList
handles.jScrollPane1Axes1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes1);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes1,[330,4,150,105],gcf);
handles.jScrollPane1Axes1.setVisible(false)
refresh(gcf)         
    
case 7 %stem like usual scatter
%Off
set(handles.ZDataPopUpAxes_1, 'Visible',false);
set(handles.InvZ_Axes1, 'Visible',false);
set(handles.LogZ_Axes1, 'Visible',false);
set(handles.Z1Label, 'Visible', false);
set(handles.PopUpGroupAxes_1, 'Visible', false); 
%On
set(handles.XDataPopUpAxes_1, 'Visible',true);
set(handles.YDataPopUpAxes_1, 'Visible',true);  
set(handles.InvX_Axes1, 'Visible',true);
set(handles.InvY_Axes1, 'Visible',true);   
set(handles.LogX_Axes1, 'Visible',true);  
set(handles.LogY_Axes1, 'Visible',true);
set(handles.X1Label,'Visible', true);
set(handles.Y1Label,'Visible', true);
%CheckBoxList
handles.jScrollPane1Axes1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes1);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes1,[330,4,150,105],gcf);
handles.jScrollPane1Axes1.setVisible(false)
refresh(gcf)
        
case 8
%Off
set(handles.ZDataPopUpAxes_1, 'Visible',false);
set(handles.InvZ_Axes1, 'Visible',false);
set(handles.LogZ_Axes1, 'Visible',false);
set(handles.Z1Label,'Visible', false);
%On
set(handles.PopUpGroupAxes_1, 'Visible', true);  
set(handles.XDataPopUpAxes_1, 'Visible',true);
set(handles.YDataPopUpAxes_1, 'Visible',true); 
set(handles.InvX_Axes1, 'Visible',true);
set(handles.InvY_Axes1, 'Visible',true);  
set(handles.LogX_Axes1, 'Visible',true);  
set(handles.LogY_Axes1, 'Visible',true);
set(handles.X1Label, 'Visible', true);
set(handles.Y1Label, 'Visible', true);
%CheckBoxList 
handles.jScrollPane1Axes1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes1);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes1,[330,4,150,105],gcf);
handles.jScrollPane1Axes1.setVisible(false)
refresh(gcf)
    
case 9
%On       
set(handles.PopUpGroupAxes_1, 'Visible', true);          
set(handles.XDataPopUpAxes_1, 'Visible',true);
set(handles.YDataPopUpAxes_1, 'Visible',true);
set(handles.ZDataPopUpAxes_1, 'Visible',true);    
set(handles.InvX_Axes1, 'Visible',true);
set(handles.InvY_Axes1, 'Visible',true);
set(handles.InvZ_Axes1, 'Visible',true);  
set(handles.LogX_Axes1, 'Visible',true);  
set(handles.LogY_Axes1, 'Visible',true);
set(handles.LogZ_Axes1, 'Visible',true);   
set(handles.X1Label, 'Visible', true);
set(handles.Y1Label, 'Visible', true);
set(handles.Z1Label, 'Visible', true);
%CheckBoxList 
handles.jScrollPane1Axes1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes1);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes1,[330,4,150,105],gcf);
handles.jScrollPane1Axes1.setVisible(false);
refresh(gcf)
    
case 10
%Off
set(handles.ZDataPopUpAxes_1, 'Visible',false);
set(handles.InvZ_Axes1, 'Visible',false);
set(handles.LogZ_Axes1, 'Visible',false);
set(handles.Z1Label,'Visible', false);
set(handles.PopUpGroupAxes_1, 'Visible', false);
set(handles.YDataPopUpAxes_1, 'Visible',false);
set(handles.InvX_Axes1, 'Visible',false);
set(handles.InvY_Axes1, 'Visible',false); 
set(handles.LogX_Axes1, 'Visible',false);  
set(handles.LogY_Axes1, 'Visible',false);
set(handles.Y1Label, 'Visible', false);
%On
set(handles.XDataPopUpAxes_1, 'Visible',true);
set(handles.X1Label,'Visible', true);  
%CheckBoxList     
handles.jScrollPane1Axes1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes1);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes1,[330,4,150,105],gcf);
handles.jScrollPane1Axes1.setVisible(false)
refresh(gcf)  
    
case 11
%Off     
set(handles.ZDataPopUpAxes_1, 'Visible',false);
set(handles.InvZ_Axes1, 'Visible',false);
set(handles.LogZ_Axes1, 'Visible',false);
set(handles.Z1Label,'Visible',false);
set(handles.PopUpGroupAxes_1,'Visible', false);
set(handles.YDataPopUpAxes_1, 'Visible',false);   
set(handles.InvX_Axes1, 'Visible',false);
set(handles.InvY_Axes1, 'Visible',false);  
set(handles.LogX_Axes1, 'Visible',false);  
set(handles.LogY_Axes1, 'Visible',false);
set(handles.Y1Label, 'Visible', false);
%On
set(handles.XDataPopUpAxes_1, 'Visible',true);
set(handles.X1Label,'Visible', true);
%CheckBoxList  
handles.jScrollPane1Axes1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes1);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes1,[330,4,150,105],gcf);
handles.jScrollPane1Axes1.setVisible(false)
refresh(gcf)
        
case 12
%Off     
set(handles.ZDataPopUpAxes_1, 'Visible',false);
set(handles.InvZ_Axes1, 'Visible',false);
set(handles.LogZ_Axes1, 'Visible',false);
set(handles.Z1Label,'Visible',false);
set(handles.PopUpGroupAxes_1,'Visible', false); 
set(handles.XDataPopUpAxes_1, 'Visible',false);
set(handles.YDataPopUpAxes_1, 'Visible',false);
set(handles.InvX_Axes1, 'Visible',false);
set(handles.InvY_Axes1, 'Visible',false);
set(handles.LogX_Axes1, 'Visible',false);  
set(handles.LogY_Axes1, 'Visible',false);
set(handles.X1Label,'Visible', false);
set(handles.Y1Label, 'Visible', false);
%CheckBoxList  ON
handles.jScrollPane1Axes1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes1);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes1,[330,4,150,105],gcf);
handles.jScrollPane1Axes1.setVisible(true)
refresh(gcf)
     
case 13
        
set(handles.ZDataPopUpAxes_1, 'Visible',false);
set(handles.InvZ_Axes1, 'Visible',false);
set(handles.LogZ_Axes1, 'Visible',false);
set(handles.Z1Label,'Visible',false);
set(handles.PopUpGroupAxes_1,'Visible', false);  
set(handles.XDataPopUpAxes_1, 'Visible',false);
set(handles.YDataPopUpAxes_1, 'Visible',false);  
set(handles.InvX_Axes1, 'Visible',false);
set(handles.InvY_Axes1, 'Visible',false);  
set(handles.LogX_Axes1, 'Visible',false);  
set(handles.LogY_Axes1, 'Visible',false);
set(handles.X1Label,'Visible', false); 
set(handles.Y1Label, 'Visible', false);
%CheckBoxList  ON   
handles.jScrollPane1Axes1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes1);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes1,[330,4,150,105],gcf);
handles.jScrollPane1Axes1.setVisible(true)
refresh(gcf)

case 14
%Off        
set(handles.ZDataPopUpAxes_1, 'Visible',false);
set(handles.InvZ_Axes1, 'Visible',false);
set(handles.LogZ_Axes1, 'Visible',false);
set(handles.Z1Label,'Visible',false); 
set(handles.XDataPopUpAxes_1, 'Visible',false);
set(handles.YDataPopUpAxes_1, 'Visible',false);   
set(handles.InvX_Axes1, 'Visible',false);
set(handles.InvY_Axes1, 'Visible',false);  
set(handles.LogX_Axes1, 'Visible',false);  
set(handles.LogY_Axes1, 'Visible',false);
set(handles.X1Label,'Visible', false); 
set(handles.Y1Label, 'Visible', false);
%On
set(handles.PopUpGroupAxes_1,'Visible', true);
%CheckBoxList  ON   
handles.jScrollPane1Axes1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes1);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes1,[330,4,150,105],gcf);
handles.jScrollPane1Axes1.setVisible(true)
refresh(gcf)   
    
end 
handles.output = hObject;
guidata(hObject, handles);

%=============================================================================

%======Executes on button press in DrawButton_Axes1===========================
function DrawButton_Axes1_Callback(hObject, eventdata, handles) %

%set axes switches to default
set(handles.GridAxes1CheckBox, 'Value', false);
%set axes to default
axes(handles.axes1);
setpixelposition(handles.axes1, [60 222 421 331])
cla;
reset(gca);    
xlabel('-');
ylabel('-');      
legend('off'); 

%Selecting Data
if (handles.RB_Axes1_OriginalData.Value == 1)   
    handles.DrawData = handles.OriginalStructure;
else
    handles.DrawData = handles.FilteredStructure;
end
if (handles.RB_Axes1_FilteredData.Value == 1) 
    handles.DrawData = handles.FilteredStructure;
else
    handles.DrawData = handles.OriginalStructure;
end

%%Selecting XYZ axis
%======X
idX = get(handles.XDataPopUpAxes_1,'Value');
itemX = get(handles.XDataPopUpAxes_1,'String');
selectedItemX = itemX{idX};
%======Y
idY = get(handles.YDataPopUpAxes_1,'Value');
itemY = get(handles.YDataPopUpAxes_1,'String');
selectedItemY = itemY{idY}; 
%======Z
idZ = get(handles.ZDataPopUpAxes_1,'Value');
itemZ = get(handles.ZDataPopUpAxes_1,'String');
selectedItemZ = itemZ{idZ};
%====== Groups
idG = get(handles.PopUpGroupAxes_1,'Value');
itemG = get(handles.PopUpGroupAxes_1,'String');
selectedItemG = itemG{idG};

%====== Set Data to axis
x=handles.DrawData.(selectedItemX);
y=handles.DrawData.(selectedItemY);
z=handles.DrawData.(selectedItemZ);

groups = {handles.DrawData.(selectedItemG)};



%Chart Type Selecting
ChartTypeSelectIndex = get(handles.ChartTypesAxes_1, 'Value');

%   Chart Types
switch ChartTypeSelectIndex
    

    
%Scatter ========================================================================================
case 1
axes(handles.axes1);
datacursormode on; 
dcm_obj = datacursormode(gcf);
set(dcm_obj,'DisplayStyle','Window',...
'SnapToDataVertex','off','Enable','on')
sz = 35;     
s = scatter(x,y,sz,'o','k')
xlabel(selectedItemX);
ylabel(selectedItemY);                    
s.DataTipTemplate.DataTipRows(1).Label = selectedItemX;
s.DataTipTemplate.DataTipRows(2).Label = selectedItemY;    
fn = fieldnames(handles.OriginalStructure);
for   datatipindex=1:length(fieldnames(handles.DrawData))  
    s.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow(string(fn(datatipindex)),handles.DrawData.(fn{datatipindex}));
end
hold off

% Group Scatter =====================================================================================
case 2

g = gscatter(x,y,groups,'rkgb','o*hd+',7,'on',selectedItemX,selectedItemY)
legend_group = char(categories(groups{1})) 
datacursormode on; 
dcm_obj = datacursormode(gcf);
set(dcm_obj,'DisplayStyle','window',...
    'SnapToDataVertex','off','Enable','on')   
hold on
sz = 180;
s = scatter(x,y,sz,'o','w') 
xlabel(selectedItemX);
ylabel(selectedItemY); 

s.DataTipTemplate.DataTipRows(1).Label = selectedItemX;
s.DataTipTemplate.DataTipRows(2).Label = selectedItemY;    
fn = fieldnames(handles.DrawData);
for   datatipindex=1:length(fieldnames(handles.DrawData))  
    s.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow(string(fn(datatipindex)),handles.DrawData.(fn{datatipindex}));
end
legend(legend_group);        
hold off





% Pie chart ==========================================================================================
case 3
pie(x);
hold off




case 4
% Spider/Radar Chart for selected elements============================================================
setpixelposition(handles.axes1, [70 222 350 270]) %Set new size of axes
spider_params = handles.jCBListAxes1.getCheckedValues; % get list of selected params
cell_param = {}; % clear list
for i=1:size(spider_params)
    cell_param(:,i) = cellstr(spider_params.get(i-1)) % ---> to string array
end 

data = handles.UIDataTable.Data; % get list of data from disp UItable
cell_rows = size(data)              % number of rows of UItable

for i=1:cell_rows(1);           % checking 1 row for selected items
    selectedItems(i,1) = cell2mat(data(i,1))
end

selectedItems = logical(selectedItems); % ==>> transform to logical array
k = find(selectedItems);                %===find selected items index      

if (handles.RB_Axes1_OriginalData.Value == 1)   
    for j=1:length(k)         
    SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
else    
    for j=1:length(k)
    SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
end
if (handles.RB_Axes1_FilteredData.Value == 1) 
    for j=1:length(k)
    SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
else
    for j=1:length(k)         
    SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
end

headers = SortedTable.Properties.VariableNames; %get VariableNames of sorted table
    
for i=1:length(headers)
    handles.DrawData.(headers{i}) = table2array(SortedTable(:,i));
end
    
% creating structure from selected table elements
    for i=1:length(headers)
        if (iscell(SortedTable.(headers{i})(1)))
        handles.DrawData.(headers{i}) = categorical(handles.DrawData.(headers{i})); %make cells - categorical
        end
    end
handles.DrawData.(headers{1}) = categorical(handles.DrawData.(headers{1})); % Make year - categorical 
    % Creating  Matrix of elements for Spider Chart Element (i - number of elements, j)
for i=1:height(SortedTable)   
    for j=1:length(cell_param)
        Element(i,j) = handles.DrawData.(char(cell_param(j)))(i)   
    end
end  
el_num = size(Element)
% creating Names for selecting elements in spider chart
for i=1:el_num(1)
    ElementNames(1,i) = string({(k(i))+". "+SortedTable.Author(i)}); % Disply indexes an Autors
end
% Drawing Spider chart
ElementNames  = cellstr(ElementNames);% Transforming to correct type for legend
ElementNames  = char(ElementNames);
AxesLabels = cell_param; % Selected Params
AxesInterval = 5;
FillOption = 'on';
FillTransparency = 0.3;
spider_plot_R2019b(Element,...
      'AxesLabels', AxesLabels,...
      'AxesInterval', AxesInterval,...
      'FillOption', FillOption,...
      'FillTransparency', FillTransparency);
legend({ElementNames}); %Legend - ElementNumber - TO DO replace with Original Index and Autor
hold off
  
case 5
    
selected_group = categories(handles.DrawData.(selectedItemG)); %selected group for Gscatter
    
for i=1:length(selected_group)
        
    x=handles.DrawData.(selectedItemX)(handles.DrawData.(selectedItemG) == selected_group(i));
    y=handles.DrawData.(selectedItemY)(handles.DrawData.(selectedItemG) == selected_group(i));                     
    scatter(x,y,75,'d');           
    hold on
     
end    
    
datacursormode on; 
dcm_obj = datacursormode(gcf);
set(dcm_obj,'DisplayStyle','window',...
    'SnapToDataVertex','off','Enable','on')                         
sz = 1;
x=handles.DrawData.(selectedItemX);
y=handles.DrawData.(selectedItemY);
s = scatter(x,y,sz,'.','w') 
xlabel(selectedItemX);
ylabel(selectedItemY); 
s.DataTipTemplate.DataTipRows(1).Label = selectedItemX;
s.DataTipTemplate.DataTipRows(2).Label = selectedItemY;    

fn = fieldnames(handles.DrawData);
for   datatipindex=1:length(fieldnames(handles.DrawData))  
    s.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow(string(fn(datatipindex)),handles.DrawData.(fn{datatipindex}));
end 
legend({char(selected_group)})
hold off
  
case 6

selected_group = categories(handles.DrawData.(selectedItemG));    
for i=1:length(selected_group)      
    x=handles.DrawData.(selectedItemX)(handles.DrawData.(selectedItemG) == selected_group(i));
    y=handles.DrawData.(selectedItemY)(handles.DrawData.(selectedItemG) == selected_group(i));
    z=handles.DrawData.(selectedItemZ)(handles.DrawData.(selectedItemG) == selected_group(i));
    scatter3(x,y,z,'o');            
    hold on
end          

datacursormode on; 
dcm_obj = datacursormode(gcf);
set(dcm_obj,'DisplayStyle','window',...
'SnapToDataVertex','off','Enable','on')                   
sz = 180;
x=handles.DrawData.(selectedItemX);
y=handles.DrawData.(selectedItemY);
z=handles.DrawData.(selectedItemZ);
s = scatter3(x,y,z,sz,'o','w') 

xlabel(selectedItemX);
ylabel(selectedItemY);
zlabel(selectedItemZ); 

s.DataTipTemplate.DataTipRows(1).Label = selectedItemX;
s.DataTipTemplate.DataTipRows(2).Label = selectedItemY;
s.DataTipTemplate.DataTipRows(3).Label = selectedItemZ;   

fn = fieldnames(handles.DrawData);
for datatipindex=1:length(fieldnames(handles.DrawData))  
    s.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow(string(fn(datatipindex)),handles.DrawData.(fn{datatipindex}));
end   
legend({char(selected_group)})   
hold off
  
case 7 % Stem
        
datacursormode on; 
dcm_obj = datacursormode(gcf);
set(dcm_obj,'DisplayStyle','Window',...
    'SnapToDataVertex','off','Enable','on')
sz = 35;     
s = stem(x,y,':k')
xlabel(selectedItemX);
ylabel(selectedItemY);                    
s.DataTipTemplate.DataTipRows(1).Label = selectedItemX;
s.DataTipTemplate.DataTipRows(2).Label = selectedItemY;  
fn = fieldnames(handles.OriginalStructure);
for  datatipindex=1:length(fieldnames(handles.DrawData))  
    s.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow(string(fn(datatipindex)),handles.DrawData.(fn{datatipindex}));
end
hold off

case 8 %GStem
    
selected_group = categories(handles.DrawData.(selectedItemG));  
    
for i=1:length(selected_group)      
    x=handles.DrawData.(selectedItemX)(handles.DrawData.(selectedItemG) == selected_group(i));
    y=handles.DrawData.(selectedItemY)(handles.DrawData.(selectedItemG) == selected_group(i)); 
    stem(x,y,...
    '--o',...     
    'MarkerSize',5,...
    'LineWidth',0.75)
    hold on
end

datacursormode on; 
dcm_obj = datacursormode(gcf);
set(dcm_obj,'DisplayStyle','window',...
     'SnapToDataVertex','off','Enable','on')   
sz = 180;
hold on
x=handles.DrawData.(selectedItemX);
y=handles.DrawData.(selectedItemY);
s = scatter(x,y,sz,'o','w') 
xlabel(selectedItemX);
ylabel(selectedItemY); 
     
s.DataTipTemplate.DataTipRows(1).Label = selectedItemX;
s.DataTipTemplate.DataTipRows(2).Label = selectedItemY;    

fn = fieldnames(handles.DrawData);
for datatipindex=1:length(fieldnames(handles.DrawData))    
    s.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow(string(fn(datatipindex)),handles.DrawData.(fn{datatipindex}));       
end
legend({char(selected_group)})
hold off
     
case 9
    
selected_group = categories(handles.DrawData.(selectedItemG));    
for i=1:length(selected_group)      
    x=handles.DrawData.(selectedItemX)(handles.DrawData.(selectedItemG) == selected_group(i));
    y=handles.DrawData.(selectedItemY)(handles.DrawData.(selectedItemG) == selected_group(i));
    z=handles.DrawData.(selectedItemZ)(handles.DrawData.(selectedItemG) == selected_group(i));
    stem3(x,y,z,'o');            
    hold on
end          
datacursormode on; 
dcm_obj = datacursormode(gcf);
set(dcm_obj,'DisplayStyle','window',...
    'SnapToDataVertex','off','Enable','on')   
                       
sz = 180;
x=handles.DrawData.(selectedItemX);
y=handles.DrawData.(selectedItemY);
z=handles.DrawData.(selectedItemZ);
s = scatter3(x,y,z,sz,'o','w') 
xlabel(selectedItemX);
ylabel(selectedItemY);
zlabel(selectedItemZ); 

s.DataTipTemplate.DataTipRows(1).Label = selectedItemX;
s.DataTipTemplate.DataTipRows(2).Label = selectedItemY;
s.DataTipTemplate.DataTipRows(3).Label = selectedItemZ;   

fn = fieldnames(handles.DrawData);
for   datatipindex=1:length(fieldnames(handles.DrawData))  
    s.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow(string(fn(datatipindex)),handles.DrawData.(fn{datatipindex}));
end   
legend({char(selected_group)})   
hold off 
%==============================================================
case 10
        
data = handles.UIDataTable.Data; % get list of data from disp UItable
cell_rows = size(data)              % number of rows of UItable
for i=1:cell_rows(1);           % checking 1 row for selected items
    selectedItems(i,1) = cell2mat(data(i,1))
end

selectedItems = logical(selectedItems); % ==>> transform to logical array
k = find(selectedItems);                %===find selected items index      

if (handles.RB_Axes1_OriginalData.Value == 1)   
    for j=1:length(k)         
        SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
else    
    for j=1:length(k)
        SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
end
if (handles.RB_Axes1_FilteredData.Value == 1) 
    for j=1:length(k)
    SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
else
    for j=1:length(k)         
    SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
end
                   
for i=1:height(SortedTable) %length selected elements
    BarParameters(i) = handles.DrawData.(selectedItemX)(i)
end
bar(BarParameters,0.5)
ylabel(selectedItemX);       
hold off
    
case 11    
data = handles.UIDataTable.Data; % get list of data from disp UItable
cell_rows = size(data)              % number of rows of UItable

for i=1:cell_rows(1);           % checking 1 row for selected items
    selectedItems(i,1) = cell2mat(data(i,1))
end

selectedItems = logical(selectedItems); % ==>> transform to logical array
k = find(selectedItems);                %===find selected items index    
    
if (handles.RB_Axes1_OriginalData.Value == 1)   
    for j=1:length(k)         
        SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
else    
    for j=1:length(k)
        SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
end
if (handles.RB_Axes1_FilteredData.Value == 1) 
    for j=1:length(k)
        SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
else
    for j=1:length(k)         
        SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
end
                   
for i=1:height(SortedTable) %length selected elements
    BarParameters(i) = handles.DrawData.(selectedItemX)(i)
end
barh(BarParameters,0.5)
xlabel(selectedItemX);    
hold off

case 12
        
bar_params = handles.jCBListAxes1.getCheckedValues; % get list of selected params
cell_param = {}; % clear list
for i=1:size(bar_params)
    cell_param(:,i) = cellstr(bar_params.get(i-1)) % ---> to string array
end 
data = handles.UIDataTable.Data; % get list of data from disp UItable
cell_rows = size(data)              % number of rows of UItable
for i=1:cell_rows(1);           % checking 1 row for selected items
    selectedItems(i,1) = cell2mat(data(i,1))
end
selectedItems = logical(selectedItems); % ==>> transform to logical array
k = find(selectedItems);                %===find selected items index      

if (handles.RB_Axes1_OriginalData.Value == 1)   
    for j=1:length(k)         
        SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
else    
    for j=1:length(k)
        SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
end
if (handles.RB_Axes1_FilteredData.Value == 1) 
    for j=1:length(k)
        SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
else
    for j=1:length(k)         
        SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
end 
headers = SortedTable.Properties.VariableNames; %get VariableNames of sorted table
    
for i=1:length(headers)
    handles.DrawData.(headers{i}) = table2array(SortedTable(:,i));
end
    % creating structure from selected table elements
for i=1:length(headers)
    if (iscell(SortedTable.(headers{i})(1)))
        handles.DrawData.(headers{i}) = categorical(handles.DrawData.(headers{i})); %make cells - categorical
    end
end
handles.DrawData.(headers{1}) = categorical(handles.DrawData.(headers{1})); % Make year - categorical
% Creating  Matrix of elements for Spider Chart Element (i - number of elements, j)       
for i=1:height(SortedTable)   %height(SortedTable) % Selected elements   
    for j=1:length(cell_param)
        Element(i,j) = handles.DrawData.(char(cell_param(j)))(i)   
    end
end
bar(Element,'grouped')
legend({char(cell_param)})
hold off 

case 13
        
bar_params = handles.jCBListAxes1.getCheckedValues; % get list of selected params

cell_param = {}; % clear list
for i=1:size(bar_params)
    cell_param(:,i) = cellstr(bar_params.get(i-1)) % ---> to string array
end 

data = handles.UIDataTable.Data; % get list of data from disp UItable
cell_rows = size(data)              % number of rows of UItable

for i=1:cell_rows(1);           % checking 1 row for selected items
    selectedItems(i,1) = cell2mat(data(i,1))
end

selectedItems = logical(selectedItems); % ==>> transform to logical array
k = find(selectedItems);                %===find selected items index    
    
 
if (handles.RB_Axes1_OriginalData.Value == 1)   
    for j=1:length(k)         
        SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
else    
    for j=1:length(k)
        SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
end
if (handles.RB_Axes1_FilteredData.Value == 1) 
    for j=1:length(k)
        SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
else
    for j=1:length(k)         
        SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
end
headers = SortedTable.Properties.VariableNames; %get VariableNames of sorted table
    
for i=1:length(headers)
    handles.DrawData.(headers{i}) = table2array(SortedTable(:,i));
end 
% creating structure from selected table elements
for i=1:length(headers)
    if (iscell(SortedTable.(headers{i})(1)))
        handles.DrawData.(headers{i}) = categorical(handles.DrawData.(headers{i})); %make cells - categorical
    end
end
handles.DrawData.(headers{1}) = categorical(handles.DrawData.(headers{1})); % Make year - categorical 
    % Creating  Matrix of elements for Spider Chart Element (i - number of elements, j)       
for i=1:height(SortedTable)   %height(SortedTable) % Selected elements   
    for j=1:length(cell_param)
        Element(i,j) = handles.DrawData.(char(cell_param(j)))(i)   
    end
end
barh(Element,'grouped')
legend({char(cell_param)})
hold off 
        
case 14
          
paral_params = handles.jCBListAxes1.getCheckedValues; % get list of selected params

cell_param = {}; % clear list
for i=1:size(paral_params)
    cell_param(:,i) = cellstr(paral_params.get(i-1)) % ---> to string array
end 

data = handles.UIDataTable.Data; % get list of data from disp UItable
cell_rows = size(data)              % number of rows of UItable
for i=1:cell_rows(1);           % checking 1 row for selected items
    selectedItems(i,1) = cell2mat(data(i,1))
end

selectedItems = logical(selectedItems); % ==>> transform to logical array
k = find(selectedItems);                %===find selected items index    

if (handles.RB_Axes1_OriginalData.Value == 1)   
    for j=1:length(k)         
        SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
else    
    for j=1:length(k)
        SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
end
if (handles.RB_Axes1_FilteredData.Value == 1) 
    for j=1:length(k)
        SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
else
    for j=1:length(k)         
        SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
end              
for j=1:length(cell_param)              
    for i=1:height(SortedTable)           
        ParalelStruct.(cell_param{j})(i) = handles.DrawData.(cell_param{j})(i)         
    end
    ParalelStruct.(cell_param{j}) = transpose(ParalelStruct.(cell_param{j}))          
end
ParallelTable = struct2table(ParalelStruct);
figure;
p = parallelplot(ParallelTable);
p.GroupVariable = selectedItemG;
p.LineStyle = {'-'}
p.LineWidth = [1.5] 
end

% if handles.NewAxisWindow.Value == true
%     refline;
% end

%===============================================================================================================
%============= in ChartTypesAxes_2.
function ChartTypesAxes_2_Callback(hObject, eventdata, handles)           
   
spider_param_list = handles.OriginalDataTable.Properties.VariableNames;   
handles.jListAxes2 = java.util.ArrayList;  % any java.util.List will be ok
for  i=1:length(spider_param_list)
        handles.jListAxes2.add(i-1, char(spider_param_list(i)));
end
handles.jCBListAxes2 = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.jListAxes2);
ChartTypeSelectIndex = get(handles.ChartTypesAxes_2, 'Value');

switch ChartTypeSelectIndex
case 1 %Scatter Plot
%Off       
set(handles.ZDataPopUpAxes_2, 'Visible',false);
set(handles.InvZ_Axes2, 'Visible',false);
set(handles.LogZ_Axes2, 'Visible',false);
set(handles.Z2Label,'Visible', false); 
set(handles.PopUpGroupAxes_2, 'Visible' ,false);
%On
set(handles.XDataPopUpAxes_2, 'Visible',true); 
set(handles.YDataPopUpAxes_2, 'Visible',true); 
set(handles.InvX_Axes2, 'Visible',true);
set(handles.InvY_Axes2, 'Visible',true);  
set(handles.LogX_Axes2, 'Visible',true);  
set(handles.LogY_Axes2, 'Visible',true);
set(handles.X2Label,'Visible', true);
set(handles.Y2Label,'Visible', true);
%CheckBoxList
handles.jScrollPane1Axes2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes2,[840,4,150,105],gcf);
handles.jScrollPane1Axes2.setVisible(false)
refresh(gcf)

case 2 % Group Scatter Plot
%Off   
set(handles.ZDataPopUpAxes_2 ,'Visible',false);
set(handles.InvZ_Axes2, 'Visible',false);
set(handles.LogZ_Axes2, 'Visible',false);
set(handles.Z2Label,'Visible', false);
%on
set(handles.PopUpGroupAxes_2, 'Visible', true);  
set(handles.XDataPopUpAxes_2, 'Visible',true);
set(handles.YDataPopUpAxes_2, 'Visible',true);   
set(handles.InvX_Axes2, 'Visible',true);
set(handles.InvY_Axes2, 'Visible',true);  
set(handles.LogX_Axes2, 'Visible',true);  
set(handles.LogY_Axes2, 'Visible',true);
set(handles.X2Label,'Visible', true);
set(handles.Y2Label,'Visible', true); 
%CheckBoxList   
handles.jScrollPane1Axes2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes2,[840,4,150,105],gcf);
handles.jScrollPane1Axes2.setVisible(false)
refresh(gcf)

case 3 % Pie
%Off    
set(handles.ZDataPopUpAxes_2, 'Visible',false);
set(handles.InvZ_Axes2, 'Visible',false);
set(handles.LogZ_Axes2, 'Visible',false);
set(handles.Z2Label,'Visible', false);
set(handles.PopUpGroupAxes_2, 'Visible' ,false);
set(handles.Y2Label, 'Visible', false);
set(handles.YDataPopUpAxes_2, 'Visible',false);   
set(handles.InvX_Axes2, 'Visible',false);
set(handles.InvY_Axes2, 'Visible',false);   
set(handles.LogX_Axes2, 'Visible',false);  
set(handles.LogY_Axes2, 'Visible',false);
%On
set(handles.X2Label, 'Visible', true); 
set(handles.XDataPopUpAxes_2, 'Visible',true);
%CheckBoxList      
handles.jScrollPane1Axes2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes2,[840,4,150,105],gcf);
handles.jScrollPane1Axes2.setVisible(false)
refresh(gcf)

case 4 %Spider Chart
%Off       
set(handles.ZDataPopUpAxes_2, 'Visible',false);
set(handles.InvZ_Axes2, 'Visible',false);
set(handles.LogZ_Axes2, 'Visible',false);
set(handles.Z2Label, 'Visible', false);      
set(handles.PopUpGroupAxes_2,'Visible', false);
set(handles.XDataPopUpAxes_2, 'Visible',false);
set(handles.X2Label, 'Visible',false);     
set(handles.XDataPopUpAxes_2, 'Visible',false);
set(handles.YDataPopUpAxes_2, 'Visible',false);    
set(handles.InvX_Axes2, 'Visible',false);
set(handles.InvY_Axes2, 'Visible',false);   
set(handles.LogX_Axes2, 'Visible',false);  
set(handles.LogY_Axes2, 'Visible',false);
set(handles.Y2Label, 'Visible', false);
%CheckBoxList On
handles.jScrollPane1Axes2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes2,[840,4,150,105],gcf);
handles.jScrollPane1Axes2.setVisible(true)        
refresh(gcf)

case 5 %
%Off 
set(handles.PopUpGroupAxes_2, 'Visible', true);
set(handles.XDataPopUpAxes_2, 'Visible',true);
set(handles.YDataPopUpAxes_2, 'Visible',true);   
set(handles.InvX_Axes2, 'Visible',true);
set(handles.InvY_Axes2, 'Visible',true);    
set(handles.LogX_Axes2, 'Visible',true);  
set(handles.LogY_Axes2, 'Visible',true);
set(handles.X2Label,'Visible', true);
set(handles.Y2Label,'Visible', true)


set(handles.Z2Label, 'Visible', false);
set(handles.LogZ_Axes2, 'Visible',false);
set(handles.InvZ_Axes2, 'Visible',false);  
set(handles.ZDataPopUpAxes_2, 'Visible',false); 


%CheckBoxList
handles.jScrollPane1Axes2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes2,[840,4,150,105],gcf);
handles.jScrollPane1Axes2.setVisible(false)
refresh(gcf)

case 6
    %On         
set(handles.PopUpGroupAxes_2, 'Visible', true);            
set(handles.XDataPopUpAxes_2, 'Visible',true);
set(handles.YDataPopUpAxes_2, 'Visible',true);
set(handles.ZDataPopUpAxes_2, 'Visible',true);  
set(handles.InvX_Axes2, 'Visible',true);
set(handles.InvY_Axes2, 'Visible',true);
set(handles.InvZ_Axes2, 'Visible',true);   
set(handles.LogX_Axes2, 'Visible',true);  
set(handles.LogY_Axes2, 'Visible',true);
set(handles.LogZ_Axes2, 'Visible',true);   
set(handles.X2Label, 'Visible', true);
set(handles.Y2Label, 'Visible', true);
set(handles.Z2Label, 'Visible', true);
%CheckBoxList
handles.jScrollPane1Axes2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes2,[840,4,150,105],gcf);
handles.jScrollPane1Axes2.setVisible(false)
refresh(gcf)  
case 7 %stem like usual scatter
%Off
set(handles.ZDataPopUpAxes_2, 'Visible',false);
set(handles.InvZ_Axes2, 'Visible',false);
set(handles.LogZ_Axes2, 'Visible',false);
set(handles.Z2Label, 'Visible', false);
set(handles.PopUpGroupAxes_2, 'Visible', false); 
%On
set(handles.XDataPopUpAxes_2, 'Visible',true);
set(handles.YDataPopUpAxes_2, 'Visible',true);  
set(handles.InvX_Axes2, 'Visible',true);
set(handles.InvY_Axes2, 'Visible',true);   
set(handles.LogX_Axes2, 'Visible',true);  
set(handles.LogY_Axes2, 'Visible',true);
set(handles.X2Label,'Visible', true);
set(handles.Y2Label,'Visible', true);
%CheckBoxList
handles.jScrollPane1Axes2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes2,[840,4,150,105],gcf);
handles.jScrollPane1Axes2.setVisible(false)
refresh(gcf) 

case 8
%Off
set(handles.ZDataPopUpAxes_2, 'Visible',false);
set(handles.InvZ_Axes2, 'Visible',false);
set(handles.LogZ_Axes2, 'Visible',false);
set(handles.Z2Label,'Visible', false);
%On
set(handles.PopUpGroupAxes_2, 'Visible', true);  
set(handles.XDataPopUpAxes_2, 'Visible',true);
set(handles.YDataPopUpAxes_2, 'Visible',true); 
set(handles.InvX_Axes2, 'Visible',true);
set(handles.InvY_Axes2, 'Visible',true);  
set(handles.LogX_Axes2, 'Visible',true);  
set(handles.LogY_Axes2, 'Visible',true);
set(handles.X2Label, 'Visible', true);
set(handles.Y2Label, 'Visible', true);
%CheckBoxList 
handles.jScrollPane1Axes2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes2,[840,4,150,105],gcf);
handles.jScrollPane1Axes2.setVisible(false);
refresh(gcf)

case 9
%On       
set(handles.PopUpGroupAxes_2, 'Visible', true);          
set(handles.XDataPopUpAxes_2, 'Visible',true);
set(handles.YDataPopUpAxes_2, 'Visible',true);
set(handles.ZDataPopUpAxes_2, 'Visible',true);    
set(handles.InvX_Axes2, 'Visible',true);
set(handles.InvY_Axes2, 'Visible',true);
set(handles.InvZ_Axes2, 'Visible',true);  
set(handles.LogX_Axes2, 'Visible',true);  
set(handles.LogY_Axes2, 'Visible',true);
set(handles.LogZ_Axes2, 'Visible',true);  
set(handles.X2Label, 'Visible', true);
set(handles.Y2Label, 'Visible', true);
set(handles.Z2Label, 'Visible', true);
%CheckBoxList 
handles.jScrollPane1Axes2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes2,[840,4,150,105],gcf);
handles.jScrollPane1Axes2.setVisible(false);
refresh(gcf)     
    
case 10
%Off
set(handles.ZDataPopUpAxes_2, 'Visible',false);
set(handles.InvZ_Axes2, 'Visible',false);
set(handles.LogZ_Axes2, 'Visible',false);
set(handles.Z2Label,'Visible', false);
set(handles.PopUpGroupAxes_2, 'Visible', false);
set(handles.YDataPopUpAxes_2, 'Visible',false);
set(handles.InvX_Axes2, 'Visible',false);
set(handles.InvY_Axes2, 'Visible',false); 
set(handles.LogX_Axes2, 'Visible',false);  
set(handles.LogY_Axes2, 'Visible',false);
set(handles.Y2Label, 'Visible', false);
%On
set(handles.XDataPopUpAxes_2, 'Visible',true);
set(handles.X2Label,'Visible', true);  
%CheckBoxList     
handles.jScrollPane1Axes2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes2,[840,4,150,105],gcf);
handles.jScrollPane1Axes2.setVisible(false);
refresh(gcf)

case 11
%Off     
set(handles.ZDataPopUpAxes_2, 'Visible',false);
set(handles.InvZ_Axes2, 'Visible',false);
set(handles.LogZ_Axes2, 'Visible',false);
set(handles.Z2Label,'Visible',false);
set(handles.PopUpGroupAxes_2,'Visible', false);
set(handles.YDataPopUpAxes_2, 'Visible',false);   
set(handles.InvX_Axes2, 'Visible',false);
set(handles.InvY_Axes2, 'Visible',false);  
set(handles.LogX_Axes2, 'Visible',false);  
set(handles.LogY_Axes2, 'Visible',false);
set(handles.Y2Label, 'Visible', false);
%On
set(handles.XDataPopUpAxes_2, 'Visible',true);
set(handles.X2Label,'Visible', true);
%CheckBoxList  
handles.jScrollPane1Axes2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes2,[840,4,150,105],gcf);
handles.jScrollPane1Axes2.setVisible(false);
refresh(gcf)
           
case 12
%Off     
set(handles.ZDataPopUpAxes_2, 'Visible',false);
set(handles.InvZ_Axes2, 'Visible',false);
set(handles.LogZ_Axes2, 'Visible',false);
set(handles.Z2Label,'Visible',false);
set(handles.PopUpGroupAxes_2,'Visible', false); 
set(handles.XDataPopUpAxes_2, 'Visible',false);
set(handles.YDataPopUpAxes_2, 'Visible',false);
set(handles.InvX_Axes2, 'Visible',false);
set(handles.InvY_Axes2, 'Visible',false);
set(handles.LogX_Axes2, 'Visible',false);  
set(handles.LogY_Axes2, 'Visible',false);
set(handles.X2Label,'Visible', false);
set(handles.Y2Label, 'Visible', false);
%CheckBoxList  ON
handles.jScrollPane1Axes2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes2,[840,4,150,105],gcf);
handles.jScrollPane1Axes2.setVisible(true);
refresh(gcf)
     
case 13
        
set(handles.ZDataPopUpAxes_2,'Visible',false);
set(handles.InvZ_Axes2, 'Visible',false);
set(handles.LogZ_Axes2, 'Visible',false);
set(handles.Z2Label,'Visible',false);
set(handles.PopUpGroupAxes_2,'Visible', false);  
set(handles.XDataPopUpAxes_2, 'Visible',false);
set(handles.YDataPopUpAxes_2, 'Visible',false);  
set(handles.InvX_Axes2, 'Visible',false);
set(handles.InvY_Axes2, 'Visible',false);  
set(handles.LogX_Axes2, 'Visible',false);  
set(handles.LogY_Axes2, 'Visible',false);
set(handles.X2Label,'Visible', false); 
set(handles.Y2Label, 'Visible', false); 
%CheckBoxList  ON   
handles.jScrollPane1Axes2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes2,[840,4,150,105],gcf);
handles.jScrollPane1Axes2.setVisible(true);
refresh(gcf)

case 14
%Off        
set(handles.ZDataPopUpAxes_2, 'Visible',false);
set(handles.InvZ_Axes2, 'Visible',false);
set(handles.LogZ_Axes2, 'Visible',false);
set(handles.Z2Label,'Visible',false); 
set(handles.XDataPopUpAxes_2, 'Visible',false);
set(handles.YDataPopUpAxes_2, 'Visible',false);   
set(handles.InvX_Axes2, 'Visible',false);
set(handles.InvY_Axes2, 'Visible',false);  
set(handles.LogX_Axes2, 'Visible',false);  
set(handles.LogY_Axes2, 'Visible',false);
set(handles.X2Label,'Visible', false); 
set(handles.Y2Label, 'Visible', false);
%On
set(handles.PopUpGroupAxes_2,'Visible', true);
%CheckBoxList  ON
handles.jScrollPane1Axes2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListAxes2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Axes2,[840,4,150,105],gcf);
handles.jScrollPane1Axes2.setVisible(true);
refresh(gcf) 

end
handles.output = hObject;
guidata(hObject, handles); 

%===========================================================================================

%====================button press in DrawButton_Axes2.
function DrawButton_Axes2_Callback(hObject, eventdata, handles)

set(handles.GridAxes2CheckBox, 'Value', false);
    
axes(handles.axes2);

setpixelposition(handles.axes2, [570 221 422 332])
cla;
reset(gca);    
xlabel('-');
ylabel('-');      
legend('off');


%Selecting Data
if (handles.RB_Axes2_OriginalData.Value == 1)   
    handles.DrawData = handles.OriginalStructure;
else
    handles.DrawData = handles.FilteredStructure;
end
if (handles.RB_Axes2_FilteredData.Value == 1) 
    handles.DrawData = handles.FilteredStructure;
else
    handles.DrawData = handles.OriginalStructure;
end

%%Selecting XYZ axis
idX = get(handles.XDataPopUpAxes_2,'Value');
itemX = get(handles.XDataPopUpAxes_2,'String');
selectedItemX = itemX{idX};
%=========
idY = get(handles.YDataPopUpAxes_2,'Value');
itemY = get(handles.YDataPopUpAxes_2,'String');
selectedItemY = itemY{idY}; 
%==========
idZ = get(handles.ZDataPopUpAxes_2,'Value');
itemZ = get(handles.ZDataPopUpAxes_2,'String');
selectedItemZ = itemZ{idZ};
%===========
idG = get(handles.PopUpGroupAxes_2,'Value');
itemG = get(handles.PopUpGroupAxes_2,'String');
selectedItemG = itemG{idG};
%============
x=handles.DrawData.(selectedItemX);
y=handles.DrawData.(selectedItemY);
z=handles.DrawData.(selectedItemZ);
groups = {handles.DrawData.(selectedItemG)};

%Chart Type Selecting
ChartTypeSelectIndex = get(handles.ChartTypesAxes_2, 'Value');

switch ChartTypeSelectIndex

    %Scatter ================================================================
case 1
    axes(handles.axes2);
    datacursormode on; 
    dcm_obj = datacursormode(gcf);
    set(dcm_obj,'DisplayStyle','Window',...
    'SnapToDataVertex','off','Enable','on')
    sz = 35;     
    s = scatter(x,y,sz,'o','k')
    xlabel(selectedItemX);
    ylabel(selectedItemY);                    
    s.DataTipTemplate.DataTipRows(1).Label = selectedItemX;
    s.DataTipTemplate.DataTipRows(2).Label = selectedItemY;    
    fn = fieldnames(handles.OriginalStructure);
    for   datatipindex=1:length(fieldnames(handles.DrawData))  
        s.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow(string(fn(datatipindex)),handles.DrawData.(fn{datatipindex}));
    end
    hold off
    

    %Group Scatter =========================================================
case 2

    g = gscatter(x,y,groups,'rkgb','o*hd+',7,'on',selectedItemX,selectedItemY)
    legend_group = char(categories(groups{1})) 
    datacursormode on; 
    dcm_obj = datacursormode(gcf);
    set(dcm_obj,'DisplayStyle','window',...
        'SnapToDataVertex','off','Enable','on')   
    hold on
    sz = 180;
    s = scatter(x,y,sz,'o','w') 
    xlabel(selectedItemX);
    ylabel(selectedItemY); 
    
    s.DataTipTemplate.DataTipRows(1).Label = selectedItemX;
    s.DataTipTemplate.DataTipRows(2).Label = selectedItemY;    
    fn = fieldnames(handles.DrawData);
    for   datatipindex=1:length(fieldnames(handles.DrawData))  
        s.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow(string(fn(datatipindex)),handles.DrawData.(fn{datatipindex}));
    end
    legend(legend_group);        
    hold off
    
    
    % Pie chart ===============================================================
    case 3   

    pie(x);
    
    hold off

    % Spider/Radar Chart for selected elements==================================
    case 4

    setpixelposition(handles.axes2, [615 225 320 270])

    spider_params = handles.jCBListAxes2.getCheckedValues;

    cell_param = {};
    for i=1:size(spider_params)
    cell_param(:,i) = cellstr(spider_params.get(i-1))
    end
    
    data = handles.UIDataTable.Data;
    cell_rows = size(data)

    for i=1:cell_rows(1);
    selectedItems(i,1) = cell2mat(data(i,1))
    end

    selectedItems = logical(selectedItems);
    k = find(selectedItems);
    
    if (handles.RB_Axes2_OriginalData.Value == 1)   
        for j=1:length(k)         
        SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
        end
    else    
        for j=1:length(k)
        SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
        end
    end
    if (handles.RB_Axes2_FilteredData.Value == 1) 
        for j=1:length(k)
        SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
        end
    else
        for j=1:length(k)         
        SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
        end
    end
    headers = SortedTable.Properties.VariableNames;

    for i=1:length(headers)
    handles.DrawData.(headers{i}) = table2array(SortedTable(:,i));
    end

    for i=1:length(headers)
        if (iscell(SortedTable.(headers{i})(1)))
        handles.DrawData.(headers{i}) = categorical(handles.DrawData.(headers{i})); %make cells - categorical
        end
    end
    handles.DrawData.(headers{1}) = categorical(handles.DrawData.(headers{1})); % Make year - categorical

    for i=1:height(SortedTable)   
        for j=1:length(cell_param)
        Element(i,j) = handles.DrawData.(char(cell_param(j)))(i)   
        end
    end  
    el_num = size(Element)
    % creating Names for selecting elements in spider chart
    for i=1:el_num(1)
        ElementNames(1,i) = string({(k(i))+". "+SortedTable.Author(i)}); % Disply indexes an Autors
    end
    % Drawing Spider chart
    ElementNames  = cellstr(ElementNames);% Transforming to correct type for legend
    ElementNames  = char(ElementNames);
    AxesLabels = cell_param; % Axes properties ��� ���������
    AxesInterval = 5;
    FillOption = 'on';
    FillTransparency = 0.3;
    spider_plot_R2019b(Element,...
      'AxesLabels', AxesLabels,...
      'AxesInterval', AxesInterval,...
      'FillOption', FillOption,...
      'FillTransparency', FillTransparency);
     legend({ElementNames});
     
     hold off 
case 5
    
        selected_group = categories(handles.DrawData.(selectedItemG)); %selected group for Gscatter
            
        for i=1:length(selected_group)
                
            x=handles.DrawData.(selectedItemX)(handles.DrawData.(selectedItemG) == selected_group(i));
            y=handles.DrawData.(selectedItemY)(handles.DrawData.(selectedItemG) == selected_group(i));                     
            scatter(x,y,35,'d');            
            hold on
             
        end    
            
        datacursormode on; 
        dcm_obj = datacursormode(gcf);
        set(dcm_obj,'DisplayStyle','window',...
            'SnapToDataVertex','off','Enable','on')                         
        sz = 180;
        x=handles.DrawData.(selectedItemX);
        y=handles.DrawData.(selectedItemY);
        s = scatter(x,y,sz,'o','w') 
        xlabel(selectedItemX);
        ylabel(selectedItemY); 
        s.DataTipTemplate.DataTipRows(1).Label = selectedItemX;
        s.DataTipTemplate.DataTipRows(2).Label = selectedItemY;    
        
        fn = fieldnames(handles.DrawData);
        for   datatipindex=1:length(fieldnames(handles.DrawData))  
            s.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow(string(fn(datatipindex)),handles.DrawData.(fn{datatipindex}));
        end 
        legend({char(selected_group)})
        hold off
          
    case 6

        selected_group = categories(handles.DrawData.(selectedItemG));    
        for i=1:length(selected_group)      
            x=handles.DrawData.(selectedItemX)(handles.DrawData.(selectedItemG) == selected_group(i));
            y=handles.DrawData.(selectedItemY)(handles.DrawData.(selectedItemG) == selected_group(i));
            z=handles.DrawData.(selectedItemZ)(handles.DrawData.(selectedItemG) == selected_group(i));
            scatter3(x,y,z,'o');            
            hold on
        end          
        
        datacursormode on; 
        dcm_obj = datacursormode(gcf);
        set(dcm_obj,'DisplayStyle','window',...
        'SnapToDataVertex','off','Enable','on')                   
        sz = 180;
        x=handles.DrawData.(selectedItemX);
        y=handles.DrawData.(selectedItemY);
        z=handles.DrawData.(selectedItemZ);
        s = scatter3(x,y,z,sz,'o','w') 
        
        xlabel(selectedItemX);
        ylabel(selectedItemY);
        zlabel(selectedItemZ); 
        
        s.DataTipTemplate.DataTipRows(1).Label = selectedItemX;
        s.DataTipTemplate.DataTipRows(2).Label = selectedItemY;
        s.DataTipTemplate.DataTipRows(3).Label = selectedItemZ;   
        
        fn = fieldnames(handles.DrawData);
        for datatipindex=1:length(fieldnames(handles.DrawData))  
            s.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow(string(fn(datatipindex)),handles.DrawData.(fn{datatipindex}));
        end   
        legend({char(selected_group)})   
        hold off

    case 7 % Stem
        
        datacursormode on; 
        dcm_obj = datacursormode(gcf);
        set(dcm_obj,'DisplayStyle','Window',...
            'SnapToDataVertex','off','Enable','on')
        sz = 35;     
        s = stem(x,y,':k')
        xlabel(selectedItemX);
        ylabel(selectedItemY);                    
        s.DataTipTemplate.DataTipRows(1).Label = selectedItemX;
        s.DataTipTemplate.DataTipRows(2).Label = selectedItemY;  
        fn = fieldnames(handles.OriginalStructure);
        for  datatipindex=1:length(fieldnames(handles.DrawData))  
            s.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow(string(fn(datatipindex)),handles.DrawData.(fn{datatipindex}));
        end
        hold off
    case 8 %GStem
    
        selected_group = categories(handles.DrawData.(selectedItemG));  
            
        for i=1:length(selected_group)      
            x=handles.DrawData.(selectedItemX)(handles.DrawData.(selectedItemG) == selected_group(i));
            y=handles.DrawData.(selectedItemY)(handles.DrawData.(selectedItemG) == selected_group(i)); 
            stem(x,y,...
            '--o',...     
            'MarkerSize',5,...
            'LineWidth',0.75)
            hold on
        end
        
        datacursormode on; 
        dcm_obj = datacursormode(gcf);
        set(dcm_obj,'DisplayStyle','window',...
             'SnapToDataVertex','off','Enable','on')   
        sz = 180;
        hold on
        x=handles.DrawData.(selectedItemX);
        y=handles.DrawData.(selectedItemY);
        s = scatter(x,y,sz,'o','w') 
        xlabel(selectedItemX);
        ylabel(selectedItemY); 
             
        s.DataTipTemplate.DataTipRows(1).Label = selectedItemX;
        s.DataTipTemplate.DataTipRows(2).Label = selectedItemY;    
        
        fn = fieldnames(handles.DrawData);
        for datatipindex=1:length(fieldnames(handles.DrawData))    
            s.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow(string(fn(datatipindex)),handles.DrawData.(fn{datatipindex}));       
        end
        legend({char(selected_group)})
        hold off
                         
    case 9
    
        selected_group = categories(handles.DrawData.(selectedItemG));    
        for i=1:length(selected_group)      
            x=handles.DrawData.(selectedItemX)(handles.DrawData.(selectedItemG) == selected_group(i));
            y=handles.DrawData.(selectedItemY)(handles.DrawData.(selectedItemG) == selected_group(i));
            z=handles.DrawData.(selectedItemZ)(handles.DrawData.(selectedItemG) == selected_group(i));
            stem3(x,y,z,'o');            
            hold on
        end          
        datacursormode on; 
        dcm_obj = datacursormode(gcf);
        set(dcm_obj,'DisplayStyle','window',...
            'SnapToDataVertex','off','Enable','on')   
                               
        sz = 180;
        x=handles.DrawData.(selectedItemX);
        y=handles.DrawData.(selectedItemY);
        z=handles.DrawData.(selectedItemZ);
        s = scatter3(x,y,z,sz,'o','w') 
        xlabel(selectedItemX);
        ylabel(selectedItemY);
        zlabel(selectedItemZ); 
        
        s.DataTipTemplate.DataTipRows(1).Label = selectedItemX;
        s.DataTipTemplate.DataTipRows(2).Label = selectedItemY;
        s.DataTipTemplate.DataTipRows(3).Label = selectedItemZ;   
        
        fn = fieldnames(handles.DrawData);
        for   datatipindex=1:length(fieldnames(handles.DrawData))  
            s.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow(string(fn(datatipindex)),handles.DrawData.(fn{datatipindex}));
        end   
        legend({char(selected_group)})   
        hold off 

    case 10
        
        data = handles.UIDataTable.Data; % get list of data from disp UItable
        cell_rows = size(data)              % number of rows of UItable
        for i=1:cell_rows(1);           % checking 1 row for selected items
            selectedItems(i,1) = cell2mat(data(i,1))
        end
        
        selectedItems = logical(selectedItems); % ==>> transform to logical array
        k = find(selectedItems);                %===find selected items index      
        
        if (handles.RB_Axes1_OriginalData.Value == 1)   
            for j=1:length(k)         
                SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
            end
        else    
            for j=1:length(k)
                SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
            end
        end
        if (handles.RB_Axes1_FilteredData.Value == 1) 
            for j=1:length(k)
            SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
            end
        else
            for j=1:length(k)         
            SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
            end
        end
                           
        for i=1:height(SortedTable) %length selected elements
            BarParameters(i) = handles.DrawData.(selectedItemX)(i)
        end
        bar(BarParameters,0.5)
        ylabel(selectedItemX);       
        hold off

    case 11    
        data = handles.UIDataTable.Data; % get list of data from disp UItable
        cell_rows = size(data)              % number of rows of UItable
        
        for i=1:cell_rows(1);           % checking 1 row for selected items
            selectedItems(i,1) = cell2mat(data(i,1))
        end
        
        selectedItems = logical(selectedItems); % ==>> transform to logical array
        k = find(selectedItems);                %===find selected items index    
            
        if (handles.RB_Axes1_OriginalData.Value == 1)   
            for j=1:length(k)         
                SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
            end
        else    
            for j=1:length(k)
                SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
            end
        end
        if (handles.RB_Axes1_FilteredData.Value == 1) 
            for j=1:length(k)
                SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
            end
        else
            for j=1:length(k)         
                SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
            end
        end
                           
        for i=1:height(SortedTable) %length selected elements
            BarParameters(i) = handles.DrawData.(selectedItemX)(i)
        end
        barh(BarParameters,0.5)
        xlabel(selectedItemX);    
        hold off

case 12
        
bar_params = handles.jCBListAxes2.getCheckedValues; % get list of selected params
cell_param = {}; % clear list
for i=1:size(bar_params)
    cell_param(:,i) = cellstr(bar_params.get(i-1)) % ---> to string array
end 
data = handles.UIDataTable.Data; % get list of data from disp UItable
cell_rows = size(data)              % number of rows of UItable
for i=1:cell_rows(1);           % checking 1 row for selected items
    selectedItems(i,1) = cell2mat(data(i,1))
end
selectedItems = logical(selectedItems); % ==>> transform to logical array
k = find(selectedItems);                %===find selected items index      

if (handles.RB_Axes1_OriginalData.Value == 1)   
    for j=1:length(k)         
        SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
else    
    for j=1:length(k)
        SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
end
if (handles.RB_Axes1_FilteredData.Value == 1) 
    for j=1:length(k)
        SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
else
    for j=1:length(k)         
        SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
    end
end 
headers = SortedTable.Properties.VariableNames; %get VariableNames of sorted table
    
for i=1:length(headers)
    handles.DrawData.(headers{i}) = table2array(SortedTable(:,i));
end
    % creating structure from selected table elements
for i=1:length(headers)
    if (iscell(SortedTable.(headers{i})(1)))
        handles.DrawData.(headers{i}) = categorical(handles.DrawData.(headers{i})); %make cells - categorical
    end
end
handles.DrawData.(headers{1}) = categorical(handles.DrawData.(headers{1})); % Make year - categorical
% Creating  Matrix of elements for Spider Chart Element (i - number of elements, j)       
for i=1:height(SortedTable)   %height(SortedTable) % Selected elements   
    for j=1:length(cell_param)
        Element(i,j) = handles.DrawData.(char(cell_param(j)))(i)   
    end
end
bar(Element,'grouped')
legend({char(cell_param)})
hold off 

case 13
        
    bar_params = handles.jCBListAxes2.getCheckedValues; % get list of selected params
    
    cell_param = {}; % clear list
    for i=1:size(bar_params)
        cell_param(:,i) = cellstr(bar_params.get(i-1)) % ---> to string array
    end 
    
    data = handles.UIDataTable.Data; % get list of data from disp UItable
    cell_rows = size(data)              % number of rows of UItable
    
    for i=1:cell_rows(1);           % checking 1 row for selected items
        selectedItems(i,1) = cell2mat(data(i,1))
    end
    
    selectedItems = logical(selectedItems); % ==>> transform to logical array
    k = find(selectedItems);                %===find selected items index    
        
     
    if (handles.RB_Axes1_OriginalData.Value == 1)   
        for j=1:length(k)         
            SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
        end
    else    
        for j=1:length(k)
            SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
        end
    end
    if (handles.RB_Axes1_FilteredData.Value == 1) 
        for j=1:length(k)
            SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
        end
    else
        for j=1:length(k)         
            SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
        end
    end
    headers = SortedTable.Properties.VariableNames; %get VariableNames of sorted table
        
    for i=1:length(headers)
        handles.DrawData.(headers{i}) = table2array(SortedTable(:,i));
    end 
    % creating structure from selected table elements
    for i=1:length(headers)
        if (iscell(SortedTable.(headers{i})(1)))
            handles.DrawData.(headers{i}) = categorical(handles.DrawData.(headers{i})); %make cells - categorical
        end
    end
    handles.DrawData.(headers{1}) = categorical(handles.DrawData.(headers{1})); % Make year - categorical 
        % Creating  Matrix of elements for Spider Chart Element (i - number of elements, j)       
    for i=1:height(SortedTable)   %height(SortedTable) % Selected elements   
        for j=1:length(cell_param)
            Element(i,j) = handles.DrawData.(char(cell_param(j)))(i)   
        end
    end
    barh(Element,'grouped')
    legend({char(cell_param)})
    hold off 
case 14
          
    paral_params = handles.jCBListAxes2.getCheckedValues; % get list of selected params
    
    cell_param = {}; % clear list
    for i=1:size(paral_params)
        cell_param(:,i) = cellstr(paral_params.get(i-1)) % ---> to string array
    end 
    
    data = handles.UIDataTable.Data; % get list of data from disp UItable
    cell_rows = size(data)              % number of rows of UItable
    for i=1:cell_rows(1);           % checking 1 row for selected items
        selectedItems(i,1) = cell2mat(data(i,1))
    end
    
    selectedItems = logical(selectedItems); % ==>> transform to logical array
    k = find(selectedItems);                %===find selected items index    
    
    if (handles.RB_Axes1_OriginalData.Value == 1)   
        for j=1:length(k)         
            SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
        end
    else    
        for j=1:length(k)
            SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
        end
    end
    if (handles.RB_Axes1_FilteredData.Value == 1) 
        for j=1:length(k)
            SortedTable(j,:) = handles.FilteredDataTable(k(j),:)    % creating new Table from selected elements in UITable
        end
    else
        for j=1:length(k)         
            SortedTable(j,:) = handles.OriginalDataTable(k(j),:)    % creating new Table from selected elements in UITable
        end
    end              
    for j=1:length(cell_param)              
        for i=1:height(SortedTable)           
            ParalelStruct.(cell_param{j})(i) = handles.DrawData.(cell_param{j})(i)         
        end
        ParalelStruct.(cell_param{j}) = transpose(ParalelStruct.(cell_param{j}))          
    end
    ParallelTable = struct2table(ParalelStruct);
    figure;
    p = parallelplot(ParallelTable);
    p.GroupVariable = selectedItemG;
    p.LineStyle = {'-'}
    p.LineWidth = [1.5]    

end

%===============================================================================================================
% --- Executes on selection change in PopUpMenuFilter1.
function PopUpMenuFilter1_Callback(hObject, eventdata, handles)

idItem = get(handles.PopUpMenuFilter1,'Value');
item = get(handles.PopUpMenuFilter1,'String');
selectedItem = item{idItem};
listCatParam = categories(handles.OriginalStructure.(selectedItem));

handles.jListFilter1 = java.util.ArrayList;  % any java.util.List will be ok

for  i=1:length(listCatParam)
     handles.jListFilter1.add(i-1, char(listCatParam(i)));
end

handles.jCBListFilter1 = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.jListFilter1);
handles.jScrollPane1Filter1 = com.mathworks.mwswing.MJScrollPane(handles.jCBListFilter1);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Filter1,[1050,445,211,85],gcf);

handles.output = hObject;
guidata(hObject, handles);
%===============================================================================================================

%===============================================================================================================
% --- Executes on selection change in PopUpMenuFilter2.
function PopUpMenuFilter2_Callback(hObject, eventdata, handles)

idItem = get(handles.PopUpMenuFilter2,'Value');
item = get(handles.PopUpMenuFilter2,'String');
selectedItem = item{idItem};
listCatParam = categories(handles.OriginalStructure.(selectedItem));

handles.jListFilter2 = java.util.ArrayList;  % any java.util.List will be ok
 for  i=1:length(listCatParam)
     handles.jListFilter2.add(i-1, char(listCatParam(i)));
end

handles.jCBListFilter2 = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.jListFilter2);
handles.jScrollPane1Filter2 = com.mathworks.mwswing.MJScrollPane(handles.jCBListFilter2);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Filter2,[1050,336,211,85],gcf);

handles.output = hObject;
guidata(hObject, handles);
%===============================================================================================================

%===============================================================================================================
% --- Executes on selection change in PopUpMenuFilter3.
function PopUpMenuFilter3_Callback(hObject, eventdata, handles)

idItem = get(handles.PopUpMenuFilter3,'Value');
item = get(handles.PopUpMenuFilter3,'String');
selectedItem = item{idItem};
listCatParam = categories(handles.OriginalStructure.(selectedItem));

handles.jListFilter3 = java.util.ArrayList;  % any java.util.List will be ok
 for  i=1:length(listCatParam)
     handles.jListFilter3.add(i-1, char(listCatParam(i)));
end

handles.jCBListFilter3 = com.mathworks.mwswing.checkboxlist.CheckBoxList(handles.jListFilter3);
handles.jScrollPane1Filter3 = com.mathworks.mwswing.MJScrollPane(handles.jCBListFilter3);
[jhScroll,hContainer] = javacomponent(handles.jScrollPane1Filter3,[1050,227,211,85],gcf);

handles.output = hObject;
guidata(hObject, handles);
%===============================================================================================================

%===============================================================================================================
% --- Executes on button press in FilterDataButton.
function FilterDataButton_Callback(hObject, eventdata, handles)
%clear filtered structure
handles.FilteredDataTable(:,:) = [];
FilterIndexArray = []; 
%===============================================================================================
CatFilter_1 = handles.jCBListFilter1.getCheckedValues; % Get selected Params for 1st cat filter
if size(CatFilter_1)== 0        %If - null select all
    handles.ModelFilter1 = handles.jCBListFilter1.getCheckModel;
    handles.ModelFilter1.checkAll;
    CatFilter_1 = handles.jCBListFilter1.getCheckedValues;
end

Cell_CatFilter_1 = {}; %Cell Cat Filter 1 - for substitute in fileds of structure
for i=1:size(CatFilter_1)
    Cell_CatFilter_1(:,i) = cellstr(CatFilter_1.get(i-1))
end
%GetNameField of selected cat param
idItemF1 = get(handles.PopUpMenuFilter1,'Value');
itemF1 = get(handles.PopUpMenuFilter1,'String');
selectedItemF1 = itemF1{idItemF1};
for i=1:length(Cell_CatFilter_1) % Creating structur with indexes
        StructIndex_F1{i}.index = find(handles.OriginalStructure.(selectedItemF1) == Cell_CatFilter_1(i));      
end
%Creating Index Massive for 1 Cat Filter
k = 1;
for i=1:size(CatFilter_1)  
     for j=1:length(StructIndex_F1{1,i}.index)          
         IndexMassiveCat_1(k) = StructIndex_F1{1,i}.index(j);
         k=k+1;
   end     
end   
%==========================================================================================
%========================Second filter=====================================================
CatFilter_2 = handles.jCBListFilter2.getCheckedValues;
if size(CatFilter_2)== 0
    handles.ModelFilter2 = handles.jCBListFilter2.getCheckModel;
    handles.ModelFilter2.checkAll;
    CatFilter_2 = handles.jCBListFilter2.getCheckedValues;
end

Cell_CatFilter_2 = {}; 
for i=1:size(CatFilter_2)
    Cell_CatFilter_2(:,i) = cellstr(CatFilter_2.get(i-1))
end
%GetNameField of selected cat param
idItemF2 = get(handles.PopUpMenuFilter2,'Value');
itemF2 = get(handles.PopUpMenuFilter2,'String');
selectedItemF2 = itemF2{idItemF2};
for i=1:length(Cell_CatFilter_2) 
        StructIndex_F2{i}.index = find(handles.OriginalStructure.(selectedItemF2) == Cell_CatFilter_2(i));      
end
k=1;
for i=1:size(CatFilter_2)
     for j=1:length(StructIndex_F2{1,i}.index)         
         IndexMassiveCat_2(k) = StructIndex_F2{1,i}.index(j);
         k=k+1;
   end     
end
%====================================================================================
%======================Third Cat Filter==============================================
CatFilter_3 = handles.jCBListFilter3.getCheckedValues;
if size(CatFilter_3)== 0
    handles.ModelFilter3 = handles.jCBListFilter3.getCheckModel;
    handles.ModelFilter3.checkAll;
    CatFilter_3 = handles.jCBListFilter3.getCheckedValues;
end

Cell_CatFilter_3 = {}; 
for i=1:size(CatFilter_3)
    Cell_CatFilter_3(:,i) = cellstr(CatFilter_3.get(i-1))
end
%GetNameField of selected cat param
idItemF3 = get(handles.PopUpMenuFilter3,'Value');
itemF3 = get(handles.PopUpMenuFilter3,'String');
selectedItemF3 = itemF3{idItemF3};
for i=1:length(Cell_CatFilter_3) 
        StructIndex_F3{i}.index = find(handles.OriginalStructure.(selectedItemF3) == Cell_CatFilter_3(i));      
end
k=1;
for i=1:size(CatFilter_3) 
     for j=1:length(StructIndex_F3{1,i}.index)       
         IndexMassiveCat_3(k) = StructIndex_F3{1,i}.index(j);
         k=k+1;
   end
end
%====================================================================================
%=================Nuber Filters -First===============================================
minValueF1 = str2double(get(handles.F1MinVal, 'String'));
if isnan(minValueF1)==1
   minValueF1 = -1000000
end
maxValueF1 = str2double(get(handles.F1MaxVal, 'String'));
if isnan(maxValueF1)==1
   maxValueF1 = 1000000
end
idNumF1 = get(handles.PopUpNumFilter1,'Value');
itemNumF1 = get(handles.PopUpNumFilter1,'String');
selectedNumF1 = itemNumF1{idNumF1};

IndexMassiveNum_1 = find(...
                  handles.OriginalDataTable.(selectedNumF1)>=minValueF1...
                & handles.OriginalDataTable.(selectedNumF1)<=maxValueF1) ;
%=========================Second Number=============================================
minValueF2 = str2double(get(handles.F2MinVal, 'String'));
if isnan(minValueF2)==1
   minValueF2 = -1000000
end
maxValueF2 = str2double(get(handles.F2MaxVal, 'String'));
if isnan(maxValueF2) == 1
   maxValueF2 = 1000000
end
idNumF2 = get(handles.PopUpNumFilter2,'Value');
itemNumF2 = get(handles.PopUpNumFilter2,'String');
selectedNumF2 = itemNumF2{idNumF2};

IndexMassiveNum_2 = find(...
                  handles.OriginalDataTable.(selectedNumF2)>=minValueF2...
                & handles.OriginalDataTable.(selectedNumF2)<=maxValueF2) ;
%=========================Third Number=============================================
minValueF3 = str2double(get(handles.F3MinVal, 'String'));
if isnan(minValueF3)==1
   minValueF3 = -1000000
end
maxValueF3 = str2double(get(handles.F3MaxVal, 'String'));
if isnan(maxValueF3)==1
   maxValueF3 = 1000000
end
idNumF3 = get(handles.PopUpNumFilter3,'Value');
itemNumF3 = get(handles.PopUpNumFilter3,'String');
selectedNumF3 = itemNumF3{idNumF3};

IndexMassiveNum_3 = find(...
                  handles.OriginalDataTable.(selectedNumF3)>=minValueF3...
                & handles.OriginalDataTable.(selectedNumF3)<=maxValueF3) ;
%========================================================================
% IndexMassiveCat_1
% IndexMassiveCat_2
% IndexMassiveCat_3
% 
% IndexMassiveNum_1
% IndexMassiveNum_2
% IndexMassiveNum_3
%===========
%=======Mintersect - New function from file_ex = Create 1 array of double indexes
FilterIndexArray = mintersect(IndexMassiveCat_1,IndexMassiveCat_2,IndexMassiveCat_3,IndexMassiveNum_1,IndexMassiveNum_2,IndexMassiveNum_3);
%==========================================================================
%========================Creating FilteredDataTable========================


for j=1:length(FilterIndexArray)         
    handles.FilteredDataTable(j,:) = handles.OriginalDataTable(FilterIndexArray(j),:);
end
%S======Creating Filtered Structure=======================================

headers = handles.OriginalDataTable.Properties.VariableNames; 
for i=1:length(headers)
    handles.FilteredStructure.(headers{i}) = table2array(handles.FilteredDataTable(:,i));
end

for i=1:length(headers)

    if (iscell(handles.FilteredDataTable.(headers{i})(1)))

        handles.FilteredStructure.(headers{i}) = categorical(handles.FilteredStructure.(headers{i})); %make cells - categorical

    end
end
handles.FilteredStructure.(headers{1}) = categorical(handles.FilteredStructure.(headers{1})); % Make year - categorical
% handles.FilteredStructure and handles.FilteredDataTable are in handles
%==========================================================================================
set(handles.UIDataTable, 'Data', {}); % clear uitable;
%=========================Display Filtered Data Table in UIDataTable=======================

selector = table2cell(array2table(true(height(handles.FilteredDataTable),1)));

uitable_headers = ['X' headers]; 

table_cell = table2cell(handles.FilteredDataTable);
data_table = [selector table_cell];

handles.UIDataTable.Data = data_table;
handles.UIDataTable.ColumnName = uitable_headers;
handles.UIDataTable.SelectionHighlight = 'on';

mtable = handles.UIDataTable;
jscrollpane = findjobj(mtable); 
jtable = jscrollpane.getViewport.getView;
jtable.setSortable(true);	
jtable.setColumnAutoResizable(true);

guidata(hObject, handles);
handles.output = hObject;







% --- Executes on button press in ExportDataButton.
function ExportDataButton_Callback(hObject, eventdata, handles)
headers = handles.OriginalDataTable.Properties.VariableNames;
[filename, pathname] = uiputfile('*.xls', 'Choose a file name');
Data = handles.UIDataTable.Data;
ExportTable = cell2table(Data);
ExportTable.Properties.VariableNames = ['X' headers];
ExportTable = removevars(ExportTable,'X')
outname = fullfile(pathname, filename);
writetable(ExportTable, outname);



% --- Executes on button press in SelectAllCheckBox.
function SelectAllCheckBox_Callback(hObject, eventdata, handles)

if handles.SelectAllCheckBox.Value == true
      handles.UIDataTable.Data(:,1) = {true};     
else
      handles.UIDataTable.Data(:,1) = {false};
end
% Hint: get(hObject,'Value') returns toggle state of SelectAllCheckBox

% --- Executes on button press in ExpandTable.
function ExpandTable_Callback(hObject, eventdata, handles)

if handles.ExpandTable.Value == 1
    setpixelposition(handles.UIDataTable, [0 193 1291 490])
    uistack(handles.UIDataTable, 'top');
else
    setpixelposition(handles.UIDataTable, [0 573 1291 111]) 
end
% Hint: get(hObject,'Value') returns toggle state of ExpandTable

% --- Outputs from this function are returned to the command line.
function varargout = RFDataAnalys_OutputFcn(hObject, eventdata, handles) 
  
    varargout{1} = handles.output;
    % --- Executes on button press in GridAxes2CheckBox.
function GridAxes2CheckBox_Callback(hObject, eventdata, handles)

    axes(handles.axes2);
    if handles.GridAxes2CheckBox.Value == true
    grid on;
    grid minor;
    end
    if handles.GridAxes2CheckBox.Value == false
    grid off
    end
    % Hint: get(hObject,'Value') returns toggle state of GridAxes2CheckBox

function ChartTypesAxes_1_CreateFcn(hObject, eventdata, handles)
 
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end   
    % --- Executes on button press in GridAxes1CheckBox.
function GridAxes1CheckBox_Callback(hObject, eventdata, handles)
    axes(handles.axes1);
    if handles.GridAxes1CheckBox.Value == true
    grid on
    grid minor
    end
    if handles.GridAxes1CheckBox.Value == false
    grid off
    end

    % --- Executes on selection change in XDataPopUpAxes_1.
function XDataPopUpAxes_1_Callback(hObject, eventdata, handles)
    % --- Executes during object creation, after setting all properties.
    function XDataPopUpAxes_1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    % --- Executes on selection change in YDataPopUpAxes_1.
    function YDataPopUpAxes_1_Callback(hObject, eventdata, handles)
    % --- Executes during object creation, after setting all properties.
    function YDataPopUpAxes_1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    % --- Executes on selection change in ZDataPopUpAxes_1.
    function ZDataPopUpAxes_1_Callback(hObject, eventdata, handles)
    % --- Executes during object creation, after setting all properties.
    function ZDataPopUpAxes_1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    % --- Executes on selection change in PopUpGroupAxes_1.
    function PopUpGroupAxes_1_Callback(hObject, eventdata, handles)
    % --- Executes during object creation, after setting all properties.
    function PopUpGroupAxes_1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    % --- Executes on button press in LogX_Axes1.
    function LogX_Axes1_Callback(hObject, eventdata, handles)
    axes(handles.axes1);
    if handles.LogX_Axes1.Value == true
    set(gca, 'XScale', 'log');
    else
    set(gca, 'XScale', 'linear');
    end
    % --- Executes on button press in LogY_Axes1.
    function LogY_Axes1_Callback(hObject, eventdata, handles)
    axes(handles.axes1);
    if handles.LogY_Axes1.Value == true
    set(gca, 'YScale', 'log');
    else
    set(gca, 'YScale', 'linear');
    end
    % --- Executes on button press in LogZ_Axes1.
    function LogZ_Axes1_Callback(hObject, eventdata, handles)
    axes(handles.axes1);
    if handles.LogZ_Axes1.Value == true
    set(gca, 'ZScale', 'log');
    else
    set(gca, 'ZScale', 'linear');
    end
    % --- Executes on button press in InvX_Axes1.
    function InvX_Axes1_Callback(hObject, eventdata, handles)
    axes(handles.axes1);
    if handles.InvX_Axes1.Value == true
    set(gca, 'XDir','reverse');
    else
    set(gca, 'XDir','normal')
    end
    % --- Executes on button press in InvY_Axes1.
    function InvY_Axes1_Callback(hObject, eventdata, handles)
    axes(handles.axes1);
    if handles.InvY_Axes1.Value == true
    set(gca, 'YDir','reverse');
    else
    set(gca, 'YDir','normal')
    end
    % --- Executes on button press in InvZ_Axes1.
    function InvZ_Axes1_Callback(hObject, eventdata, handles)
    axes(handles.axes1);
    if handles.InvZ_Axes1.Value == true
    set(gca, 'ZDir','reverse');
    else
    set(gca, 'ZDir','normal')
    end
    

% --- Executes during object creation, after setting all properties.
function ChartTypesAxes_2_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    % --- Executes on selection change in XDataPopUpAxes_2.
    function XDataPopUpAxes_2_Callback(hObject, eventdata, handles)
    
    
    % --- Executes during object creation, after setting all properties.
    function XDataPopUpAxes_2_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    % --- Executes on selection change in YDataPopUpAxes_2.
    function YDataPopUpAxes_2_Callback(hObject, eventdata, handles)
    
    
    % --- Executes during object creation, after setting all properties.
    function YDataPopUpAxes_2_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    % --- Executes on selection change in ZDataPopUpAxes_2.
    function ZDataPopUpAxes_2_Callback(hObject, eventdata, handles)
    
    
    % --- Executes during object creation, after setting all properties.
    function ZDataPopUpAxes_2_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    % --- Executes on selection change in PopUpGroupAxes_2.
    function PopUpGroupAxes_2_Callback(hObject, eventdata, handles)
    
    
    % --- Executes during object creation, after setting all properties.
    function PopUpGroupAxes_2_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
% --- Executes during object creation, after setting all properties.
function PopUpMenuFilter3_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    % --- Executes on selection change in PopUpNumFilter1.
    function PopUpNumFilter1_Callback(hObject, eventdata, handles)
    
    
    % --- Executes during object creation, after setting all properties.
    function PopUpNumFilter1_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
    function F1MinVal_Callback(hObject, eventdata, handles)
    
    
    % --- Executes during object creation, after setting all properties.
    function F1MinVal_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
    function F1MaxVal_Callback(hObject, eventdata, handles)
    
    % --- Executes during object creation, after setting all properties.
    function F1MaxVal_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    % --- Executes on selection change in PopUpNumFilter2.
    function PopUpNumFilter2_Callback(hObject, eventdata, handles)
    
    
    
    % --- Executes during object creation, after setting all properties.
    function PopUpNumFilter2_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
    function F2MinVal_Callback(hObject, eventdata, handles)
    
    
    
    % --- Executes during object creation, after setting all properties.
    function F2MinVal_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    function F2MaxVal_Callback(hObject, eventdata, handles)
    
    % --- Executes during object creation, after setting all properties.
    function F2MaxVal_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
   
    % --- Executes on selection change in PopUpNumFilter3.
    function PopUpNumFilter3_Callback(hObject, eventdata, handles)
    
    % --- Executes during object creation, after setting all properties.
    function PopUpNumFilter3_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
      
    function F3MinVal_Callback(hObject, eventdata, handles)
     
    % --- Executes during object creation, after setting all properties.
    function F3MinVal_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    function F3MaxVal_Callback(hObject, eventdata, handles)
    % --- Executes during object creation, after setting all properties.
    function F3MaxVal_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
% --- Executes during object creation, after setting all properties.
function PopUpMenuFilter1_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % --- Executes during object creation, after setting all properties.
function PopUpMenuFilter2_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    


% --- Executes on button press in NewAxisWindow.
function NewAxisWindow_Callback(hObject, eventdata, handles)
% hObject    handle to NewAxisWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NewAxisWindow
