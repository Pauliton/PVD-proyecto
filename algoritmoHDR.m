%% Limpieza
close all; clear; clc;
%warning('off');

%% P0. Seleccion de archivos
%--------Opcion 1 para archivos de /memorial, else para /personal----------
opcion = 1;
switch opcion
    case 1
        path = 'memorial/memorial00%d.png';
        iminit = 61;
        imfinal = 76;
        numImagenes = imfinal-iminit+1;
        tiempoExposicion = zeros(1, 16);
        for i = 0:numImagenes-1
            tiempoExposicion(i+1) = log(32/(2^i));
        end
    case 2
        %Con este caso no ejecutar P1
        path = 'memorial_reducido/memorial00%d.png';
        im = [62 66 69];
        numImagenes = 3;
        tiempoExposicion = log([16 1 1/8]);
        for i = 1:numImagenes
            cellArrayImagenes{i} = im2uint8(imread(sprintf(path, im(i))));
            imshow(cellArrayImagenes{i});
        end
    otherwise
        fprintf('Aquí hay que poner la carpeta personal.\n');
end

%% P1. Lectura de archivos
fprintf('Leyendo archivos con ruta local: %s\n', path);

for i = 1:numImagenes
    cellArrayImagenes{i} = im2uint8(imread(sprintf(path, i+iminit-1)));
    imshow(cellArrayImagenes{i});
end

%% P2. Preprocesado
fprintf('Recortando los archivos.\n');

%recorte tal que [recorteIzq, recorteSuperior, recorteDch, recorteInferior]
recorte = [3 35 8 20]; %valor de píxeles a recortar
cellArrayRecortes = recorteImagen(cellArrayImagenes, recorte);

%% P3. Forma matricial
%Matriz RGB con filas = los píxeles de cada imagen leída PERO MUESTREADA!
ancho = size(cellArrayRecortes{1}, 2);
alto = size(cellArrayRecortes{1}, 1);
numSamples = ceil(255*2 / (numImagenes - 1)) * 2;
step = ancho*alto / numSamples;
sampleIndices = floor((1:step:ancho*alto));
sampleIndices = sampleIndices';

matrizR = zeros(numSamples, numImagenes);
matrizG = zeros(numSamples, numImagenes);
matrizB = zeros(numSamples, numImagenes);

for i=1:numImagenes
    %muestreo por cada canal RGB
    [matrizRtemporal, matrizGtemporal, matrizBtemporal] = sample(...
        cellArrayRecortes{i}, sampleIndices);
    %imagen con muestras
    matrizR(:,i) = matrizRtemporal;
    matrizG(:,i) = matrizGtemporal;
    matrizB(:,i) = matrizBtemporal;
end

%% P4. Resolver sistema lineal
%log delta t para cada imagen
B = zeros(ancho*alto, numImagenes);
for i = 1:numImagenes
    B(:,i) = tiempoExposicion(i);
end

%Factor de suavizado
smoothing = 50;

%Funcion de pesos para cada valor de pixel
w = zeros(1, 256);
for i=1:256
    w(i) = weight(i, 1, 256);
end

fprintf('Calculando el primer sistema lineal.\n');
[g_R, lE_R] = gsolve(matrizR, B, smoothing, w);
fprintf('Calculando el segundo sistema lineal.\n');
[g_G, lE_G] = gsolve(matrizG, B, smoothing, w);
fprintf('Calculando el tercer sistema lineal.\n');
[g_B, lE_B] = gsolve(matrizB, B, smoothing, w);

%% P5. Mostrar las curvas de respuesta
figure; 
    title('Función de respuesta RGB');
subplot(2, 2, 1); plot(g_R, 0:255, 'r'); 
    title('Función de respuesta R'); ylim([0 255]);
subplot(2, 2, 2); plot(g_G, 0:255, 'g'); 
    title('Función de respuesta G'); ylim([0 255]);
subplot(2, 2, 3); plot(g_B, 0:255, 'b'); ylim([0 255]);
    title('Función de respuesta B'); ylim([0 255]);
subplot(2, 2, 4); plot(g_R, 0:255, 'r', g_G, 0:255, 'g', g_B, 0:255, 'b');
    title('Funciones de respuesta RGB'); ylim([0 255]);

%% P6. Cálculo del mapa de radiancia
fprintf('Computing hdr image\n')
hdrMap = hdr(cellArrayRecortes, g_R, g_G, g_B, w, B);

figure, imshow(hdrMap);
    title('Irradiance HDR map');
