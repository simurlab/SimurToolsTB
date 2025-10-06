function [x_out, y_out, z_out, cmap] = esfera_3d(z_in, theta_min, theta_max, ...
                                    phi_min, phi_max, rho, mesh_scale, varargin)
%ESFERA_3D Representa datos 3D sobre una superficie esférica.
%
%   [x_out, y_out, z_out, cmap] = esfera_3d(z_in, theta_min, theta_max, ...
%       phi_min, phi_max, rho, mesh_scale, <plotspec>, <interpspec>, <z_scale>)
%
%   INPUT:
%       z_in        : matriz (M x N) con magnitudes a proyectar sobre la esfera.
%                     - Filas: barrido horizontal entre theta_min y theta_max.
%                     - Columnas: barrido vertical entre phi_min y phi_max.
%                     Se interpola si M  N. 
%       theta_min   : ángulo mínimo horizontal (rad).  
%       theta_max   : ángulo máximo horizontal (rad). |theta_max - theta_min|  2.  
%       phi_min     : ángulo mínimo vertical (rad).  
%       phi_max     : ángulo máximo vertical (rad). |phi_max - phi_min|  .  
%       rho         : radio base de la esfera (positivo, escalar).  
%       mesh_scale  : escala de mallado (>0). Si <1 aumenta resolución, si >1 la reduce.  
%
%   OPCIONALES (en varargin):
%       plotspec    : 'mesh' (defecto), 'surf', 'meshc', 'contour' u 'off'.  
%       interpspec  : 'linear' (defecto), 'spline', 'nearest' o 'cubic'.  
%       z_scale     : factor de escala de datos (1 por defecto). Si 1 amplifica/atenúa picos.  
%
%   OUTPUT:
%       x_out   : coordenadas X cartesianas.  
%       y_out   : coordenadas Y cartesianas.  
%       z_out   : coordenadas Z cartesianas.  
%       cmap    : mapa de colores asociado a (x_out, y_out, z_out).  
%
%   EXAMPLE:
%       % Datos sintéticos en una esfera de radio 5
%       z = peaks(50);
%       [x, y, z_out, cmap] = esfera_3d(z, 0, 2*pi, -pi/2, pi/2, 5, 1, 'surf');
%       figure, surf(x,y,z_out,cmap), axis equal
%
%   See also: polar3d, cyl3d, pol2cart, sph2cart, interp2
%
% Author:   J. M. De Freitas (QinetiQ, 2005)  
% Adaptación: normalizado a snake_case y documentación unificada  
% History:  27.09.2005  creación y publicación (beta)  
%           02.10.2025  adaptación a toolbox, renombrado como esfera_3d  
%

    % -------------------- Validaciones de entrada --------------------
    if (nargin < 7)
        error('esfera_3d: muy pocos argumentos de entrada.');
    elseif (nargin > 10)
        error('esfera_3d: demasiados argumentos de entrada.');
    end

    if theta_max <= theta_min
        error('theta_max debe ser mayor que theta_min.');
    end
    if abs(theta_max - theta_min) > 2*pi
        error('El rango de theta no puede ser mayor que 2.');
    end
    if phi_max <= phi_min
        error('phi_max debe ser mayor que phi_min.');
    end
    if abs(phi_max - phi_min) > pi
        error('El rango de phi no puede ser mayor que .');
    end
    if rho <= 0
        error('rho debe ser positivo.');
    end
    if mesh_scale <= 0
        warning('mesh_scale debe ser > 0, se ajusta a 1.');
        mesh_scale = 1;
    end

    % -------------------- Parámetros por defecto --------------------
    plot_spec = 'mesh';
    interp_spec = 'linear';
    z_scale = 1.0;

    % -------------------- Interpretar varargin --------------------
    if length(varargin) >= 1
        if ischar(varargin{1})
            plot_spec = varargin{1};
        elseif isnumeric(varargin{1})
            z_scale = varargin{1};
        end
    end
    if length(varargin) >= 2
        if ischar(varargin{2})
            interp_spec = varargin{2};
        elseif isnumeric(varargin{2})
            z_scale = varargin{2};
        end
    end
    if length(varargin) >= 3
        z_scale = varargin{3};
    end

    % -------------------- Preparar datos --------------------
    z_in = flipud(z_in);
    [r,c] = size(z_in);

    n = mesh_scale;
    if r > c
        L = r;
        L2 = fix(L/n)*n;
        step = r/(c-1);
        [X1,Y1] = meshgrid(0:step:r,1:r);
        [X,Y] = meshgrid(1:n:L2,1:n:L2); 
        T = interp2(X1,Y1,z_in,X,Y,interp_spec);
    elseif c > r
        L = c;
        L2 = fix(L/n)*n;
        step = c/(r-1);
        [X1,Y1] = meshgrid(1:c,0:step:c);
        [X,Y] = meshgrid(1:n:L2,1:n:L2); 
        T = interp2(X1,Y1,z_in,X,Y,interp_spec);
    else
        L = r;
        L2 = fix(L/n)*n;
        [X1,Y1] = meshgrid(1:r,1:r);
        [X,Y] = meshgrid(1:n:L2,1:n:L2); 
        T = interp2(X1,Y1,z_in,X,Y,interp_spec);
    end

    [p,q] = size(T);
    L2 = max(p,q);

    % -------------------- Construcción de ángulos --------------------
    theta = linspace(theta_min, theta_max, L2);
    phi   = linspace(phi_min, phi_max, L2);
    [theta_grid, phi_grid] = meshgrid(theta, phi);

    % -------------------- Escalado de datos --------------------
    T(isnan(T)) = 0;
    z_avg = mean(T(:));
    max_z = max(T(:)-z_avg);
    min_z = min(T(:)-z_avg);
    rho_max = rho + z_scale*max_z;
    rho_min = rho + z_scale*min_z;
    if rho_min < 0
        z_scale = -rho/min_z;
        warning('esfera_3d: z_scale ajustado a %.2f para evitar radios negativos', z_scale);
    end

    % -------------------- Conversión a coordenadas cartesianas --------------------
    [x_out, y_out, z_out] = sph2cart(theta_grid, phi_grid, rho + z_scale*T);

    % -------------------- Colormap --------------------
    n_color = 50;
    [cmap, ~, ~] = radial_colormap(x_out,y_out,z_out,n_color);

    % -------------------- Representación --------------------
    switch plot_spec
        case 'mesh'
            mesh(x_out,y_out,z_out); colormap(gray);
            axis equal off vis3d;
        case 'meshc'
            meshc(x_out,y_out,z_out); colormap(gray);
            axis equal off vis3d;
        case 'surf'
            surf(x_out,y_out,z_out,cmap); shading interp;
            axis equal off vis3d; colorbar;
        case 'contour'
            contour3(x_out,y_out,z_out,25); axis equal vis3d; grid on;
        case 'off'
            % No dibuja nada
        otherwise
            warning('esfera_3d: plotspec desconocido, se usa mesh');
            mesh(x_out,y_out,z_out);
    end
end

% -------------------- Función auxiliar: mapa radial --------------------
function [cmap,Rmax,Rmin] = radial_colormap(X,Y,Z,n_color)
    R = sqrt(X.^2 + Y.^2 + Z.^2);
    Rmax = max(R(:));
    Rmin = min(R(:));
    cmap = (R - Rmin) / (Rmax - Rmin) * n_color;
end
