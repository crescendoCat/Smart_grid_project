function varargout = untitled1(varargin)
% UNTITLED1 MATLAB code for untitled1.fig
%      UNTITLED1, by itself, creates a new UNTITLED1 or raises the existing
%      singleton*.
%
%      H = UNTITLED1 returns the handle to a new UNTITLED1 or the handle to
%      the existing singleton*.
%
%      UNTITLED1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED1.M with the given input arguments.
%
%      UNTITLED1('Property','Value',...) creates a new UNTITLED1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled1

% Last Modified by GUIDE v2.5 24-Apr-2018 00:53:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled1_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled1_OutputFcn, ...
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


% --- Executes just before untitled1 is made visible.
function untitled1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled1 (see VARARGIN)

% Choose default command line output for untitled1
handles.output = hObject;

% Define the global variables so we can use them in other function.
global plants_name_list;
global plants_data_base;
global plant_num;
global quoted_price;
global buy_price;
global buy_num;
global fig_data_cell;
global x_log;
global start_time;
global total_power_dem;
global buy_quantity;

%<<Function>>Reading and Preprocessing data

plants_name_list = {
    '台南仁德懷恩_0419.csv'
    '台南六甲顏阿甚_0419.csv'
    '台南安東庭園_0419.csv'
    '台南善化胡聰明_0419.csv'
    '台南鹽水許明和_0419.csv'
    '高雄內門蔡宗憲_0419.csv'
    '雲林台西林玉婷_0419.csv'
    '雲林四湖玉米_0419.csv'
    '嘉義布袋蔡政翰_0419.csv'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
    '嘉義朴子黃任逢_0419.csv'
    '南投國姓林月敏一場_0419.csv'
    }; 

plants_data_base = [];

plant_num = size(plants_name_list, 1);



for i=1:plant_num
    M = sum(csvread(plants_name_list{i}, 1, 2), 2);
    R = zeros(24, 1);
    for t=0:23
        s = t*3+1;
        e = t*3+3;
        R(t+1) = sum(M(s:e, 1)) / 3;
    end
    plants_data_base = [plants_data_base R];
end


buy_num = 3;

% We don't have the file of the data of total power demended, so we just key
% in manully.
total_power = [
    823.2 760.69 690.2 701.28 660.49 683.57 718.55 1013.8 1073.45 1227.85 1329.51 1391.72 1340.42 1438.32 1458.11 1441 1496.1 1346.59 1273.67 1269 1202.78 976.03 910.04 864.97;
    784.76 740.91 665.35 668.18 650.07 659.22 698.63 1017.31 1028.3 1173.13 1291.9 1306.69 1268.16 1336.94 1448.96 1398.8 1383.29 1240.6 1186.43 1138.72 1157.57 980.01 879.06 864.51;
    755.4 713.52 696.51 693.64 659.07 673.95 682.91 754.5 943.29 1087.2 1225.82 1224.93 1364.63 1385.19 1369.04 1310.43 1287.35 1119.48 877.63 874.64 896.9 939.98 922.39 896.3
];
% Total power demended is too large, our plants can not handle it, so we add
% some parameter to limit the quantity.
total_power_dem = total_power' / 25 * 0.5;

% Draw the graph of total power generated.
axesHandle = findobj('Tag', 'axes_total_gen');
X = (1:24);
h = plot(axesHandle, X, plants_data_base(:, :));
xlabel(axesHandle, '小時');
ylabel(axesHandle, 'kW');

% Draw the graph of total power demended.
axesHandle = findobj('Tag', 'axes_total_dem');
X = (1:24);
plot(axesHandle, X, total_power_dem);
xlabel(axesHandle, '小時');
ylabel(axesHandle, 'kW/h');



% Generate the random buy prices and quoted prices.
% This process can be change in later development.
quoted_price = rand(24, plant_num) * 8.8 + 1.2;
buy_price = rand(24, buy_num) * 8.8 + 2.4;
axesHandle = findobj('Tag', 'axes_quoted_price');
X = (1:plant_num);
h1 = bar(axesHandle, X, quoted_price(1, :));
xlabel(axesHandle, '案場');
ylabel(axesHandle, '每度/元');

% Draw the graphes.
axesHandle = findobj('Tag', 'axes_buy_price');
X = (1:buy_num);
h2 = bar(axesHandle, X, buy_price(1, :));
xlabel(axesHandle, '用戶');
ylabel(axesHandle, '每度/元');

% Define the variables to record the value of the output of 
% Optimiaztion processes in each round(for each hour).
fval_log = [];
x_log = [];


% Parameter detail please check the Matlab manul of linprog
A = eye(plant_num+buy_num);
Aeq = [ones(1 ,buy_num) -1*ones(1, plant_num)];
beq = 0;
fig_data_cell= {};
start_time = 6;
end_time = 18;
buy_quantity = zeros(24, buy_num);
sell_quantity = zeros(24, plant_num);
for compute_time = start_time:end_time
    
    f = [-1 * buy_price(compute_time, :) quoted_price(compute_time, :)];
    b = [total_power_dem(compute_time, :) plants_data_base(compute_time, :)];
%{
    disp(f);
    disp(A);
    disp(b);
    disp(Aeq);
    disp(beq);
%}
    [x, fval, exitflag, output] = linprog(f, A, b, Aeq, beq, zeros(1, plant_num + buy_num), 1000 * ones(1, plant_num + buy_num));
    fval_log = [fval_log -fval];
    meanPrice = mean(x(2:plant_num + buy_num ));
    buy_quantity(compute_time, :) = x(1:buy_num);
    sell_quantity(compute_time, :) = x(buy_num+1:buy_num + plant_num);
    x_log = [x_log sum(x(1:buy_num, 1))];
    fig_data_cell(compute_time, 1) = {fig_draw_preprocess(plants_data_base(compute_time, :), quoted_price(compute_time, :))};
    
    %figure();
    %bar(x);
end

% Draw the vertical line.
line_y = (0:0.5:max(fig_data_cell{12, :}(:)));
line_x = x_log(12-start_time) * ones(1, size(line_y, 2));

% Draw the actual demended line.
line_x_actual = sum(total_power_dem(12, :)) * ones(1, size(line_y, 2));

axesHandle = findobj('Tag', 'axes_output');
X = (1:size(fig_data_cell{12, :}(:), 1));
hold(axesHandle, 'on');
h3 = stairs(axesHandle, X, fig_data_cell{12, :}(:), 'b');
h4 = plot(axesHandle, line_x, line_y, 'r');
h5 = plot(axesHandle, line_x_actual, line_y, 'g');
hold(axesHandle, 'off');
xlabel(axesHandle, '度');
ylabel(axesHandle, '每度/元');

global bar_data;

axesHandle = findobj('Tag', 'axes_bought_and_actual');
bar_data = [total_power_dem(12, :)' + eps buy_quantity(12, :)'+eps];
h6 = bar(axesHandle, bar_data);
legend(h6, {'購買度數' '實際需求度數'}, 'Location', 'northoutside');
xlabel(axesHandle, '用戶');
ylabel(axesHandle, '度');

axesHandle = findobj('Tag', 'axes_total_earn');
total_plants_earn = sum(sell_quantity(:, :) .* quoted_price(:, :), 2);
total_user_cost = sum(buy_quantity(:, :) .* buy_price(:, :), 2);
total_earn = total_user_cost - total_plants_earn;
plot(axesHandle, [total_plants_earn total_user_cost total_earn]);
legend(axesHandle, {'案場總收入' '用戶總支出' '平台總收入'});
xlabel(axesHandle, '小時');
ylabel(axesHandle, '元(新台幣)');


textHandle = findobj('Tag', 'text_start_time');
s = sprintf('%02d:00', start_time);
disp(s);
set(textHandle, 'String', s);

textHandle = findobj('Tag', 'text_end_time');
s = sprintf('%02d:00', end_time);
disp(s);
set(textHandle, 'String', s);



% Collect the handles of each graph, so we can change the contents of the
% graphes later.
global handlers;
handlers = containers.Map({'quoted_price' 'buy_price' 'stairs' 'price_line' 'actual_dem_line' 'actual_bought_and_dem'}, {h1, h2, h3, h4, h5, h6});


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global fig_data_cell;
global x_log;
global quoted_price;
global buy_price;
global plant_num;
global buy_num;
global handlers;
global start_time;
global total_power_dem;
global buy_quantity;
t = round(get(handles.slider1, 'Value'));
line_y = (0:0.5:max(fig_data_cell{t, :}(:)));
line_x = x_log(t-start_time+1) * ones(1, size(line_y, 2));
line_x_actual = sum(total_power_dem(t, :)) * ones(1, size(line_y, 2));
X = (1:size(fig_data_cell{t, :}(:), 1));

set(handlers('stairs'), 'xdata', X, 'ydata', fig_data_cell{t, :}(:));
set(handlers('price_line'), 'xdata', line_x, 'ydata', line_y);
set(handlers('actual_dem_line'), 'xdata', line_x_actual, 'ydata', line_y);

global bar_data;

bar_data = [total_power_dem(t, :)' + eps buy_quantity(t, :)'+eps];
b = handlers('actual_bought_and_dem');
set(b(1), 'ydata', bar_data(:, 1));
set(b(2), 'ydata', bar_data(:, 2));

X = (1:plant_num);
set(handlers('quoted_price'), 'xdata', X, 'ydata', quoted_price(t, :));


X = (1:buy_num);
set(handlers('buy_price'), 'xdata', X, 'ydata', buy_price(t, :));


textHandle = findobj('Tag', 'text_now_time');
s = sprintf('%02d:00', t);
set(textHandle, 'String', s);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plants_name_list;
global plant_num;
plants = '';
for i=1:plant_num
    plants = [plants sprintf('%d. %s\n', i, plants_name_list{i})];
end
disp(plants);
content = sprintf([...
    '使用的廠商資料\n'...
    '%s\n'...
    '使用的用戶資料\n'...
    '東海大學 智慧校園電力監測系統\n'...
    '2018-04-18\n'...
    '2018-04-20\n'...
    '2018-04-21\n'...
    ] , plants);
Information('title', '說明', 'string', content)
