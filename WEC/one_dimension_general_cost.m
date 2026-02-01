clc;
clear;
close all;

%% plot surface of target function
% f(x,u) = lambda*u*u-u*x with lambda = 0.01
% setting range of parameters x and u
% x ===> z_dot(velocity) in range[-1,1] and u ===> Fpto in range [-200,200]

x = linspace(-1,1,200); %z_dot
u = linspace(-200,200,400); % Fpto

[X,U] = meshgrid(x,u);

lambda = 0.01;
F = -X.*U + lambda.*U.*U;
surf(X,U,F);
xlabel('x = z_dot');
ylabel('u = Fpto');
zlabel('f(x,u)= -xu+λuu');
colorbar;

%% search process
%z(1)=x=z_dot; z(2)=u=Fpto
f_target = @(z)(-z(1)*z(2)+lambda*z(2)*z(2));
z_dot_limit = 1;
Fpto_limit = 200;
ub = [z_dot_limit;Fpto_limit];
lb = -ub;

x_save_arr = zeros(1,10);
u_save_arr = zeros(1,10);
J_local_min_save = zeros(1,10);
counter = 1;

J_stage_global_min = inf;
for z1 = -z_dot_limit:1:z_dot_limit
    for z2 = -Fpto_limit:200:Fpto_limit
        z0 = [z1;z2];
        z_star_online = fmincon(f_target,z0,[],[],[],[],lb,ub);
        J_stage_local_min = -z_star_online(1)*z_star_online(2) + lambda*z_star_online(2)*z_star_online(2);
        if J_stage_local_min < J_stage_global_min
            J_stage_global_min = J_stage_local_min;
            x_save_arr(:,counter) = z_star_online(1);
            u_save_arr(:,counter) = z_star_online(2);
            J_local_min_save(:,counter) = J_stage_local_min;
            counter = counter + 1;
        end
    end
end
