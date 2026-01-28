%%
if t_current<=T
for tau = 1:T
    avg_constr = 0;
    x_pred = x(:,end);

    for i = t_current-T+tau : t_current+tau-1
        %case 1: i < 1
        if i < 1
            avg_constr = avg_constr + 0;
        elseif i >= 1
        %case 1:
            if (i <= t_current-1)
                avg_constr = avg_constr + h(x_past(:,i),u_past(:,i));
            elseif(i >= t_current)&&(i <= t_current+N-1)
                avg_constr = avg_constr + h(x(:,i-t_current+1),u(:,i-t_current+1));
            else
                u_pred = norm(x_pred);
                avg_constr = avg_constr + h(x_pred,u_pred);
                x_pred = dynamics(x_pred,u_pred);
            end
            
        end
    end
    opti.subject_to(avg_constr <= 0);

end
end