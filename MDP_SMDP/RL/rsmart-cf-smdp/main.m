% Simulator for a Markov Chain 

% Embedded in it is the Q-Learning algorithm
rand('twister',25);
global NO_REPLICATIONS ITERMAX NA NS SMALL TPM TRM TTM ETA

global1 % global parameters initialized 

stat=struct('Q',zeros(NS,NA),'iter',0,'old_action',1,'old_state',1,'current_state',1,'rimm',0,'total_reward',0,'total_time',0,'flag',0,'rho',0,'explore',0.5);


        done=0; % Pnemonic for simulation, 1 stands for end
                % 0 stands for continue 

        	while 0==done
                
                [stat,done]=jump_learn(stat);
                
                end

                policy=pol_finder(stat);
                
                final_rho=stat.rho


