function varargout = infect_model_config(varargin)
% INFECT_MODEL_CONFIG MATLAB code for infect_model_config.fig
%      INFECT_MODEL_CONFIG, by itself, creates a new INFECT_MODEL_CONFIG or raises the existing
%      singleton*.
%
%      H = INFECT_MODEL_CONFIG returns the handle to a new INFECT_MODEL_CONFIG or the handle to
%      the existing singleton*.
%
%      INFECT_MODEL_CONFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INFECT_MODEL_CONFIG.M with the given input arguments.
%
%      INFECT_MODEL_CONFIG('Property','Value',...) creates a new INFECT_MODEL_CONFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before infect_model_config_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to infect_model_config_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help infect_model_config

% Last Modified by GUIDE v2.5 02-Aug-2020 23:24:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @infect_model_config_OpeningFcn, ...
                   'gui_OutputFcn',  @infect_model_config_OutputFcn, ...
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


% --- Executes just before infect_model_config is made visible.
function infect_model_config_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to infect_model_config (see VARARGIN)

% Choose default command line output for infect_model_config
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes infect_model_config wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = infect_model_config_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on selection change in InfMod.
function InfMod_Callback(hObject, eventdata, handles)
% hObject    handle to InfMod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns InfMod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InfMod


% --- Executes during object creation, after setting all properties.
function InfMod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfMod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sparsity_Callback(hObject, eventdata, handles)
% hObject    handle to sparsity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sparsity as text
%        str2double(get(hObject,'String')) returns contents of sparsity as a double


% --- Executes during object creation, after setting all properties.
function sparsity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sparsity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function N_Callback(hObject, eventdata, handles)
% hObject    handle to N (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of N as text
%        str2double(get(hObject,'String')) returns contents of N as a double


% --- Executes during object creation, after setting all properties.
function N_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lb_Callback(hObject, eventdata, handles)
% hObject    handle to lb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lb as text
%        str2double(get(hObject,'String')) returns contents of lb as a double


% --- Executes during object creation, after setting all properties.
function lb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ub_Callback(hObject, eventdata, handles)
% hObject    handle to ub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ub as text
%        str2double(get(hObject,'String')) returns contents of ub as a double


% --- Executes during object creation, after setting all properties.
function ub_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

reset(RandStream.getGlobalStream,sum(100*clock));

%%
Prob = str2double(get(handles.sparsity,'string'));
N = str2double(get(handles.N,'string'));

InfMod = get(handles.InfMod,'String');
InfModVal = InfMod{get(handles.InfMod,'Value')};

%%
if ~exist('./Synthetic_data', 'dir')
   mkdir('Synthetic_data')
end

switch InfModVal
    
    case 'By Prevalence'
        
        % Validity of user input
        if Prob>1 || Prob<0
            Msg = 'Error occurred! When choosing <by prevalence>, select a value between 0 and 1.';
            error(Msg);
        end

        Samp_VStatus = binornd(1,Prob,N,1);
        InfSet = find(Samp_VStatus==1);
        [k,~] = size(InfSet);
        Samp_DataName = sprintf('Synthetic_data/Test_samples_N%d_prvc%d_%s.mat',...
            N,round(Prob*100),datestr(now,'yyyymmddHHMM'));
        
    case 'By Case Number'
        
        % Validity of user input
        if Prob<1 || mod(Prob,1)~=0 || Prob>N
            Msg = 'Error occurred! When choosing <by case number>, select a positive integer value no greater than N.';
            error(Msg);
        end
        
        k = Prob;
        InfSet = randsample(N,k);
        Samp_VStatus = zeros(N,1);
        Samp_VStatus(InfSet) = 1;
        Samp_DataName = sprintf('Synthetic_data/Test_samples_N%d_k%d_%s.mat',...
            N,k,datestr(now,'yyyymmddHHMM'));
        
end

ub = str2double(get(handles.ub,'string'));
lb = str2double(get(handles.lb,'string'));

Params.InfModVal = InfModVal;
Params.N = N;
Params.Prob = Prob;
Params.k = k;
Params.lb = lb;
Params.ub = ub;
Params.InfSet = InfSet;
Params.Samp_VStatus = Samp_VStatus;
Params.Samp_DataName = Samp_DataName;

main(Params);


%% Generate testing samples

% InfSet = randsample(N,k);
% Samp_VQuant = zeros(N,1); 
% Samp_VQuant(InfSet,1) = (ub-lb)*rand(k,1) + lb;
% Samp_VStatus = zeros(N,1);
% Samp_VStatus(InfSet,1) = 1;
% 
% fprintf('Virus load in test samples:\n'); Samp_VQuant
% fprintf('Infection status in test samples: \n'); Samp_VStatus
% fprintf('Test samples with infection:\n'); InfSet


% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('By Prevelance: each test sample has a particular probability for being infected.\n');
fprintf('By Case Number: number of cases for being infected.\n');
%fprintf('By Percentage: a particular fraction of the total test samples are infected.\n');
fprintf('Infection Prevelance (prvc) or Percentage (pctg): a value between 0 and 1.\n');
fprintf('Population Size (N): total number test samples.\n');
fprintf('Virus Load Lower Bound (lb): smallest virus load when a person is infected.\n');
fprintf('Virus Load Upper Bound (ub): largest virus load when a person is infected.\n');

fprintf('\nDefault Infection Model Configuration:\n');
fprintf('Infection mode: By Prevelance\n')
% fprintf('Infection Prevelance (prvc) or Percentage (pctg): 0.01\n');
fprintf('Infection Prevelance (prvc) or Case Number (k): 0.01\n');
fprintf('Population Size (N): 1000\n');
fprintf('Virus Load Lower Bound (lb): 0.\n');
fprintf('Virus Load Upper Bound (ub): 100000\n')
