function [action,stat]=action_selector(stat)

global NA 

ran=rand(1);

if ran < stat.explore
% explore
stat.flag=1;
else
stat.flag=0;
end

state=stat.current_state;

if stat.Q(state,1)>stat.Q(state,2)

   if stat.flag==0
   action=1;
   else
   action=2;
   end

else

   if stat.flag==0
   action=2;
   else
   action=1;
   end

end

stat.explore=stat.explore*0.999;

