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
quoted_price_range = [1 8];
buy_price_range = [3 10];
supply_range = [0 200];
demand_range = [0 200];
% Set up parameters
% Best: lr = 0.001, beta=0.01
lr = 0.001;
beta = 0.01;
eta = 0.9;
ITERMAX = 100;
sup_model = strcat('../Model/sup_Q_factor_', update_method, '_iter_', int2str(ITERMAX), '.mat');
usr_model = strcat('../Model/usr_Q_factor_', update_method, '_iter_', int2str(ITERMAX), '.mat');
sup_model_QL = strcat('../Model/sup_Q_factor_', update_method_QL, '_iter_', int2str(ITERMAX), '.mat');
usr_model_QL = strcat('../Model/usr_Q_factor_', update_method_QL, '_iter_', int2str(ITERMAX), '.mat');
sup_model_fix = strcat('../Model/sup_Q_factor_fix_qp_iter_', int2str(ITERMAX), '.mat');
usr_model_fix = strcat('../Model/usr_Q_factor_fix_qp_iter_', int2str(ITERMAX), '.mat');

if strcmp(phase,'train')
    % Training phase
    % Define the path of training data 
    DATA_PATH = '../Data/Supplier/train/';

    fprintf('Training with R-SMART\n');
    train(DATA_PATH, quoted_price_range, buy_price_range, supply_range, ...
           demand_range, update_method, lr, beta, eta, ITERMAX, sup_model, ...
           usr_model);
       
    fprintf('Training with basic Q-learning\n');
    train(DATA_PATH, quoted_price_range, buy_price_range, supply_range, ...
           demand_range, update_method_QL, lr, beta, eta, ITERMAX, sup_model_QL, ...
           usr_model_QL);
       
    fprintf('Training with fix quoted price\n');
    train(DATA_PATH, [quoted_price_range(1) quoted_price_range(1)], ...
           buy_price_range, supply_range, demand_range, update_method, lr, ...
           beta, eta, ITERMAX, sup_model_fix, usr_model_fix);
   
    
elseif strcmp(phase, 'test')
    % Testing phase
    % Define the test data path
    DATA_PATH = '../Data/Supplier/test/';

    [Result] = test(DATA_PATH, quoted_price_range, buy_price_range, supply_range, ...
        demand_range, sup_model, usr_model);
    
    [Result_Q_learning] = test(DATA_PATH, quoted_price_range, buy_price_range, supply_range, ...
        demand_range, sup_model_QL, usr_model_QL);
    
    [Result_fix] = test(DATA_PATH, quoted_price_range, buy_price_range, supply_range, ...
        demand_range, sup_model_fix, usr_model_fix);
    
    day_num = 39;
    % Draw the result
    draw_result(Result, Result_Q_learning, Result_fix, day_num, quoted_price_range(2), ...
        buy_price_range(2), buy_price_range(1), SAVE_FLAG, SAVE_PATH);
else
    error('[ERROR] Undefined phase, please check your argument.');
end    

    
