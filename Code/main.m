% This is main file of Smart Grid project
% Author: Chan-Wei Hu
%=========================================================================
clear global; 
close all;
warning off;

phase = 'test';
update_method = 'R-SMART';
SAVE_FLAG = 0;
SAVE_PATH = strcat('../Result/', update_method);
quoted_price_range = [4 9];
buy_price_range = [3 8];
supply_range = [0 200];
demand_range = [0 200];
sup_model = strcat(strcat('../Model/sup_Q_factor_', update_method), '.mat');
usr_model = strcat(strcat('../Model/usr_Q_factor_', update_method), '.mat');

if strcmp(phase,'train')
    % Training phase
    % Define the path of training data 
    DATA_PATH = '../Data/Supplier/train/';

    % Set up parameters
    % Best: lr = 0.001, beta=0.01
    lr = 0.001;
    beta = 0.01;
    eta = 0.99;
    ITERMAX = 50;

    train(DATA_PATH, quoted_price_range, buy_price_range, supply_range, ...
        demand_range, update_method, lr, beta, eta, ITERMAX, sup_model, ...
        usr_model);
    
elseif strcmp(phase, 'test')
    % Testing phase
    % Define the test data path
    DATA_PATH = '../Data/Supplier/test/';

    [Result] = test(DATA_PATH, quoted_price_range, buy_price_range, supply_range, ...
        demand_range, sup_model, usr_model);
    
    quoted_price_range = [4 9];
    update_method = 'Q-learning';
    sup_model = strcat(strcat('../Model/sup_Q_factor_', update_method), '.mat');
    usr_model = strcat(strcat('../Model/usr_Q_factor_', update_method), '.mat');
    
    [Result_fix] = test(DATA_PATH, quoted_price_range, buy_price_range, supply_range, ...
        demand_range, sup_model, usr_model);
    
    day_num = 39;
    % Draw the result
    draw_result(Result, Result_fix, day_num, quoted_price_range(2), ...
        quoted_price_range(1), buy_price_range(2), buy_price_range(1), ...
        SAVE_FLAG, SAVE_PATH);
else
    error('[ERROR] Undefined phase, please check your argument.');
end    

    
