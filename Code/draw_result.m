function draw_result(Result, Result_QL, Result_fix, day_num, sup_p_ub, ...
    usr_p_ub, usr_p_lb, SAVE_FLAG, output_dir)
% Description:
%   This is function for plotting the result.
%   Author: Chan-Wei Hu
%=========================================================================

%% Plot the supplier quoted price difference 
% Reshape it first : [day_num*hour_intv, plant_num] -> [day_num, hour_intv, plant_num]
hour_intv = 7:1:18;
plant_num = size(Result.sup_price_RL,2);
sup_p_R_SMART = zeros(day_num, length(hour_intv), plant_num);
sup_p_QL = zeros(day_num, length(hour_intv), plant_num);
sup_p_fix = zeros(day_num, length(hour_intv), plant_num);
sup_p_Random = zeros(day_num, length(hour_intv), plant_num);
for i = 1:day_num
    sup_p_R_SMART(i, :, :) = Result.sup_price_RL((i-1)*length(hour_intv)+1:i*length(hour_intv), :);
    sup_p_Random(i, :, :) = Result.sup_price_Random((i-1)*length(hour_intv)+1:i*length(hour_intv), :);
    sup_p_QL(i, :, :) = Result_QL.sup_price_RL((i-1)*length(hour_intv)+1:i*length(hour_intv), :);
    sup_p_fix(i, :, :) = Result_fix.sup_price_RL((i-1)*length(hour_intv)+1:i*length(hour_intv), :);
end
sup_avg_p_R_SMART = squeeze(sum(sum(sup_p_R_SMART,1),3)/(day_num*plant_num));
sup_avg_p_QL = squeeze(sum(sum(sup_p_QL,1),3)/(day_num*plant_num)); 
sup_avg_p_fix = squeeze(sum(sum(sup_p_fix,1),3)/(day_num*plant_num));
sup_avg_p_Random = squeeze(sum(sum(sup_p_Random,1),3)/(day_num*plant_num));
figure();
plot(hour_intv, sup_avg_p_R_SMART, '-o', ...
     hour_intv, sup_avg_p_QL, '-+', ...
     hour_intv, sup_avg_p_fix, '--', ...
     hour_intv, sup_avg_p_Random, '-x');
legend('R-SMART', 'Q-learning', 'Fix quoted price', 'Random');
title('Average supplier price comparison');
ylabel('Avg. price');
xlabel('time');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, '/supplier_price_cmp.jpg'));
end

%% Plot the user buy price difference 
% Reshape it first : [day_num*hour_intv, plant_num] -> [day_num, hour_intv, plant_num]
buy_num = size(Result.usr_price_RL,2);
usr_p_R_SMART = zeros(day_num, length(hour_intv), buy_num);
usr_p_QL = zeros(day_num, length(hour_intv), buy_num);
usr_p_fix = zeros(day_num, length(hour_intv), buy_num);
usr_p_Random = zeros(day_num, length(hour_intv), buy_num);
for i = 1:day_num
    usr_p_R_SMART(i, :, :) = Result.usr_price_RL((i-1)*length(hour_intv)+1:i*length(hour_intv), :);
    usr_p_QL(i, :, :) = Result_QL.usr_price_RL((i-1)*length(hour_intv)+1:i*length(hour_intv), :);
    usr_p_Random(i, :, :) = Result.usr_price_Random((i-1)*length(hour_intv)+1:i*length(hour_intv), :);
    usr_p_fix(i, :, :) = Result_fix.usr_price_RL((i-1)*length(hour_intv)+1:i*length(hour_intv), :);
end
usr_avg_p_RL = squeeze(sum(sum(usr_p_R_SMART,1),3)/(day_num*buy_num));
usr_avg_p_QL = squeeze(sum(sum(usr_p_QL,1),3)/(day_num*buy_num));
usr_avg_p_fix = squeeze(sum(sum(usr_p_fix,1),3)/(day_num*buy_num));
usr_avg_p_Random = squeeze(sum(sum(usr_p_Random,1),3)/(day_num*buy_num));
figure();
plot(hour_intv, usr_avg_p_RL, '-o', ...
     hour_intv, usr_avg_p_QL, '-+', ...
     hour_intv, usr_avg_p_fix, '--', ...
     hour_intv, usr_avg_p_Random, '-x');
legend('R-SMART', 'Q-learning', 'Fix quoted price', 'Random');
title('Average user price comparison');
ylabel('Avg. price');
xlabel('time');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, '/User_price_cmp.jpg'));
end

%% Actual supply and ideal supply comparison
ideal_supply = sum(sum(Result.sup_ideal_supply,1)/day_num, 3);
sup_QL = squeeze(sum(sum(Result_QL.sup_actual_supply_RL,1)/day_num,3)./ideal_supply)*100;
sup_R_SMART = squeeze(sum(sum(Result.sup_actual_supply_RL,1)/day_num,3)./ideal_supply)*100;
sup_fix = squeeze(sum(sum(Result_fix.sup_actual_supply_RL,1)/day_num,3)./ideal_supply)*100;
sup_Random = squeeze(sum(sum(Result.sup_actual_supply_Random,1)/day_num,3)./ideal_supply)*100;
figure();
plot(hour_intv, sup_R_SMART, '-o', ...
     hour_intv, sup_QL, '-x', ...
     hour_intv, sup_fix, '--', ...
     hour_intv, sup_Random, '-+');
legend('R-SMART', 'Q-learning', 'Fix quoted price', 'Random');
title('Supplier total supply comparison');
ylabel('%');
xlabel('hour');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, '/Supply.jpg'));
end

%% Actual get and ideal need comparison
ideal_need = sum(sum(Result.usr_ideal_need,1)/day_num, 3);
usr_QL = squeeze(sum(sum(Result_QL.usr_actual_get_RL,1)/day_num,3)./ideal_need)*100;
usr_R_SMART= squeeze(sum(sum(Result.usr_actual_get_RL,1)/day_num,3)./ideal_need)*100;
usr_fix = squeeze(sum(sum(Result_fix.usr_actual_get_RL,1)/day_num,3)./ideal_need)*100;
usr_Random = squeeze(sum(sum(Result.usr_actual_get_Random,1)/day_num,3)./ideal_need)*100;
figure();
plot(hour_intv, usr_R_SMART, '-o', ...
     hour_intv, usr_QL, '-x', ...
     hour_intv, usr_fix, '--', ...
     hour_intv, usr_Random, '-+');
legend('R-SMART', 'Q-learning','Fix quoted price', 'Random');
title('Percentage of user need comparison');
ylabel('%');
xlabel('hour');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, '/User Need.jpg'));
end

%% Plot supplier average benefit of RL vs Random
figure();
sup_R_SMART = squeeze(sum(sum(Result.sup_actual_supply_RL,1)/day_num,3));
sup_Random = squeeze(sum(sum(Result.sup_actual_supply_Random,1)/day_num,3));
sup_fix = squeeze(sum(sum(Result_fix.sup_actual_supply_Random,1)/day_num,3));
R_SMART_percentage = ((sup_R_SMART./ideal_need).*(sup_avg_p_R_SMART/sup_p_ub));
fix_percentage = ((sup_fix./ideal_need).*(sup_avg_p_fix/sup_p_ub));
Random_percentage = ((sup_Random./ideal_need).*(sup_avg_p_Random/sup_p_ub));

% Result of fixed to lowest price
sup_QL = squeeze(sum(sum(Result_QL.sup_actual_supply_RL,1)/day_num,3));
QL_percentage = ((sup_QL./ideal_need).*(sup_avg_p_QL/sup_p_ub));

plot(hour_intv, R_SMART_percentage*100,  '-o', ... 
     hour_intv, QL_percentage*100, '-+', ...
     hour_intv, fix_percentage*100, '--', ...
     hour_intv, Random_percentage*100, '-x');
legend('R-SMART', 'Q-learning','Fix quoted price', 'Random');
title('Average supplier benefit');
ylabel('Benefit Ratio');
xlabel('Day');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, '/Average_supplier_benefit.jpg'));
end
%hour_avg_RL = sum((sup_RL./sup_ideal).*(sup_avg_p_RL/9))/length(hour_intv);
%hour_avg_random = sum((sup_Random./sup_ideal).*(sup_avg_p_Random/9))/length(hour_intv);
%fprintf('Supplier benefit improves %.2f%% than Random\n', ...
%    ((hour_avg_RL - hour_avg_random)/hour_avg_random)*100);

%% Plot user average benefit of RL vs Random 
figure();
usr_ideal = squeeze(sum(sum(Result.usr_ideal_need,1)/day_num, 3));
usr_R_SMART = squeeze(sum(sum(Result.usr_actual_get_RL,1)/day_num,3));
usr_fix = squeeze(sum(sum(Result_fix.usr_actual_get_RL,1)/day_num,3));
usr_Random = squeeze(sum(sum(Result.usr_actual_get_Random,1)/day_num,3));
RL_percentage = ((usr_R_SMART./usr_ideal).*(1-((usr_avg_p_RL-usr_p_lb)/(usr_p_ub-usr_p_lb))));
Random_percentage = ((usr_Random./usr_ideal).*(1-((usr_avg_p_Random-usr_p_lb)/(usr_p_ub-usr_p_lb))));
fix_percentage = ((usr_fix./usr_ideal).*(1-((usr_avg_p_fix-usr_p_lb)/(usr_p_ub-usr_p_lb))));

% Fixed to lowest quoted price
usr_QL = squeeze(sum(sum(Result_QL.usr_actual_get_RL,1)/day_num,3));
QL_percentage = ((usr_QL./usr_ideal).*(1-((usr_avg_p_QL-usr_p_lb)/(usr_p_ub-usr_p_lb))));

plot(hour_intv,  RL_percentage*100, '-o', ...
     hour_intv, QL_percentage*100, '-+', ...
     hour_intv, fix_percentage*100, '--', ...
     hour_intv,  Random_percentage*100, '-x');
legend('R-SMART', 'Q-learning','Fix quoted price', 'Random');
title('Average user benefit comparison');
ylabel('Benefit Ratio');
xlabel('Day');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, '/Average_user_benefit.jpg'));
end
%hour_avg_RL = sum((usr_RL./usr_ideal).*(1-usr_avg_p_RL/usr_p_ub))/length(hour_intv);
%hour_avg_random = sum((usr_Random./usr_ideal).*(1-usr_avg_p_Random/usr_p_ub))/length(hour_intv);
%fprintf('User benefit improves %.2f%% than Random\n', ...
%    ((hour_avg_RL - hour_avg_random)/hour_avg_random)*100);

end