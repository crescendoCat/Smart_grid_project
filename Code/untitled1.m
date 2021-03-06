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

% Last Modified by GUIDE v2.5 31-Jul-2018 03:02:04

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
global plant_num;
global buy_num;
global start_time;
global Result;
global day;
global hour;
global end_time;
global plants_data_base;
global total_power_dem;
start_time = 7;
end_time = 18;
day = 1;
hour = 1;


    warning off;


DATA_PATH = '../Data/Supplier/test/';
[plants_data_base, total_power_dem, plant_num, buy_num, day_num] = dataloader(DATA_PATH);
Result = struct('actual_supply_RL', zeros(day_num, 12, plant_num),...
                'actual_supply_Random', zeros(day_num, 12, plant_num), ...
                'sup_price_RL', zeros(day_num, 12, plant_num), ...
                'usr_price_RL', zeros(day_num, 12, buy_num), ...
                'sup_price_Random', zeros(day_num, 12, plant_num), ...
                'usr_price_Random', zeros(day_num, 12, buy_num), ...
                'sup_ideal_supply', zeros(day_num, 24, plant_num), ...
                'usr_ideal_need', zeros(day_num, 24, buy_num), ...
                'sup_actual_supply_RL', zeros(day_num, 12, plant_num), ...
                'usr_actual_get_RL', zeros(day_num, 12, buy_num), ...
                'sup_actual_supply_Random', zeros(day_num, 12, plant_num), ...
                'usr_actual_get_Random', zeros(day_num, 12, buy_num));
%[Result_hour] = testSingleHour(squeeze(plants_data_base(1, 12, :)), ...
%        squeeze(total_power_dem(1, 12, :)), ...
%        quoted_price_range, buy_price_range, supply_range, ...
%        demand_range, sup_model, usr_model);
%Result = fetchOutcomeToResult(Result, Result_hour, day, hour);
now_display_hour = 5;

[data] = computeDataFromResult(Result, day, now_display_hour);
handles.pushbutton_stop.Enable = 'off';
% Draw the graph of total power generated.
axesHandle = findobj('Tag', 'axes_total_gen');
disp(axesHandle);
X = (1:24);
dh1 = plot(axesHandle, X, data.total_gen_data);
title(axesHandle, 'Supply', 'FontSize', 24);
xlim(axesHandle, [0, 25]);
xticks(axesHandle, linspace(0, 24, 4));
xlabel(axesHandle, 'Hour', 'FontSize', 20);
ylabel(axesHandle, 'kW', 'FontSize', 20);

% Draw the graph of total power demended.
axesHandle = findobj('Tag', 'axes_total_dem');
X = (1:24);

dh2 = plot(axesHandle, X, data.total_dem_data);
title(axesHandle, 'Demand', 'FontSize', 24)
xlim(axesHandle, [0, 25]);
xticks(axesHandle, linspace(0, 24, 4));
xlabel(axesHandle, 'Hour', 'FontSize', 20);
ylabel(axesHandle, 'kW', 'FontSize', 20);

%axesHandle = findobj('Tag', 'axes16');
%[data] = computeDataFromResult(Result, 1:12);
%h3 = plot(axesHandle, )
pos_width = 0.680;
pos_height = 0.1200;
axesHandle = findobj('Tag', 'axes10');
subplot(axesHandle);
ax1 = subplot( 4, 1, 1);
pos = get(ax1, 'Position');
pos(3:4) = [0.845 pos_height];
pos(1) = pos(1)-0.025;
set(ax1, 'Position', pos);
ax1.FontSize = 15;
h1 = bar(ax1, data.sup_pricing, 'FaceColor','flat');
ylim(ax1, [0, 10]);
%legend(axesHandle, 'boxoff');
xticks(ax1, linspace(1, 19, 10));
xlabel(ax1, 'Suppliers', 'FontSize', 18);
ylabel(ax1, 'NTD/kWh', 'FontSize', 18);
title(ax1, 'Pricing', 'FontSize', 20);
legend(ax1, {'RL', 'Random'}, 'Location', 'eastoutside', 'FontSize', 15);
legend(ax1, 'boxoff');
%labelBar(h1(1), data.sup_pricing(:, 1), -0.35);
%labelBar(h1(2), data.sup_pricing(:, 2));

ax2 = subplot(4, 1, 2);
pos = get(ax2, 'Position');
pos(2:4) = [pos(2) - 0.015 pos_width pos_height];
pos(1) = pos(1)-0.025;
set(ax2, 'Position', pos);
h2 = bar(ax2, data.plants_earn_growth_rate, 'FaceColor','flat');
ylim(ax2, [-150, 150]);
xticks(ax2, linspace(1, 19, 10));
%legend(axesHandle, 'boxoff');
xlabel(ax2, 'Suppliers', 'FontSize', 18);
ylabel(ax2, 'Percentage', 'FontSize', 18);
title(ax2, 'Income Growth', 'FontSize', 20);
t2 = labelBar(h2, data.plants_earn_growth_rate);



ax3 = subplot( 4, 1, 3);
pos = get(ax3, 'Position');
pos = [pos(1)-0.025 pos(2)-0.035 0.845 pos_height];
set(ax3, 'Position', pos);
h3 = bar(ax3, data.usr_pricing, 'FaceColor','flat');
%legend(axesHandle, 'boxoff');
ylim(ax3, [0, 10]);
xticks(ax3, linspace(1, 3, 3));
xlabel(ax3, 'Power Users', 'FontSize', 18);
ylabel(ax3, 'NTD/kWh', 'FontSize', 18);
title(ax3, 'Pricing', 'FontSize', 20);
legend(ax3, {'RL', 'Random'}, 'Location', 'eastoutside', 'FontSize', 15);
legend(ax3, 'boxoff');


ax4 = subplot(4, 1, 4);
pos = get(ax4, 'Position');
pos = [pos(1)-0.025 pos(2)-0.05 pos_width pos_height];
set(ax4, 'Position', pos);
h4 = bar(ax4, data.users_cost_growth_rate, 'FaceColor','flat');
ylim(ax4, [-150, 150]);
%legend(axesHandle, 'boxoff');
xlabel(ax4, 'Power users', 'FontSize', 18);
ylabel(ax4, 'Percentage', 'FontSize', 18);
title(ax4, 'Saving Rate', 'FontSize', 20);
t4 = labelBar(h4, data.users_cost_growth_rate);

global handlers;
handlers = containers.Map({'sup_price' 'earn_rate' 'usr_price' 'cost_rate' 'total_gen' 'total_dem'...
    'earn_t' 'cost_t'}, ... 
    {h1, h2, h3, h4, dh1, dh2, ...
    t2, t4});
%update_graph_data(handles);

% Update handles structure
guidata(hObject, handles);

function out = postProcessBarData(list)
    list(isinf(list)) = 1;
    list(list > 15) = 1;
    list(isnan(list)) = 0;
    out = list;

function data = computeDataFromResult(Result, day, now_display_hour)
    global end_time;
    global start_time;
    global plant_num;
    
    start_data_idx = (day-1)*(end_time-start_time+1) + 1;

    plants_sup_growth_rate = (squeeze(Result.sup_actual_supply_RL(day, now_display_hour, :)) - ...
        squeeze(Result.sup_actual_supply_Random(day, now_display_hour, :))) ./ ...
        (squeeze(Result.sup_actual_supply_Random(day, now_display_hour, :) + eps));
    plants_sup_growth_rate = postProcessBarData(plants_sup_growth_rate);
    plants_sup_growth_rate = plants_sup_growth_rate' * 100;
    
    total_sup_gRate = sum(squeeze(Result.sup_actual_supply_RL(day, now_display_hour, :)) - ...
        squeeze(Result.sup_actual_supply_Random(day, now_display_hour, :))) / ...
        sum(squeeze(Result.sup_actual_supply_Random(day, now_display_hour, :))) * 100;

    act_sup_Rand = squeeze(Result.sup_actual_supply_Random(day, now_display_hour, :));
    if(size(act_sup_Rand, 2) ~= plant_num)
        act_sup_Rand = act_sup_Rand';
    end
    total_plants_earn_Rand = act_sup_Rand .* ...
        squeeze(Result.sup_price_Random(day, now_display_hour, :))';

    act_sup_RL = squeeze(Result.sup_actual_supply_RL(day, now_display_hour, :));
    if(size(act_sup_RL, 2) ~= plant_num)
        act_sup_RL = act_sup_RL';
    end
    total_plants_earn_RL =act_sup_RL .* ...
        squeeze(Result.sup_price_RL(day, now_display_hour, :))';

    plants_earn_growth_rate = (total_plants_earn_RL - total_plants_earn_Rand) ./ (total_plants_earn_Rand + eps);
    plants_earn_growth_rate = postProcessBarData(plants_earn_growth_rate);
    plants_earn_growth_rate = plants_earn_growth_rate * 100;
    total_earn_gRate = sum(total_plants_earn_RL - total_plants_earn_Rand) / sum(total_plants_earn_Rand) * 100;
    
    users_need_growth_rate = (squeeze(Result.usr_actual_get_RL(day, now_display_hour, :)) - ...
        squeeze(Result.usr_actual_get_Random(day, now_display_hour, :))) ./ ...
        (squeeze(Result.usr_actual_get_Random(day, now_display_hour, :)));
    users_need_growth_rate = postProcessBarData(users_need_growth_rate);
    users_need_growth_rate = users_need_growth_rate' * 100;

    total_need_gRate = sum(squeeze(Result.usr_actual_get_RL(day, now_display_hour, :)) - ...
        squeeze(Result.usr_actual_get_Random(day, now_display_hour, :))) / ...
        sum(squeeze(Result.usr_actual_get_Random(day, now_display_hour, :))) * 100;
    global buy_num
    usr_cst_Rand = squeeze(Result.usr_actual_get_Random(day, now_display_hour, :));
    if(size(usr_cst_Rand, 2) ~= buy_num)
        usr_cst_Rand = usr_cst_Rand';
    end
    
    total_user_cost_Rand = usr_cst_Rand .* ...
        squeeze(Result.usr_price_Random(day, now_display_hour, :))';
    
    usr_cst_RL = squeeze(Result.usr_actual_get_RL(day, now_display_hour, :));
    if(size(usr_cst_RL, 2) ~= buy_num)
        usr_cst_RL = usr_cst_RL';
    end
    
    total_user_cost_RL = usr_cst_RL .* ...
        squeeze(Result.usr_price_RL(day, now_display_hour, :))';

    users_cost_growth_rate = (total_user_cost_RL - total_user_cost_Rand) ./ (total_user_cost_Rand);
    %total_user_cost_RL - total_user_cost_Rand
    %total_user_cost_Rand
    users_cost_growth_rate = postProcessBarData(users_cost_growth_rate);
    users_cost_growth_rate = users_cost_growth_rate*-100;
    total_cost_gRate = sum(total_user_cost_RL - total_user_cost_Rand) / sum(total_user_cost_Rand) * -100;
    %===============================================day avg%
    diff = (end_time-start_time+1);
    day_sup_growth_rate = sum((squeeze(Result.sup_actual_supply_RL(day, 1:diff, :)) - ...
        squeeze(Result.sup_actual_supply_Random(day, 1:diff, :))), 2) ./ ...
        sum(squeeze(Result.sup_actual_supply_Random(day, 1:diff, :)), 2);
    day_sup_growth_rate = postProcessBarData(day_sup_growth_rate);
    day_sup_growth_rate = day_sup_growth_rate' * 100;
    
    day_total_sup_gRate = sum(sum(squeeze(Result.sup_actual_supply_RL(day, 1:diff, :)) - ...
        squeeze(Result.sup_actual_supply_Random(day, 1:diff, :)))) / ...
        sum(sum(squeeze(Result.sup_actual_supply_Random(day, 1:diff, :)))) * 100;

    act_sup_Rand = squeeze(Result.sup_actual_supply_Random(day, 1:diff, :));
    if(size(act_sup_Rand, 2) ~= plant_num)
        act_sup_Rand = act_sup_Rand';
    end
    day_plants_earn_Rand = act_sup_Rand .* ...
        squeeze(Result.sup_price_Random(day, 1:diff, :));

    act_sup_RL = squeeze(Result.sup_actual_supply_RL(day, 1:diff, :));
    if(size(act_sup_RL, 2) ~= plant_num)
        act_sup_RL = act_sup_RL';
    end
    day_plants_earn_RL =act_sup_RL .* ...
        squeeze(Result.sup_price_RL(day, 1:diff, :));

    day_earn_growth_rate = sum(day_plants_earn_RL - day_plants_earn_Rand, 1) ./ sum(day_plants_earn_Rand + eps, 1);
    day_earn_growth_rate = postProcessBarData(day_earn_growth_rate);
    day_earn_growth_rate = day_earn_growth_rate * 100;
    day_total_earn_gRate = sum(sum(day_plants_earn_RL - day_plants_earn_Rand)) / sum(sum(day_plants_earn_Rand)) * 100;
    
    day_need_growth_rate = sum((squeeze(Result.usr_actual_get_RL(day, 1:diff, :)) - ...
        squeeze(Result.usr_actual_get_Random(day, 1:diff, :))), 2) ./ ...
        sum(squeeze(Result.usr_actual_get_Random(day, 1:diff, :)), 2);
    day_need_growth_rate = postProcessBarData(day_need_growth_rate);
    day_need_growth_rate = day_need_growth_rate' * 100;
    
    day_total_need_gRate = sum(sum(squeeze(Result.usr_actual_get_RL(day, 1:diff, :)) - ...
        squeeze(Result.usr_actual_get_Random(day, 1:diff, :)))) / ...
        sum(sum(squeeze(Result.usr_actual_get_Random(day, 1:diff, :)))) * 100;

    act_need_Rand = squeeze(Result.usr_actual_get_Random(day, 1:diff, :));
    if(size(act_need_Rand, 2) ~= buy_num)
        act_need_Rand = act_need_Rand';
    end
    day_users_cost_Rand = act_need_Rand .* ...
        squeeze(Result.usr_price_Random(day, 1:diff, :));

    act_need_RL = squeeze(Result.usr_actual_get_RL(day, 1:diff, :));
    if(size(act_need_RL, 2) ~= buy_num)
        act_need_RL = act_need_RL';
    end
    day_users_cost_RL =act_need_RL .* ...
        squeeze(Result.usr_price_RL(day, 1:diff, :));

    day_cost_growth_rate = sum(day_users_cost_RL - day_users_cost_Rand, 1) ./ sum(day_users_cost_Rand + eps, 1);
    day_cost_growth_rate = postProcessBarData(day_cost_growth_rate);
    day_cost_growth_rate = day_cost_growth_rate * 100;
    day_total_cost_gRate = sum(sum(day_users_cost_RL - day_users_cost_Rand)) / sum(sum(day_users_cost_Rand)) * 100;
    
    
    %sum(total_user_cost_RL - total_user_cost_Rand)
    %sum(total_user_cost_Rand)

    total_gen_data = squeeze(Result.sup_ideal_supply(day, :, :));
    data = squeeze(Result.usr_ideal_need(day, :, :));
    
    data = struct('plants_sup_growth_rate', plants_sup_growth_rate, ...
        'plants_earn_growth_rate', plants_earn_growth_rate, ...
        'users_need_growth_rate', users_need_growth_rate, ...
        'users_cost_growth_rate', users_cost_growth_rate, ...
        'sup_pricing',  [squeeze(Result.sup_price_RL(day, now_display_hour, :)) ...
                         squeeze(Result.sup_price_Random(day, now_display_hour, :))], ...
        'usr_pricing',  [squeeze(Result.usr_price_RL(day, now_display_hour, :)) ...
                         squeeze(Result.usr_price_Random(day, now_display_hour, :))], ...
        'total_gen_data', total_gen_data, ...
        'total_dem_data', data, ...
        'total_sup', total_sup_gRate, 'total_earn', total_earn_gRate, ...
        'total_need', total_need_gRate, 'total_cost', total_cost_gRate, ...
        'day_sup_growth_rate', day_sup_growth_rate, ...
        'day_earn_growth_rate', day_earn_growth_rate, ...
        'day_need_growth_rate', day_need_growth_rate, ...
        'day_cost_growth_rate', day_cost_growth_rate, ...
        'day_sup', day_total_sup_gRate, 'day_earn', day_total_earn_gRate, ...
        'day_need', day_total_need_gRate, 'day_cost', day_total_cost_gRate);

function tlist = labelBar(h, labels, xPad, yPad)
    if nargin <= 2
        xPad = 0;
    end
    if nargin <= 3
        yPad = 0;
    end
    str = [];
    for i=1:numel(h.YData)
        str = [str string(sprintf('%3.0f', labels(i)))];
    end
    tlist = text(h.XData + xPad, h.YData + yPad, str, 'HorizontalAlignment','center', 'VerticalAlignment','bottom');
    
    
    
function tlist = updateBarLabel(h, tlist, labels, xPad, yPad)
    if nargin <= 3
        xPad = 0;
    end
    if nargin <= 4
        yPad = 0;
    end
        
    for i=1:numel(h.YData)
        % Adjusting the y position of the label
        if h.YData(i) < 0
            y = h.YData(i) - 60;
        else
            y = h.YData(i);
        end
        
        if y >= 90
            y = 90;
        elseif y <= -150
            y = -150;
        end
        tlist(i).Position = [h.XData(i) + xPad, y + yPad];
        tlist(i).String = sprintf('%3.0f', labels(1, i));
    end

    
    
function out = computeCData(list)
    len = max(size(list));
    out = repmat([0 0.4470 0.7410], len, 1);
    out((list < 0), :) = repmat([1 0 0], sum(list < 0), 1);

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
global start_time;
global day;
global hour;
hour = round(get(handles.slider1, 'Value')) - start_time+1;
update_graph_data(handles, day, hour);

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
    '南投國姓林月敏一場\n'...
    '台中龍井農會沙田路\n'...
    '台南仁德懷恩\n'...
    '台南六甲嚴阿甚\n'...
    '台南善化胡聰明\n'...
    '台南安東庭園\n'...
    '台南鹽水許明和\n'...
    '嘉義布袋蔡政翰\n'...
    '嘉義朴子黃任逢\n'...
    '嘉義東石楊清財\n'...
    '彰化彰濱建泰二期\n'...
    '新竹竹東彭玉蓮\n'...
    '雲林台西林玉婷\n'...
    '雲林四湖玉米\n'...
    '雲林斗六嬌旺食品\n'...
    '雲林斗六廖進豐\n'...
    '雲林斗南慈愛\n'...
    '雲林水林吳有明\n'...
    '高雄內門蔡宗憲\n'...
    '\n'...
    '使用的用戶資料\n'...
    '東海大學 智慧校園電力監測系統\n'...
    '2018-04-18\n'...
    '2018-04-20\n'...
    '2018-04-21\n'...
    ] , plants);
Information('title', '說明', 'string', content)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global day;
day = round(get(handles.slider2, 'Value'));
global hour;
update_graph_data(handles, day, hour);

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function update_graph_data(handles, day, now_display_hour)
global plant_num;
global buy_num;
global handlers;
global start_time;
global Result;
global end_time;
disp('update');
disp([day now_display_hour]);
[data] = computeDataFromResult(Result, day, now_display_hour);
b = handlers('sup_price');
set(b(1), 'ydata', data.sup_pricing(:, 1));
set(b(2), 'ydata', data.sup_pricing(:, 2));
set(b(1), 'cdata', 4);
set(b(2), 'cdata', 5);
%updateBarLabel(handlers('sup_rate'), handlers('sup_t'), data.plants_sup_growth_rate);

set(handlers('earn_rate'), 'ydata', data.plants_earn_growth_rate);
updateBarLabel(handlers('earn_rate'), handlers('earn_t'), data.plants_earn_growth_rate);

b = handlers('usr_price');
set(b(1), 'ydata', data.usr_pricing(:, 1));
set(b(2), 'ydata', data.usr_pricing(:, 2));
set(b(1), 'cdata', 4);
set(b(2), 'cdata', 5);
%updateBarLabel(handlers('need_rate'), handlers('need_t'), data.users_need_growth_rate);

set(handlers('cost_rate'), 'ydata', data.users_cost_growth_rate);
updateBarLabel(handlers('cost_rate'), handlers('cost_t'), data.users_cost_growth_rate);

%set(handlers('sup_rate'), 'cdata', computeCData(data.plants_sup_growth_rate));
set(handlers('earn_rate'), 'cdata', computeCData(data.plants_earn_growth_rate));
%set(handlers('need_rate'), 'cdata', computeCData(data.users_need_growth_rate));
set(handlers('cost_rate'), 'cdata', computeCData(data.users_cost_growth_rate));

p = handlers('total_gen');
for i=1:plant_num
    set(p(i), 'ydata', data.total_gen_data(:, i));
end

p = handlers('total_dem');
for i=1:buy_num
    set(p(i), 'ydata', data.total_dem_data(:, i));
end



textHandle = findobj('Tag', 'text_now_time');
s = sprintf('%02d:00', now_display_hour+start_time -1);
set(textHandle, 'String', s);

textHandle = findobj('Tag', 'text_now_day');
s = sprintf('%d', day);
set(textHandle, 'String', s);

textHandle = findobj('Tag', 'text_earn');
s = sprintf('%.2f%%', data.total_earn);
set(textHandle, 'String', s);

textHandle = findobj('Tag', 'text_cost');
s = sprintf('%.2f%%', data.total_cost);
set(textHandle, 'String', s);

textHandle = findobj('Tag', 'text_earn_day');
s = sprintf('%.2f%%', data.day_earn);
set(textHandle, 'String', s);

textHandle = findobj('Tag', 'text_cost_day');
s = sprintf('%.2f%%', data.day_cost);
set(textHandle, 'String', s);

function Result = testSingleHour(supply, demand, quoted_range, buy_range, supply_range, ...
    demand_range, sup_model, usr_model)
quoted_price_ub = quoted_range(2);
quoted_price_lb = quoted_range(1);
quoted_edges = quoted_price_lb:1:quoted_price_ub;

% Discretize the supply state space => demand 
demand_ub = supply_range(2);
demand_lb = supply_range(1);
demand_state_edges = demand_lb:5:demand_ub;
demand_state_num = size(demand_state_edges,2) - 1;

% For User
% Discretize the action space => buy_price
buy_price_ub = buy_range(2);
buy_price_lb = buy_range(1);
buy_edges = buy_price_lb:1:buy_price_ub;

% Discretize the demand state space => supply
supply_ub = demand_range(2);
supply_lb = demand_range(1);
supply_state_edges = supply_lb:5:supply_ub;
supply_state_num = size(supply_state_edges,2) - 1;

% Load in the Q-factor table
load(sup_model, 'sup_Q_factor');
load(usr_model, 'usr_Q_factor');

[a, b] = size(supply);
if a ~= 1
    if b ~= 1
        error('The supply must be a one dimension matrix');
    end
    supply = supply(:)';
    plant_num = a;
else
    plant_num = b;
end
[a, b] = size(demand);
if a ~= 1
    if b ~= 1
        error('The demand must be a one dimension matrix');
    end
    demand = demand(:)';
    buy_num = a;
else
    buy_num = b;
end

% Variables for linear programming
A = eye(plant_num+buy_num);
Aeq = [ones(1 ,buy_num) -1*ones(1, plant_num)];
beq = 0;

% Define a data structure for plotting the result
Result = struct('actual_supply_RL', [], 'actual_supply_Random', [], ...
                'sup_price_RL', [], 'usr_price_RL', [], ...
                'sup_price_Random', [], 'usr_price_Random', [], ...
                'sup_ideal_supply', supply, ...
                'usr_ideal_need', demand, ...
                'sup_actual_supply_RL', zeros(plant_num, 1), ...
                'usr_actual_get_RL', zeros(buy_num, 1), ...
                'sup_actual_supply_Random', zeros(plant_num, 1), ...
                'usr_actual_get_Random', zeros(buy_num, 1));

    for use_RL = 0:1
        if use_RL 
            % Get supplier current state
            sup_cur_state = discretize(supply(:), supply_state_edges);
            total_sup_cur_state = discretize(sum(supply(:)), supply_state_edges);
            total_dem_cur_state = discretize(sum(demand(:)), demand_state_edges);
            sup_cur = total_dem_cur_state * supply_state_num + sup_cur_state;

            quoted_price = zeros(1, plant_num);
            buy_price = zeros(1, buy_num);
            for i = 1:plant_num
                % Get the index of the max Q-value in current state, that is
                % the price to quote
                [~, quoted_price(i)] = max(sup_Q_factor(i, sup_cur(i), :));
                quoted_price(i) = quoted_price(i)+quoted_price_lb-1;
            end
            % Get user current state
            usr_cur_state = discretize(supply(:), demand_state_edges);
            usr_cur = total_sup_cur_state * demand_state_num + usr_cur_state;
            for i = 1:buy_num
                [~, buy_price(i)] = max(usr_Q_factor(i, usr_cur(i), :)); 
                buy_price(i) = buy_price(i)+buy_price_lb-1;
            end

            % Store the price into result
            Result.sup_price_RL = quoted_price;
            Result.usr_price_RL = buy_price;                
        else
            quoted_price = randi([quoted_price_lb quoted_price_ub], 1, plant_num);
            buy_price = randi([buy_price_lb buy_price_ub], 1, buy_num);

            % Store the price into result
            Result.sup_price_Random = quoted_price;
            Result.usr_price_Random = buy_price; 
        end

        f = [-1 * buy_price quoted_price];
        b = [demand supply];

        [x, ~, ~, ~] = linprog(f, A, b, Aeq, beq, ...
            zeros(1, plant_num + buy_num), 1000 * ones(1, plant_num + buy_num), [], ...
            optimset('Display','none'));

        if use_RL
            Result.sup_actual_supply_RL(:) = x(buy_num+1:plant_num+buy_num);
            Result.usr_actual_get_RL(:) = x(1:buy_num);
        else
            Result.sup_actual_supply_Random(:) = x(buy_num+1:plant_num+buy_num);
            Result.usr_actual_get_Random(:) = x(1:buy_num);
        end
    end

function Result = fetchOutcomeToResult(Result, Result_hour, day, hour)
    global start_time;
    Result.sup_actual_supply_RL(day, hour, :) = Result_hour.sup_actual_supply_RL(:);
    Result.sup_actual_supply_Random(day, hour, :) = Result_hour.sup_actual_supply_Random(:);
    Result.sup_price_RL(day, hour, :) = Result_hour.sup_price_RL(:);
    Result.usr_price_RL(day, hour, :) = Result_hour.usr_price_RL(:);
    Result.sup_price_Random(day, hour, :) = Result_hour.sup_price_Random(:);
    Result.usr_price_Random(day, hour, :) = Result_hour.usr_price_Random(:);
    Result.sup_ideal_supply(day, hour+start_time-1, :) = Result_hour.sup_ideal_supply(:);
    Result.usr_ideal_need(day, hour+start_time-1, :) = Result_hour.usr_ideal_need(:);
    Result.usr_actual_get_RL(day, hour, :) = Result_hour.usr_actual_get_RL(:);
    Result.usr_actual_get_Random(day, hour, :) = Result_hour.usr_actual_get_Random(:);


% --- Executes on button press in pushbutton_fetchdata.
function pushbutton_fetchdata_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fetchdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pushbutton_stop.Enable = 'on';
delete(instrfindall);
serialPort = serial('COM6'); %獲得Serial Port(序列阜)
set(serialPort,'BaudRate',9600); %設定Baud Rate
global T;
try 
    
   fopen(serialPort); %打開Serial Port
   T = timer('TimerFcn', {@startDataFetchingProcess, handles, serialPort}, 'ExecutionMode', 'fixedSpacing');
   start(T);
catch ME
 
    id = ME.identifier
 
    fclose(serialPort); %關閉Serial Port
 
end
%{
global plants_data_base;
global total_power_dem;
global day;
global hour;
global start_time;
global end_time;
global Result;
hour = hour+1;
if hour > end_time - start_time+1
    hour = 1;
    day = day+1;
    if day > 10
        day = 1;
        hour = 1;
    end
end
    phase = 'test';
    update_method = 'R-SMART';
    update_method_QL = 'Q-learning';
    SAVE_FLAG = 1;
    SAVE_PATH = '../Result';
    quoted_price_range = [1 8];
    buy_price_range = [3 10];
    supply_range = [0 500];
    demand_range = [0 500];
    sup_model = strcat(strcat('../Model/sup_Q_factor_', update_method), '.mat');
    usr_model = strcat(strcat('../Model/usr_Q_factor_', update_method), '.mat');
    sup_model_QL = strcat(strcat('../Model/sup_Q_factor_', update_method_QL), '.mat');
    usr_model_QL = strcat(strcat('../Model/usr_Q_factor_', update_method_QL), '.mat');

[Result_hour] = testSingleHour(squeeze(plants_data_base(day, hour+start_time-1, :)), ...
        squeeze(total_power_dem(day, hour+start_time-1, :)), ...
        quoted_price_range, buy_price_range, supply_range, ...
        demand_range, sup_model, usr_model);
Result = fetchOutcomeToResult(Result, Result_hour, day, hour);
set(handles.slider2, 'Value', day);
set(handles.slider1, 'Value', hour + start_time - 1);
%}
%update_graph_data(handles);

function startDataFetchingProcess(obj, event, handles, serialPort)
    global start_time;
    global day;
    global hour;
    global end_time;
    global Result;
    update_method = 'R-SMART';
    update_method_QL = 'Q-learning';
    quoted_price_range = [1 8];
    buy_price_range = [3 10];
    supply_range = [0 500];
    demand_range = [0 500];
    sup_model = strcat(strcat('../Model/sup_Q_factor_', update_method), '.mat');
    usr_model = strcat(strcat('../Model/usr_Q_factor_', update_method), '.mat');


stop = 0;
%try   %進行例外(Exception)處理
        day = str2num(fgetl(serialPort));   %使用fgetl()來讀去從Serial Port讀到的值
        hour = str2num(fgetl(serialPort));
        supNum = str2num(fgetl(serialPort));
        sup = zeros(1, supNum);
        for i=1:supNum
            sup(1, i) = str2double(fgetl(serialPort));
        end
        usrNum = str2num(fgetl(serialPort));
        usr = zeros(1, usrNum);
        for i=1:usrNum
            usr(1, i) = str2double(fgetl(serialPort));
        end
        disp([day, hour]);
        disp(sup);
        disp(usr);

        [Result_hour] = testSingleHour(sup, ...
                usr, ...
                quoted_price_range, buy_price_range, supply_range, ...
                demand_range, sup_model, usr_model);
        Result = fetchOutcomeToResult(Result, Result_hour, day, hour);
        set(handles.slider2, 'Value', day);
        set(handles.slider1, 'Value', hour + start_time - 1);
        update_graph_data(handles, day, hour);
 


% --- Executes on button press in pushbutton_stop.
function pushbutton_stop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global T;
stop(T);
handles.pushbutton_stop.Enable = 'off';
delete(instrfindall);