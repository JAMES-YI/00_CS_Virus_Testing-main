function varargout = pool_test_gui(varargin)
% POOL_TEST_GUI MATLAB code for pool_test_gui.fig
%      POOL_TEST_GUI, by itself, creates a new POOL_TEST_GUI or raises the existing
%      singleton*.
%
%      H = POOL_TEST_GUI returns the handle to a new POOL_TEST_GUI or the handle to
%      the existing singleton*.
% 
%      POOL_TEST_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POOL_TEST_GUI.M with the given input arguments.
%
%      POOL_TEST_GUI('Property','Value',...) creates a new POOL_TEST_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pool_test_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pool_test_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pool_test_gui

% Last Modified by GUIDE v2.5 29-Aug-2020 19:41:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pool_test_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @pool_test_gui_OutputFcn, ...
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


% --- Executes just before pool_test_gui is made visible.
function pool_test_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pool_test_gui (see VARARGIN)

% Choose default command line output for pool_test_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pool_test_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pool_test_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in mix_mat_selec.
function mix_mat_selec_Callback(hObject, eventdata, handles)
% hObject    handle to mix_mat_selec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pool_matrix_gui



% --- Executes on button press in pool_status_ent.
function pool_status_ent_Callback(hObject, eventdata, handles)
% hObject    handle to pool_status_ent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pool_status_gui

% --- Executes on button press in samp_status_dec.
function samp_status_dec_Callback(hObject, eventdata, handles)
% hObject    handle to samp_status_dec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pool_decode_gui

% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf('-----Start of Help Information for Pooling Test System------\n');
fprintf('Step 1. Click Choose Mixing Matrix to choose a mixing matrix, and follow the instructions there.\n');
fprintf('Step 2. Click Enter Status of Pools to enter pooling results, and follow the instructions there.\n');
fprintf('Step 3. Click Decode Sample Status to check the decoding results, and follow the instructions there.\n');
fprintf('Repeat Step 1, 2, and 3 every time you start new one.\n');
fprintf('-----End of Help Information for Pooling Test System------\n');


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
