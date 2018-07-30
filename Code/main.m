% This is main file of Smart Grid project
% Author: Chan-Wei Hu
%=========================================================================
clear global; 
close all;
warning off;

phase = 'train';
update_method = 'R-SMART';
update_method_QL = 'Q-learning';
SAVE_FLAG = 1;
SAVE_PATH = '../Result';
%SAVE_PATH = strcat('../Result/', update_method);
quoted_price_range = [1 8];
buy_price_range = [3 10];
supply_range = [0 500];
demand_range = [0 500];
sup_model = strcat(strcat('../Model/sup_Q_factor_', update_method), '.mat');
usr_model = strcat(strcat('../Model/usr_Q_factor_', update_method), '.mat');
sup_model_QL = strcat(strcat('../Model/sup_Q_factor_', update_method_QL), '.mat');
usr_model_QL = strcat(strcat('../Model/usr_Q_factor_', update_method_QL), '.mat');


%
quoted_price_range_QL = [2 8];
%
if strcmp(phase,'train')
    % Training phase
    % Define the path of training data 
    DATA_PATH = '../Data/Supplier/train/';

    % Set up parameters
    % Best: lr = 0.001, beta=0.01
    lr = 0.001;
    beta = 0.01;
    eta = 0.9;
    ITERMAX = 100;

    train_origin(DATA_PATH, quoted_price_range, buy_price_range, supply_range, ...
           demand_range, update_method, lr, beta, eta, ITERMAX, sup_model, ...
           usr_model);
    %    demand_range, update_method, lr, beta, eta, ITERMAX, sup_model, ...
    %    usr_model);
    
elseif strcmp(phase, 'test')
    % Testing phase
    % Define the test data path
    DATA_PATH = '../Data/Supplier/test/';

    [Result] = test(DATA_PATH, quoted_price_range, buy_price_range, supply_range, ...
        demand_range, sup_model, usr_model);
    
    [Result_Q_learning] = test(DATA_PATH, quoted_price_range_QL, buy_price_range, supply_range, ...
        demand_range, sup_model_QL, usr_model_QL);
    
    day_num = 39;
    % Draw the result
    draw_result(Result, Result_Q_learning, day_num, quoted_price_range(2), ...
        quoted_price_range(1), buy_price_range(2), buy_price_range(1), ...
        SAVE_FLAG, SAVE_PATH);
else
    error('[ERROR] Undefined phase, please check your argument.');
end    

    
