%% Compute the F and Phi matrices of MPC
% X(k) = Fx(0/k)+Phi*U(k)
% (Required parameters: 1) n – dimension of the state vector x(k);
% 2) p – dimension of the input vector u(k);
% 3) N – prediction horizon length;
% 4) A – system state transition matrix;
% 5) B – system input matrix.)

function [F_mat,Phi_mat] = mpc_mat(n,p,N,A,B)
%% The dimension of F is n(N+1) × n;number of rows: n(N+1);number of columns: n.
%% Compute the F matrix
    F_mat = zeros(n*(N+1),n);
    I_nn = eye(n);
    for i = 0:N
% In the first iteration, the indexing starts from the first row of the matrix to the n-th row.
%In the second iteration, the indexing starts from (1 + n) to (n + n), and so on.
%Finally, the general indexing formula is from i·n + 1 to i·n + n.
        F_mat(n*i+1:n*i+n,:) = I_nn; 
        I_nn = I_nn * A;
    end
 %% Compute the Phi matrix
    Phi_prime = zeros(n*N,N*p);
    Phi_zero = zeros(n,N*p);
    for i = 1:N
        I_tmp = B;
        for j = i:-1:1
        %% In the first iteration (i = 1), expand an n-by-p block at the first index position.
        %Row indices: (1 + (i − 1)n : i·n);
        %Column indices: (1 + (j − 1)p : j·p).
            n_start = 1+(i-1)*n;
            n_end = i*n;
            p_start = 1 + (j-1)*p;
            p_end = j*p;
        %%fprintf("%d %d %d %d",n_start,n_end,p_start,p_end);
        %%fprintf('\n');
            Phi_prime(n_start:n_end,p_start:p_end) = I_tmp;
             I_tmp = A*I_tmp;
        end
    end
    Phi_mat = [Phi_zero;Phi_prime];
end