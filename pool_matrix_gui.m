function varargout = pool_matrix_gui(varargin)
% POOL_MATRIX_GUI MATLAB code for pool_matrix_gui.fig
%      POOL_MATRIX_GUI, by itself, creates a new POOL_MATRIX_GUI or raises the existing
%      singleton*.
%
%      H = POOL_MATRIX_GUI returns the handle to a new POOL_MATRIX_GUI or the handle to
%      the existing singleton*.
%
%      POOL_MATRIX_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POOL_MATRIX_GUI.M with the given input arguments.
%
%      POOL_MATRIX_GUI('Property','Value',...) creates a new POOL_MATRIX_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pool_matrix_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pool_matrix_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pool_matrix_gui

% Last Modified by GUIDE v2.5 29-Aug-2020 23:17:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pool_matrix_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @pool_matrix_gui_OutputFcn, ...
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


% --- Executes just before pool_matrix_gui is made visible.
function pool_matrix_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pool_matrix_gui (see VARARGIN)

% Choose default command line output for pool_matrix_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

Mat = poolMatrixGen(5,10);
cellMat = num2cell(Mat);

[nPool,nSamp] = size(Mat); 

for i=1:nPool
    rowName{i} = sprintf('Pool %d',i);
end

for i=1:nSamp
    colName{i} = sprintf('Sample %d',i);
end

set(handles.mat_in_tab,...
    'Data',cellMat,...
    'ColumnName',colName,'RowName',rowName);



% UIWAIT makes pool_matrix_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pool_matrix_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in matrix_manu.
function matrix_manu_Callback(hObject, eventdata, handles)
% hObject    handle to matrix_manu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns matrix_manu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from matrix_manu

matrix_manu = get(handles.matrix_manu,'String');
switch matrix_manu{get(handles.matrix_manu,'Value')}
    
    case '5 by 10'
        
        poolMatrix = poolMatrixGen(5,10);
        
    case '6 by 15'
        
        poolMatrix = poolMatrixGen(6,15);
        
    case '7 by 21'
        
        poolMatrix = poolMatrixGen(7,21);
        
    case '8 by 28'
        
        poolMatrix = poolMatrixGen(8,28);
        
    case '9 by 36'
        
        poolMatrix = poolMatrixGen(9,36);
        
    case '10 by 45'
        
        poolMatrix = poolMatrixGen(10,45);
        
    case '11 by 55'
        
        poolMatrix = poolMatrixGen(11,55);
        
    case '12 by 66'
        
        poolMatrix = poolMatrixGen(12,66);
        
    case '13 by 78'
        
        poolMatrix = poolMatrixGen(13,78);
        
    case '14 by 91'
        
        poolMatrix = poolMatrixGen(14,91);
        
    case '15 by 105'
        
        poolMatrix = poolMatrixGen(15,105);
        
    case '16 by 120'
        
        poolMatrix = poolMatrixGen(16,120);
        
    case '17 by 136'
        
        poolMatrix = poolMatrixGen(17,136);
        
    case '18 by 153'
        
        poolMatrix = poolMatrixGen(18,153);
        
    case '19 by 171'
        
        poolMatrix = poolMatrixGen(19,171);
        
    case '20 by 190'
        
        poolMatrix = poolMatrixGen(20,190);
        
    case '21 by 210'
        
        poolMatrix = poolMatrixGen(21,210);
        
    case '22 by 231'
        
        poolMatrix = poolMatrixGen(22,231);
        
    case '23 by 253'
        
        poolMatrix = poolMatrixGen(23,253);
        
    case '24 by 276'
        
        poolMatrix = poolMatrixGen(24,276);
        
    case '25 by 300'
        
        poolMatrix = poolMatrixGen(25,300);
        
    case '26 by 325'
        
        poolMatrix = poolMatrixGen(26,325);
        
    case '27 by 351'
        
        poolMatrix = poolMatrixGen(27,351);
        
    case '28 by 378'
        
        poolMatrix = poolMatrixGen(28,378);
        
    case '29 by 406'
        
        poolMatrix = poolMatrixGen(29,406);
        
    case '30 by 435'
        
        poolMatrix = poolMatrixGen(30,435);
    
end

% display(poolMatrix)

set(handles.matrix_manu,'UserData',poolMatrix);
setappdata(0,'poolMatrix',poolMatrix);


% --- Executes during object creation, after setting all properties.
function matrix_manu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to matrix_manu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in mat_gen.
function mat_gen_Callback(hObject, eventdata, handles)
% hObject    handle to mat_gen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mat_selectObj = findobj('Tag','matrix_manu');
Mat = mat_selectObj.UserData; 

cellMat = num2cell(Mat);
[nPool,nSamp] = size(Mat); 

for i=1:nPool
    rowName{i} = sprintf('Pool %d',i);
end

for i=1:nSamp
    colName{i} = sprintf('Sample %d',i);
end

set(handles.mat_in_tab,...
    'Data',cellMat,...
    'ColumnName',colName,'RowName',rowName);

% display(Mat)



% --- Executes when entered data in editable cell(s) in mat_in_tab.
function mat_in_tab_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to mat_in_tab (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% f = figure; 
% d = randn(10,3);
% t = uitable(f);
% set(t,'Data',d);
% set(t,'ColumnName',{'a';'b';'c'})


% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Help information for pooling matrix design')
fprintf('Step 1: select pooling matrix size from the popup menu.\n');
fprintf('Step 2: click Generate Pooling Matrix\n');
fprintf('Step 3: close the graphic user interface after pooling.\n');
