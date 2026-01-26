% Ak = A + B*K_loc, K_loc is for local control law
% in the terminal invariant set:
% ∀z(i)∈ℤ and ∀v_loc(i) = K_loc*z(i)∈𝕍

%A_z = [ℤ.A;(𝕍.A)*K_loc] and b_z = [ℤ.b;𝕍.b]


function[Zf_Poly_set,A_Zf,b_Zf] = search_invariant_set(Ak,A_z,b_z)
    
    options = optimset('Display','off');

    % calculate search range for every search loop
    n_search_end = length(b_z(:,1));
    
    %max_value in the constranit area
    f_max_value = -inf;

    %setting storage for constraint
    A_current = A_z;
    b_current = b_z;
    %A_extend_next = [];
    %b_extend_next = [];
   
    A_extend_tmp = A_z;

    while(1)

        %find the max_value from every possible linear combination
        
        for i = 1:n_search_end
            [~,f_current_target_max] = linprog(-A_current(end+i-n_search_end,:)*Ak,A_current,b_current,[],[],[],[],options);

            %update the global_max_value
            f_max_value = max(f_max_value,-f_current_target_max-b_current(end+i-n_search_end));
        end
        
        % if the global_max_value <= 0 =====> search stop
        % else the A_extend_next and b_extend_max update

        if f_max_value<=0
            break;
        else
            f_max_value = -inf;
            A_extend_tmp = A_extend_tmp*Ak;
            A_extend_next = [A_current;A_extend_tmp];
            b_extend_next = [b_current;b_z];
        end

        %update the A_current and b_current for next loop
        A_current = A_extend_next;
        b_current = b_extend_next;
    end

        A_Zf = A_current;
        b_Zf = b_current;
        Zf_Poly_set = Polyhedron(A_Zf,b_Zf);
        Zf_Poly_set.minHRep();
        Zf_Poly_set.minVRep();
        
end

