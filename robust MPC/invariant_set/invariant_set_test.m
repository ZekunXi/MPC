clc;
clear;
H = [-1 0;1 0;0 -1;0 1];
h = [1;1;5;5];

X = Polyhedron(H,h);

A = [0.8 0.2;0.3 0.5];
eigen_value = eig(A);

check_term = H*A; %HA,HAA,HAAA,HAAA...

H_current = H;
h_current = h;
H_next = [];
h_next = [];

%counter = 1;

while(1)
    %if counter == 0
        %break;
    %end
    X_current = Polyhedron(H_current,h_current);
    X_next_step = Polyhedron(check_term,h);
    hold on;
    plot(Polyhedron(H_current,h_current),'color','white');

    H_next = [H_current;check_term];
    check_term = check_term * A;
    h_next = [h_current;h];

    if(X_current <= X_next_step)
        disp("true!");
        
        p1 = plot(Polyhedron(H_current,h_current),'color','yellow');
        set(p1,'FaceAlpha',0.9);
        break;
    else
        H_current = H_next;
        h_current = h_next;
    end

    %counter = counter - 1;

end

p2 = plot(Polyhedron(H_next,h_next),'color','blue');
set(p2,'FaceAlpha',0.1);

