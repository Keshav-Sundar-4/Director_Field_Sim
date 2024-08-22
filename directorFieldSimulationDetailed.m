function directorFieldSimulationDetailed()
    % Simulation parameters (can be changed by the user)
    gamma = 0.1;    % Damping coefficient
    kappa = 0.1;    % Diffusion coefficient
    beta = 0.2;     % Reaction term scaling
    Lx = 40;       % Domain size in x
    Ly = 40;       % Domain size in y
    Nx = 250;     % Number of grid points in x
    Ny = 250;     % Number of grid points in y
    dt = 0.001;    % Time step
    T = 3;        % Total time of simulation

    % Spatial setup
    x = linspace(-Lx/2, Lx/2, Nx);
    y = linspace(-Ly/2, Ly/2, Ny);
    [X, Y] = meshgrid(x, y);
    dx = x(2) - x(1);
    dy = y(2) - y(1);

    % Initial conditions for q1 and q2
    q1 = rand(Ny, Nx) - 0.5;
    q2 = rand(Ny, Nx) - 0.5;

    % Setup figure for visualization
    h = figure;
    quiver_scale = 0.5; % Adjusts the length of arrows in quiver plot

    % Time integration using Euler's method
    for t = 0:dt:T
        % Calculate Laplacian of q1 and q2
        Lap_q1 = del2(q1, dx, dy);
        Lap_q2 = del2(q2, dx, dy);

        % Update q1 and q2 using the PDEs
        q1 = q1 + dt * gamma * (-4*q2.^2 .* q1 + kappa * Lap_q1 - beta * (gradient(q1).^2 - 0.5 * grad_C(X, Y).^2));
        q2 = q2 + dt * gamma * (-4*q2.^2 .* q2 + kappa * Lap_q2 - beta * gradient(q1) .* gradient(q2));

        % Update the plot
        if mod(t, 0.1) <= dt  % Adjust condition to match dt
            angles = atan2(q2, q1); % Calculate angles
            quiver(X, Y, cos(angles), sin(angles), quiver_scale, 'k'); % Ensure vectors are visible
            title(sprintf('Director Field at t = %.2f seconds', t));
            axis equal tight; % Adjust plot to fit the data
            drawnow; % Force update of the plot
        end

        %disp(['Max q1: ', num2str(max(max(q1))), ' Min q1: ', num2str(min(min(q1)))]);
        %disp(['Max q2: ', num2str(max(max(q2))), ' Min q2: ', num2str(min(min(q2)))]);


        % Check for user cancellation
        if ~ishandle(h)
            break;
        end
    end
end

function Lap = del2(f, dx, dy)
    % Discrete Laplacian in 2D using finite differences
    Lx = (circshift(f, [0 -1]) + circshift(f, [0 1]) - 2 * f) / dx^2;
    Ly = (circshift(f, [-1 0]) + circshift(f, [1 0]) - 2 * f) / dy^2;
    Lap = Lx + Ly;
end

function gC = grad_C(X, Y)
    % Placeholder for gradient of C, user-defined function needed
    gC = sin(X) + cos(Y);  % Example gradient, replace with actual function
end

