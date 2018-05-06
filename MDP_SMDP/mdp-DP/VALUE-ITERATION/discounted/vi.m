function [policy,V]=vi(tpm,reward,discount_factor)  
%  function to do relative value iteration for MDPs using discounted
% or average reward. For  avg reward set discount factor to 1.
% This function will also do value iteration by easy change below
% tpm is a 3-dimensional
% matrix with (i,j,k) standing for intial state,final state and action
% similarly reward is a 3-d matrix.  Policy is the actual policy and
% values is the vector of converged values for each state under optimal
% policy.
epsilon=0.001;
epsilom=epsilon*(1-discount_factor)*0.5/(discount_factor)

[no_states,no_states,no_actions]=size(tpm);
V=zeros(no_states,1); % INITIALIZING VALUES TO 0 AT THE START
V_old=zeros(no_states,1); % INITIALIZING VALUES TO 0 AT THE START

done=0;
iteration=1;
while done~=1

% done is set to 1 when values converge
iteration=iteration+1;
V_old=V;
  for state=1:no_states % for -1
    % for each state all the values are iterated once
    for action=1:no_actions % for -2
      % for each action the value for that state is calculated
    sum=0; 
      for next_state=1:no_states % for -3
      % to calculate value for each state-action pair
      
      sum=sum+tpm(state,next_state,action)*reward(state,next_state,action);
      sum=sum+tpm(state,next_state,action)*discount_factor*...
      V_old(next_state,1);
      end % end for -3
       Q(state,action)=sum; 
    end % end for -2
   % Setting the max value for a given state corresponding to different 
   % actions to V(state)

   [V(state,1),optimal_action(state)]=max(Q(state,1:no_actions));  

   end % end for -1

   iter=iteration
   value_function=V
   
Vdiff=V-V_old;
NORM=norm(Vdiff,inf);
%span=max(Vdiff)-min(Vdiff);
               if(NORM)<epsilom
               done=1;
               end 

 
end % of while loop
iteration
policy=optimal_action
