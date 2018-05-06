function [stat]=rsmart(stat)

global NO_REPLICATIONS ITERMAX NA NS SMALL TPM TRM LAMBDA


% R-SMART-Learning  without SSP bounding

% Finding the MAX factor in the current state 

q_next=max(stat.Q(stat.current_state,:));


stat.iter=stat.iter+1;

if stat.flag==0

% update rho

%learn_rate1=0.5*300/(300+stat.iter);

learn_rate1=9/(100+stat.iter);

stat.rho=(1-learn_rate1)*(stat.rho)+learn_rate1*((stat.total_reward+stat.rimm)/(stat.iter+1));


stat.total_reward=stat.total_reward+stat.rimm;

end


learn_rate=log(stat.iter+1)/(stat.iter+1);

%learn_rate=10/(100+stat.iter+1);

q=stat.Q(stat.old_state,stat.old_action);

q=q*(1-learn_rate)+(learn_rate*(stat.rimm-stat.rho+(0.99*q_next)));

stat.Q(stat.old_state,stat.old_action)=q;

if stat.flag==0

learn_rate_limit=learn_rate1/learn_rate;

end