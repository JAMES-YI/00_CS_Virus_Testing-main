function varargout = samp_gen_gui(varargin)
% SAMP_GEN_GUI MATLAB code for samp_gen_gui.fig
%      SAMP_GEN_GUI, by itself, creates a new SAMP_GEN_GUI or raises the existing
%      singleton*.
%
%      H = SAMP_GEN_GUI returns the handle to a new SAMP_GEN_GUI or the handle to
%      the existing singleton*.
%
%      SAMP_GEN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAMP_GEN_GUI.M with the given input arguments.
%
%      SAMP_GEN_GUI('Property','Value',...) creates a new SAMP_GEN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before samp_gen_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to samp_gen_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help samp_gen_gui

% Last Modified by GUIDE v2.5 02-Aug-2020 15:42:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @samp_gen_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @samp_gen_gui_OutputFcn, ...
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


% --- Executes just before samp_gen_gui is made visible.
function samp_gen_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to samp_gen_gui (see VARARGIN)

handles.peaks = peaks(35); 
handles.membrane = membrane;
[x,y] = meshgrid(-8:0.5:8);
r = sqrt(x.^2+y.^2) + eps;
sinc = sin(r)./r;
handles.sinc = sinc; 

% Set the current data value
handles.current_data = handles.peaks;
surf(handles.current_data);


% Choose default command line output for samp_gen_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes samp_gen_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = samp_gen_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% JYI

surf(handles.current_data);

%%

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% JYI
contour(handles.current_data);

%%

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% JYI
mesh(handles.current_data);

%%

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% JYI

% Determine the selected data set
str = get(hObject,'String');
val = get(hObject,'Value');

% Set current data to the selected data set
switch str{val}
    case 'peaks'
        handles.current_data = handles.peaks;
    case 'membrane'
        handles.current_data = handles.membrane;
    case 'sinc'
        handles.current_data = handles.sinc;
end

% Save the handles structure
guidata(hObject,handles);


%%
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
