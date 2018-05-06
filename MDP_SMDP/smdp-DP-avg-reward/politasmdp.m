function [policy,x]=politasmdp(tpm,trm,ttm)  

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
        
           if col==1
           % first column contains coefficients of g*/
           sum=0;
               for next_state=1:NS
               
               sum=sum+(tpm(row,next_state,policy(row))*ttm(row,next_state,policy(row)));
               
               end
               
               G(row,1)=sum;
            
               
           else
           
       		  if row==col

                  
                  
       		  G(row,col)=1-tpm(row,col,policy(row));
            
              else  
       		
       		  G(row,col)=-tpm(row,col,policy(row));
              
              end
              
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

    % Determine the avg reward 

    rho=x(1)

 


    % The first value of value function vector is set to 0 */

    x(1)=0;

    % 2. Policy improvement stage */

    done=0;

    for state=1:NS
    
    large=SMALL; 
    best_action=0;
  
    	for action=1:NA
    	% determine the best action for the state 
    	sum1=0;
        sum2=0;

       	    for next_state=1:NS
       	    
       	    sum1=sum1+ (tpm(state,next_state,action)*(trm(state,next_state,action)+x(next_state)));
       	    sum2=sum2+ (tpm(state,next_state,action)*ttm(state,next_state,action));
            end

            gain=sum1-(rho*sum2);  
       	    if gain>large 
            
       	    large=gain;
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




