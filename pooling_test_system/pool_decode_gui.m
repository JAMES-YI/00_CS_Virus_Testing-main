function varargout = pool_decode_gui(varargin)
% POOL_DECODE_GUI MATLAB code for pool_decode_gui.fig
%      POOL_DECODE_GUI, by itself, creates a new POOL_DECODE_GUI or raises the existing
%      singleton*.
%
%      H = POOL_DECODE_GUI returns the handle to a new POOL_DECODE_GUI or the handle to
%      the existing singleton*.
%
%      POOL_DECODE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POOL_DECODE_GUI.M with the given input arguments.
%
%      POOL_DECODE_GUI('Property','Value',...) creates a new POOL_DECODE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pool_decode_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pool_decode_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pool_decode_gui

% Last Modified by GUIDE v2.5 11-Sep-2020 19:01:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pool_decode_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @pool_decode_gui_OutputFcn, ...
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


% --- Executes just before pool_decode_gui is made visible.
function pool_decode_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pool_decode_gui (see VARARGIN)

% Choose default command line output for pool_decode_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pool_decode_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%% Gather data and configuration setup
% poolMatrix = [1,0,0,1,0,1,1;...
%               0,1,0,1,1,1,0;...
%               0,0,1,0,1,1,1];
% 
% poolData = [1,0,0;
%             2,0,0;
%             3,1,24.29];

poolMatrix = getappdata(0,'poolMatrix');
poolData = getappdata(0,'poolData');

[~,nSamp] = size(poolMatrix); 
trialNum = 1; posNumPrior = 0;

%% Status decoding
for i = 1:trialNum

    [MNeg,MPos,Pos] = pool_dec(poolMatrix,poolData(:,2),posNumPrior);
    sampMPos{i} = MPos;
    sampMNeg{i} = MNeg;
    sampPos{i} = Pos;
    tmpStatus = zeros(nSamp,1);

    if ~isempty(MPos)
        tmpStatus(MPos,:) = ones(length(MPos),1);
    end
    
    if ~isempty(Pos)
        tmpStatus(Pos,:) = 2*ones(length(Pos),1);
    end
    
    sampStatus{i} = tmpStatus;

end


%% Report results

% GUI display
colName = {'Sample index','Status','Value'};

if ~isempty(MNeg)
    MNegNum = length(MNeg);
    MNegMat = [reshape(MNeg,[MNegNum,1]),zeros(MNegNum,1),Inf*ones(MNegNum,1)];
else
    MNegMat = Inf*ones(1,3);
end

if ~isempty(MPos)
    
    MPosNum = length(MPos);
    MPosMat = [reshape(MPos,[MPosNum,1]),ones(MPosNum,1),Inf*ones(MPosNum,1)];
else
    MPosMat = Inf*ones(1,3);
end

if ~isempty(Pos)
    
    PosNum = length(Pos);
    PosMat = [reshape(Pos,[PosNum,1]),2*ones(PosNum,1),Inf*ones(PosNum,1)];
    
else
    
    PosMat = Inf*ones(1,3);
    
end

cellMNegMat = num2cell(MNegMat);
cellMPosMat = num2cell(MPosMat);
cellPosMat = num2cell(PosMat);

set(handles.NegTab,...
    'Data',cellMNegMat,...
    'ColumnName',colName);
set(handles.PosTab,...
    'Data',cellMPosMat,...
    'ColumnName',colName);
set(handles.PotPosTab,...
    'Data',cellPosMat,...
    'ColumnName',colName);

% Write to file
handles.MNegMat = MNegMat;
handles.MPosMat = MPosMat;
handles.PosMat = PosMat;
guidata(hObject,handles);

% MNegTab = uitable('Parent', fig, 'Units', 'normal', 'Position', [0.01 0.1 0.32 .8],...
%     'Data', tab1Data,...
%     'ColumnName',colName,'ColumnEditable',colEditable,...
%     'FontSize',12);
% MPosTab = uitable('Parent', fig, 'Units', 'normal', 'Position', [1/3 0.1 0.32 .8],... 
%     'Data', tab2Data,...
%     'ColumnName',colName,'ColumnEditable',colEditable,...
%     'FontSize',12);
% PosTab = uitable('Parent', fig, 'Units', 'normal', 'Position', [2/3 0.1 0.32 .8],...
%     'Data', tab3Data,...
%     'ColumnName',colName,'ColumnEditable',colEditable,...
%     'FontSize',12);

% --- Outputs from this function are returned to the command line.
function varargout = pool_decode_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in xlsxsave.
function xlsxsave_Callback(hObject, eventdata, handles)
% hObject    handle to xlsxsave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% MNegMat = handles.MNegMat;
% MPosMat = handles.MPosMat;
% PosMat = handles.PosMat;
% poolMatrix = getappdata(0,'poolMatrix');
% % poolData = getappdata(0,'poolData');
% [nPools,nSamples] = size(poolMatrix);
% 
% nPools = 2;nSamples = 2;
% fID = sprintf('Decoding_results_m%d_N%d_%s.xlsx',nPools,nSamples,datestr(now,'yyyymmddHHMM'));
% xlswrite(fID,'HELLO','Sheet1','A1')

% setappdata(0,'poolData',poolData);
    




% --- Executes when entered data in editable cell(s) in NegTab.
function NegTab_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to NegTab (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in PosTab.
function PosTab_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to PosTab (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in PotPosTab.
function PotPosTab_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to PotPosTab (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf('------Start of help information for decoding results report------\n');
fprintf('1. Table Negative contains samples which are decoded to be negative.\n');
fprintf('2. Table Positive contains samples which are decoded to be positive.\n');
fprintf('3. Table Potential Positive contains samples which are decoded to be potentially positive.\n');
fprintf('4. A sample has status 0 if it is negative, and 1 if it is positive.\n');
fprintf('5. Inf means no data available.\n');
fprintf('------End of help information for decoding results report------\n');
