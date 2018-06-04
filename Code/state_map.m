function [state] = state_map(cur_dem_state, cur_sup_state, ...
    demand_state_num, supply_state_num)
% Description:
%   This is function for mapping the multiple state into one state.
%   Author: Chan-Wei Hu
%=========================================================================
total_state = demand_state_num*supply_state_num;
state = cur_dem_state * supply_state_num + cur_sup_state;

end