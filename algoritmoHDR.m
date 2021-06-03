%% Limpieza
close all; clear; clc;
%warning('off');

%% P0. Seleccion de archivos
%--------Opcion 1 para archivos de /memorial, else para /personal----------
opcion = 1;
if opcion == 1
    path = 'memorial/memorial00%d.png';
    iminit = 61;
    imfinal = 76;
    numImagenes = imfinal-iminit+1;
    velocDisparo = zeros(1, 16);
    for i = 0:numImagenes-1
        velocDisparo(i+1) = log(1/32*2^i);
    end
% else
%     personal = '';
%     iminit = ;
%     imfinal = ;
%     numImagenes = imfinal-iminit+1;
end

%% P0-P1. Custom 
%-----Ejecutar en lugar de P0 y P1 para limitarnos a 3 imagenes, y no 16---
path = 'memorial/memorial00%d.png';
im = [62 66 69];
numImagenes = 3;
velocDisparo = log([1/16 1 8]);

for i = 1:numImagenes
    cellArrayImagenes{i} = im2uint8(imread(sprintf(path, im(i))));
    imshow(cellArrayImagenes{i});
end

%% P1. Lectura de archivos
fprintf('Leyendo archivos con ruta local: %s\n', path);

for i = 1:numImagenes
    cellArrayImagenes{i} = im2uint8(imread(sprintf(path, i+iminit-1)));
    imshow(cellArrayImagenes{i});
end

%% P2. Preprocesado
fprintf('Recortando los archivos.\n');
ancho = size(cellArrayImagenes{1}, 2);
alto = size(cellArrayImagenes{1}, 1);

%recorte tal que [recorteIzq, recorteSuperior, recorteDch, recorteInferior]
recorte = [3 35 8 20]; %valor de píxeles a recortar

%limites tal que [xinicial, yinicial, ancho, alto]
limites = [recorte(1) recorte(2) ancho-recorte(3) alto-recorte(4)];

for i = 1:numImagenes
    cellArrayRecortes{i} = cellArrayImagenes{i}(limites(2):limites(4)-1,...
                                  limites(1):limites(3)-1,:...
                                  );
    imshow(cellArrayRecortes{i});
end

%% P3. Forma matricial
%Matriz RGB con filas = los píxeles de cada imagen leída
ancho = size(cellArrayRecortes{1}, 2);
alto = size(cellArrayRecortes{1}, 1);
matriz = zeros(ancho*alto, numImagenes, 3);

for i = 1:numImagenes
    matriz(:, i, 1) = reshape(cellArrayRecortes{i}(:, :, 1), [], 1);
    matriz(:, i, 2) = reshape(cellArrayRecortes{i}(:, :, 2), [], 1);
    matriz(:, i, 3) = reshape(cellArrayRecortes{i}(:, :, 3), [], 1);
end

%% P4. Resolver sistema lineal
w = [0:127 127:-1:0];
[g_R, lE_R] = gsolve(matriz(:, :, 1), velocDisparo, 0, w);
[g_G, lE_G] = gsolve(matriz(:, :, 2), velocDisparo, 0, w);
[g_B, lE_B] = gsolve(matriz(:, :, 3), velocDisparo, 0, w);






