function [h1, h2] = dibujar_sistema_referencia(TT, color, tam, opt)
%DIBUJAR_SISTEMA_REFERENCIA Representa gráficamente un sistema de referencia 3D.
%
%   [h1, h2] = dibujar_sistema_referencia(TT, color, tam, opt)
%
%   Esta función dibuja un sistema de referencia (frame) definido por una 
%   matriz homogénea de transformación 4x4. También admite como entrada una 
%   trayectoria de transformaciones (array 4x4xN) y dibuja todos los frames.
%
%   INPUT:
%       TT    : matriz homogénea 4x4 o trayectoria 4x4xN de transformaciones.
%       color : color de los ejes (ej. 'r', 'g', 'b', [0.5 0.5 0.5]).
%       tam   : tamaño de las flechas que representan los ejes.
%       opt   : (opcional) si se pasa, se representan todos los frames en 
%               pantalla simultáneamente. Si no se pasa, se dibujan de forma 
%               secuencial quedando solo el último.
%
%   OUTPUT:
%       h1, h2 : handles de los patches de los ejes X/Y y Z respectivamente.
%
%   EJEMPLO:
%       T = eye(4); % frame identidad
%       dibujar_frame(T, 'r', 50); % dibuja el frame en rojo
%
%   See also: trvec2tform, quat2tform
%
% Author:   Iván Maza (2001, versión original)
% History:  29.09.2025   normalizada y modernizada

    % Número de transformaciones a representar
    np = size(TT,3);

    % Dimensiones de flechas y letras
    l1=tam/13; l2=tam/8; l3=(4/5)*tam; l4=tam; letra=tam*1.1;

    % Flechas eje X e Y
    datosx1=[l1 l3 l3 l4 l3 l3 -l1 -l1 -l2 0 l2 l1];
    datosy1=[l1 l1 l2 0 -l2 -l1 -l1 l3 l3 l4 l3 l3];
    datosz1=zeros(1,12);
    unos1=ones(1,12);
    link1=[datosx1; datosy1; datosz1; unos1];
    lfs1=1:12;

    % Flecha eje Z
    datosx2=[l1 l1 l2*sqrt(2) 0 -l2*sqrt(2) -l1 -l1];
    datosy2=[l1 l1 l2*sqrt(2) 0 -l2*sqrt(2) -l1 -l1];
    datosz2=[0 l3 l3 l4 l3 l3 0];
    unos2=ones(1,7);
    link2=[datosx2; datosy2; datosz2; unos2];
    lfs2=1:7;

    % Preparar objetos gráficos
    hdl(1) = patch; hdl(2) = patch;
    etiq(1) = text('String','X');
    etiq(2) = text('String','Y');
    etiq(3) = text('String','Z');

    xlabel('Eje X'), ylabel('Eje Y'), zlabel('Eje Z')

    % Recorrer todas las transformaciones
    for k=1:np
        T = TT(:,:,k);
        li1 = T*link1;
        li2 = T*link2;

        % Posiciones de etiquetas
        posletrax = letra*T(1:3,1) + T(1:3,4);
        posletray = letra*T(1:3,2) + T(1:3,4);
        posletraz = letra*T(1:3,3) + T(1:3,4);

        if (nargin==4)
            % Mostrar todos los frames simultáneamente
            set(hdl(1),'faces',lfs1,'vertices',[li1(1,:)' li1(2,:)' li1(3,:)'],'FaceColor',color);
            set(hdl(2),'faces',lfs2,'vertices',[li2(1,:)' li2(2,:)' li2(3,:)'],'FaceColor',color);
            patch('faces',lfs1,'vertices',[li1(1,:)' li1(2,:)' li1(3,:)'],'FaceColor',color);
            patch('faces',lfs2,'vertices',[li2(1,:)' li2(2,:)' li2(3,:)'],'FaceColor',color);
            text('Position',posletrax','String','X');
            text('Position',posletray','String','Y');
            text('Position',posletraz','String','Z');
        else
            % Dibujar de forma secuencial
            set(hdl(1),'faces',lfs1,'vertices',[li1(1,:)' li1(2,:)' li1(3,:)'],'FaceColor',color,'FaceAlpha',1);
            set(hdl(2),'faces',lfs2,'vertices',[li2(1,:)' li2(2,:)' li2(3,:)'],'FaceColor',color,'FaceAlpha',1);
            set(etiq(1),'Position',posletrax');
            set(etiq(2),'Position',posletray');
            set(etiq(3),'Position',posletraz');
        end
    end

    h1 = hdl(1); 
    h2 = hdl(2);
end
