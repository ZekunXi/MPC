function [A,B,C] = WEC_parameters_creater()
%% setting parameters of WEC-system
m_buoy = 0.47; % mass of buoy
m_inf = 3.69; % added mass at the infinite frequency
Sh = 429.68; % Sh = S*ρ*g =====> hydrostatic stiffness
rho = 1000; % water density
g = 9.81; % gravitational acceleration

%% setting state space model

% intermediate state zr
% zr_dot = Ar·zr + Br·z_dot z_dot = v
Ar = [-0.8066, 5.9737, 0.5962, -0.9641;
     -5.9737, -0.0920, -0.1034, 0.6089;
     -0.5962, -0.1034, -0.1487, 4.7374;
     -0.9641, -0.6089, -4.7374, -1.7513];  
Br = [-0.0149; -0.0048; -0.0037; -0.0113]; 
Cr = [-0.7454, 0.2405, 0.1843, -0.5636]; 
nr = size(Ar,1); %dimension of state 

%initial state x0 
x0 = [0;0;zeros(nr,1)];

m_total = m_inf + m_buoy;
%create continuous state space model
Ac = [0 1 zeros(1,nr);-Sh/m_total,0,-Cr/m_total;zeros(nr,1),Br,Ar];
Bc_Fpto = [0;1/m_total;zeros(nr,1)]; %Bc Matrix for PTO-system
Bc_Fexc = [0;1/m_total;zeros(nr,1)]; %Bc Matrix for excitation force

% total_state_set x = [z,z_dot,zr=[z1,z2,...,znr]]
% observable state are only z===>(displacement of buoy) and v=z_dot===>(velocity)
Cc = [1,0,zeros(1,nr); 0,1,zeros(1,nr)];

%create a new input state u_star = [Fpto;Fexc] with dimension: 2×1;
%then Bc = [Bc_Fpto,Bc_Fexc] with dimension: 6×2;
Bc = [Bc_Fpto,Bc_Fexc];

%y: observer state = [z;dot_z]
%y(2×1) = C(2×6)x_state(6×1) + D(2×2)*u_star(2×1)
Dc = zeros(size(Bc,2),size(Bc,2));

sys_continuous = ss(Ac,Bc,Cc,Dc); %<===== continuous state space

% create discrete time system
delta = 0.01; %sampling time for continuous to discrete
sys_discrete = c2d(sys_continuous,delta,'zoh');
Ad = sys_discrete.A;
Bd = sys_discrete.B;
Cd = sys_discrete.C;
Bd_Fpto = Bd(:,1);
Bd_Fexc = Bd(:,2);
A = Ad;
B = Bd_Fpto;
C = Cd;
end