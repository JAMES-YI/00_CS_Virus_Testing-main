function varargout = pool_status_gui(varargin)
% POOL_STATUS_GUI MATLAB code for pool_status_gui.fig
%      POOL_STATUS_GUI, by itself, creates a new POOL_STATUS_GUI or raises the existing
%      singleton*.
%
%      H = POOL_STATUS_GUI returns the handle to a new POOL_STATUS_GUI or the handle to
%      the existing singleton*.
%
%      POOL_STATUS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POOL_STATUS_GUI.M with the given input arguments.
%
%      POOL_STATUS_GUI('Property','Value',...) creates a new POOL_STATUS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pool_status_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pool_status_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pool_status_gui

% Last Modified by GUIDE v2.5 30-Aug-2020 11:37:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pool_status_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @pool_status_gui_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before pool_status_gui is made visible.
function pool_status_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pool_status_gui (see VARARGIN)

% Choose default command line output for pool_status_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

poolMatrix = getappdata(0,'poolMatrix');
[nPools,~] = size(poolMatrix);
tabNum = 3;
poolNumTab = round(nPools/tabNum);

colName = {'Pool Index','Status (0/1)','Ct Value'};
colEditable = [false true true];
fig = gcf;

tab1Data = [(1:poolNumTab)',Inf*ones(poolNumTab,2)];
tab2Data = [(poolNumTab+1:2*poolNumTab)',Inf*ones(poolNumTab,2)];
tab3Data = [(2*poolNumTab+1:nPools)',Inf*ones(nPools-2*poolNumTab,2)];

tab1 = uitable('Parent', fig, 'Units', 'normal', 'Position', [0.01 0.1 0.32 .8],...
    'Data', tab1Data,...
    'ColumnName',colName,'ColumnEditable',colEditable,...
    'FontSize',12);
tab2 = uitable('Parent', fig, 'Units', 'normal', 'Position', [1/3 0.1 0.32 .8],... 
    'Data', tab2Data,...
    'ColumnName',colName,'ColumnEditable',colEditable,...
    'FontSize',12);
tab3 = uitable('Parent', fig, 'Units', 'normal', 'Position', [2/3 0.1 0.32 .8],...
    'Data', tab3Data,...
    'ColumnName',colName,'ColumnEditable',colEditable,...
    'FontSize',12);

handles.tab{1} = tab1;
handles.tab{2} = tab2;
handles.tab{3} = tab3;
guidata(hObject,handles);


% table1 = uitable('Parent', fig, 'Units', 'normal', 'Position', [0.01 0.1 0.32 .8],...
%     'Data', [(1:poolNumTab)',Inf*ones(poolNumTab,2)],...
%     'ColumnName',colName,'ColumnEditable',colEditable,...
%     'FontSize',12);
% table2 = uitable('Parent', fig, 'Units', 'normal', 'Position', [1/3 0.1 0.32 .8],... 
%     'Data', [(poolNumTab+1:2*poolNumTab)',Inf*ones(poolNumTab,2)],...
%     'ColumnName',colName,'ColumnEditable',colEditable,...
%     'FontSize',12);
% table3 = uitable('Parent', fig, 'Units', 'normal', 'Position', [2/3 0.1 0.32 .8],...
%     'Data', [(2*poolNumTab+1:nPools)',Inf*ones(nPools-2*poolNumTab,2)],...
%     'ColumnName',colName,'ColumnEditable',colEditable,...
%     'FontSize',12);
% table4 = uitable('Parent', fig, 'Units', 'normal', 'Position', [3/4 0.1 0.25 .8],...
%     'Data', Inf*ones(10,3),...
%     'ColumnName',colName);
% [left,bottom,width,height]

% UIWAIT makes pool_status_gui wait for user response (see UIRESUME)
% uiwait(handles.pooling_status_fig);


% --- Outputs from this function are returned to the command line.
function varargout = pool_status_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'tab')
    
    tab = handles.tab;
    poolData = [];
    
    for i=1:3
        tabData = get(tab{i},'Data');
        poolData = [poolData;tabData];
    end
    
    setappdata(0,'poolData',poolData);
    
end

closereq();


% --- Executes when user attempts to close pooling_status_fig.
% function figure1_CloseRequestFcn(hObject, eventdata, handles)
% % hObject    handle to pooling_status_fig (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: delete(hObject) closes the figure
% delete(hObject);


% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf('-------Start of Help Information for Pooling Status-------\n');
fprintf('Step 1: enter the quanlitative status of each pool, and use 1 for positive while 0 for negative.\n');
fprintf('Step 2: enter the quantitative value of each pool.\n');
fprintf('Step 3: click Finshed Entering.\n');
fprintf('-------End of Help Information for Pooling Status-------\n');


% --- Executes when user attempts to close pooling_status_fig.
function pooling_status_fig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to pooling_status_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
