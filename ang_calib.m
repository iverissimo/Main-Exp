function varargout = ang_calib(varargin)
% ANG_CALIB MATLAB code for ang_calib.fig
%      ANG_CALIB, by itself, creates a new ANG_CALIB or raises the existing
%      singleton*.
%
%      H = ANG_CALIB returns the handle to a new ANG_CALIB or the handle to
%      the existing singleton*.
%
%      ANG_CALIB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANG_CALIB.M with the given input arguments.
%
%      ANG_CALIB('Property','Value',...) creates a new ANG_CALIB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ang_calib_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ang_calib_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ang_calib

% Last Modified by GUIDE v2.5 22-May-2017 17:58:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ang_calib_OpeningFcn, ...
    'gui_OutputFcn',  @ang_calib_OutputFcn, ...
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


% --- Executes just before ang_calib is made visible.
function ang_calib_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ang_calib (see VARARGIN)

% Choose default command line output for ang_calib
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ang_calib wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ang_calib_OutputFcn(hObject, eventdata, handles)
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
load('ang');
load('srl')
abductor_robot(ang,srl)



function ang_Callback(hObject, eventdata, handles)
% hObject    handle to ang (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ang as text
%        str2double(get(hObject,'String')) returns contents of ang as a double
load('srl')
valstrs = get([handles.ang], 'String');
ang = str2double(valstrs);
if (0 <= ang) && (ang <= 140)
    ang = 180 - ang;
else
    warning('Angle not in acceptable range.')
    ang = 180;
end

save('ang.mat','ang');
%disp(ang)



% --- Executes during object creation, after setting all properties.
function ang_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ang (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
