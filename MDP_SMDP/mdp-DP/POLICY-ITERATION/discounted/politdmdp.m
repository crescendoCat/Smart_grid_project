function [policy,x]=politdmdp(tpm,trm,d_factor)  

SMALL=-100000; % some small number
[NS,NS,NA]=size(tpm);
policy=ones(NS,1);


G=zeros(NS,NS);
b=zeros(NS,1);

iteration=0;
done=1;

while 1==done 
% As long as two consecutive policies do not become identical. */


   % 1. Policy evaluation stage */
   % The linear equations to be solved are Gx=b. */
   % Initializing a part of the G Matrix. */

    for row=1:NS
    
	for col=1:NS
        
           
           
       		  if row==col

                  
                  
       		  G(row,col)=1-(d_factor*tpm(row,col,policy(row)));
            
              else  
       		
       		  G(row,col)=-(d_factor*tpm(row,col,policy(row)));
              
              end
              
           end
        end
    
    
       % Initializing the b matrix; equation is Gx=b*/

    for state=1:NS
    
    sum=0.0;
     	for next_state=1:NS
     	
     	sum=sum+(tpm(state,next_state,policy(state))*trm(state,next_state,policy(state)));
        end
        b(state,1)=sum;
    end
    
    
    x=G\b; % x comes out as the solution 

policy
value_function=x
 


    

    % 2. Policy improvement stage */

    done=0;

    for state=1:NS
    
    large=SMALL; 
    best_action=0;
  
    	for action=1:NA
    	% determine the best action for the state 
    	sum1=0;
        

       	    for next_state=1:NS
       	    
       	    sum1=sum1+ (tpm(state,next_state,action)*(trm(state,next_state,action)+(d_factor*x(next_state))));
       	    
            end

            
       	    if sum1>large 
            
       	    large=sum1;
       	    best_action=action;
            end

         end

         if policy(state)~=best_action
         % Policy has improved; record new action */
         policy(state)=best_action;
         done=1; % to ensure that one more iteration is done */
         end

     end

iteration=iteration+1;
end
  
iterations_needed=iteration

policy_returned=policy

value_function_returned=x




