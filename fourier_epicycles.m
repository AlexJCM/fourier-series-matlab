% La funci�n "fourier_epicycles" calcula el n�mero necesario de epic�clos
% para dibujar la curva dada, especificada por las coordenadas dadas.
% Estos epic�clos tienen diferentes radios, fases y rotaciones a diferentes
% frecuencias. N�tese que el n�mero de epic�clos ser�a el mismo que
% la longitud de la curva.

% Par�metros de entrada:                                                            %
%  - curve_x:      Coordenadas X de la curva
%  - curve_y:       Coordenadas Y de la curva.                         %
%  - no_circles:   (Opcional) N�mero m�ximo de c�rculos. La m�xima
% precisi�n de dibujo se alcanza si el no_circulos es exactamente el
% n�mero de puntos de la curva (que es el valor por defecto:
%   no_circulos=longitud(curva_x);)

% Ejemplo de uso:                                                       %
% load('heart.mat'); fourier_epicycles(curve_x, curve_y);           %

function fourier_epicycles(curve_x, curve_y, no_circles)
% C�rculos del n�mero predeterminado
if nargin < 3, no_circles = length(curve_x); end
if no_circles > length(curve_x)
    warning(['El n�mero de c�rculos no puede ser mayor que el n�mero de puntos.' ...        
        'El n�mero de c�rculos se ha fijado en: %i.', length(curve_x)]);
    no_circles = length(curve_x);
end

% Reducir la muestra de la curva si es necesario
if no_circles < length(curve_x)
    curve_x = resample(curve_x, no_circles, length(curve_x));
    curve_y = resample(curve_y, no_circles, length(curve_y));
    curve_x = [curve_x(:); curve_x(1)];
    curve_y = [curve_y(:); curve_y(1)];
end

% Parametros
pause_duration = 0;     % No. segundos de pausa entre los plots
periods_to_plot = 1;    % No. per�odos del c�rculo principal hasta que se detenga

% Calcular el DFT del n�mero complejo
Z = complex(curve_x(:), curve_y(:));
[X, freq, radius, phase] = dft_epicycles(Z,length(Z));
time_step = 2*pi/length(X);

% Dubujar el resultado
time = 0;
wave = [];
generation = 1;
h = figure;
handle = axes('Parent',h);
while generation < periods_to_plot*length(X)+2
    [x, y] = draw_epicycles(freq, radius, phase, time, wave, handle);    
    % A�ade el siguiente punto calculado a la curva de la onda
    wave = [wave; [x,y]];    
    % Incremento del tiempo y la generaci�n
    time = time + time_step;
    generation = generation + 1;
    pause(pause_duration);
end
end



%% Funciones secundarias utilizadas por la funcion principal anterior
% Calcula los par�metros DFT (Transformada de Fourier discreta) de un vector
% complejo y proporciona la frecuencia, el radio y la fase de cada uno de los ciclos.
function [X, freq, radius, phase] = dft_epicycles(Z, N)
% DFT (Transformada de Fourier discreta)
X = fft(Z, N)/N;    % DFT  de la serie compleja
freq = 0:1:N-1;     % La frecuencia de los c�rculos
radius = abs(X);    % Los radios de los c�rculos
phase = angle(X);   % Fase inicial de los c�rculos

% Ordenar por radio
[radius, idx] = sort(radius, 'descend');
X = X(idx);
freq = freq(idx);
phase = phase(idx);
end

% Dibuja los epiciclos y la l�nea de resultados en un momento dado
function [x, y] = draw_epicycles(freq, radius, phase, time, wave, handle)
%  Calcular las coordenadas
x = 0;
y = 0;
N = length(freq);
centers = NaN(N,2);
radii_lines = NaN(N,4);
for i = 1:1:N
    % Almacena las coordenadas anteriores, que ser�n el centro del nuevo c�rculo
    prevx = x;
    prevy = y;    
    % Obtener las nuevas coordenadas del punto de uni�n
    x = x + radius(i) * cos(freq(i)*time + phase(i));
    y = y + radius(i) * sin(freq(i)*time + phase(i));    
    % Centros de c�rculos
    centers(i,:) = [prevx, prevy];    
    % L�neas de radio
    radii_lines(i,:) = [prevx, x, prevy, y];
end

% PLOTTEO
cla; % Despejando los axes
% Note that viscircles do not clear the axes and thus, they
% should be cleared in order to avoid lagging issues due to
% the amount of objects that are stacked
% CirCULOS
viscircles(handle, centers, radius, 'Color', 0.5 * [1, 1, 1], 'LineWidth', 0.1);
hold on;
% Las l�neas que unen el centro con los puntos tangentes
plot(handle, radii_lines(:,1:2), radii_lines(:,3:4), 'Color', 0.5*[1 1 1], 'LineWidth', 0.1);
hold on;
% L�nea resultado
if ~isempty(wave), plot(handle, wave(:,1), wave(:,2), 'k', 'LineWidth', 2); hold on; end

% Puntero
plot(handle, x, y, 'or', 'MarkerFaceColor', 'r');
hold off;
% Limites del Plot
%xmax = sum(radius);
%axis([-xmax xmax -xmax xmax]);

axis equal;
axis off;
drawnow;
end