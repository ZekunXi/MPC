clear;
clc;
addpath('C:\matlab\casadi');
import casadi.*;
opti = casadi.Opti();
opti.solver('ipopt');

%% setting system

f = @(x,u)[-x(2); x(3)+exp(x(2))*x(3); sin(x(3))+u(1)];

n = 3; % dimension of x
p = 1; % dimension of u

% simulation parameters
delta = 0.1;
T = 1;
N = T/delta;
k_steps = 100; % length of arr to save the X_and U_predict

% weighting matrices
Q = 10*eye(n);
R = 0.1*eye(p);

%initial condition of x0
x0 = [0.5;0.3;0.2];

%% setting solver template

% storage for optimal parameters x and u for online predict
x = opti.variable(n,N+1);
u = opti.variable(p,N);

%setting initial constraints
xt = opti.parameter(n,1);
opti.set_value(xt,x0);
opti.subject_to(x(:,1) == xt);

%setting inputs constraints
opti.subject_to(-2 <= u <= 2);

%setting terminal constraints
% 1.zero terminal constriants

%here it is impossible to use the zeros terminal
%opti.subject_to(x(:,N+1) == zeros(n,1));

%setting dynamics constraints
%by using Runge-Kutta4 methode

for i = 1:N
    k1 = f(x(:,i), u(:,i));
    k2 = f(x(:,i)+delta*k1/2, u(:,i));
    k3 = f(x(:,i)+delta*k2/2, u(:,i));
    k4 = f(x(:,i)+delta*k3, u(:,i));
    x_next = x(:,i) + delta*(k1+2*k2+2*k3+k4)/6;
    opti.subject_to(x(:,i+1) == x_next);
end

%setting cost function J and minimize
J = 0;
for i = 1:N
    J = J + delta*x(:,i)'*Q*x(:,i)+ delta*u(:,i)'*R*u(:,i);
end

%for J = J + transpose(x(:,N+1))*P_terminal*x(:,N+1)

% minimize J
opti.minimize(J);

%% simulation in close loop
%setting storage arr for X_predict and U_predict
X_predict = zeros(n,k_steps+1);
U_predict = zeros(p,k_steps);
X_predict(:,1) = x0;

%simulation start
for i = 1:k_steps
    %solve the optimal problem
    sol = opti.solve();
    x_online_tmp = sol.value(x);
    u_online_tmp = sol.value(u);

    %update the predict arr
    U_predict(:,i) = u_online_tmp(:,1);
    X_predict(:,i+1) = x_online_tmp(:,2);
    
    %update the startvalue for beginning of next loop
    opti.set_value(xt,X_predict(:,i+1));

    %use the current optimal solution as the feasible solution of the next
    %loop
    opti.set_initial(x,[x_online_tmp(:,2:N+1),zeros(n,1)]);
    opti.set_initial(u,[u_online_tmp(:,2:N),zeros(p,1)]);
end

%% plot
subplot(2,1,1);
hold on;
for i = 1:n
    plot(X_predict(i,:));
end
hold off;

subplot(2,1,2);
hold on;
for i = 1:p
    plot(U_predict(i,:));
end
hold off;

