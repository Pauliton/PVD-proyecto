%% Limpieza
close all; clear; clc;
%warning('off');

%% P0. Seleccion de archivos
opcion = 1;                 %-----------Variable a controlar POR EL USUARIO

switch opcion
    case 1
        path = 'memorial/memorial00%d.png';
        iminit = 61;
        imfinal = 76;
        numImagenes = imfinal-iminit+1;
        tiempoExposicion = zeros(1, numImagenes);
        for i = 0:numImagenes-1
            tiempoExposicion(i+1) = log(32/(2^i));
        end
    case 2
        %Con este caso no ejecutar P1
        path = 'memorial_reducido/memorial00%d.png';
        im = [62 66 69];
        numImagenes = 3;
        tiempoExposicion = log([16 1 1/8]);
        cellArrayImagenes = cell(1, numImagenes);
        for i = 1:numImagenes
            cellArrayImagenes{i} = im2uint8(imread(sprintf(path, im(i))));
            imshow(cellArrayImagenes{i});
        end
    otherwise
        path = 'propias/IMG_0%d_hori.png';
        iminit = 1;
        imfinal = 3;
        numImagenes = imfinal-iminit+1;
        tiempoExposicion = log([1/8 1 8]);
end

%% P1. Lectura de archivos
fprintf('Leyendo archivos con ruta local: %s\n', path);

%Preasignamos variables para mayor velocidad
cellArrayImagenes = cell(1, numImagenes);
for i = 1:numImagenes
    cellArrayImagenes{i} = im2uint8(imread(sprintf(path, i+iminit-1)));
    imshow(cellArrayImagenes{i});
end

%% P2. Preprocesado
fprintf('Recortando los archivos.\n');

%Recorte tal que [recorteIzq, recorteSuperior, recorteDch, recorteInferior]
if opcion == 1 || opcion == 2
    recorte = [3 35 8 20]; %valor de píxeles a recortar
else
    recorte = [1 1 1 1];   %valor de píxeles a recortar
end
cellArrayRecortes = recorteImagen(cellArrayImagenes, recorte);

%% P3. Forma matricial
%Matriz RGB con filas = los píxeles de cada imagen leída PERO MUESTREADA!
%Referencia para muestreo: Konstantinos Monachopoulos, septiembre 2018.
fprintf('Muestreando las imágenes.\n');

%1. Determinamos el número de píxeles
ancho = size(cellArrayRecortes{1}, 2);alto = size(cellArrayRecortes{1}, 1);
pixeles = ancho*alto;

%2. Calculamos qué píxeles muestrear
muestras = ceil(255*2 / (numImagenes - 1)) * 2;
step = pixeles / muestras;
indicesMuestreo = floor((1:step:pixeles));
indicesMuestreo = indicesMuestreo';

%3. Preasignamos variables para mayor velocidad
matrizR = zeros(muestras, numImagenes);
matrizG = zeros(muestras, numImagenes);
matrizB = zeros(muestras, numImagenes);

%4. Muestreamos
for i=1:numImagenes
    %Muestreo por cada canal RGB
    [matrizRtemporal, matrizGtemporal, matrizBtemporal] = sample(...
        cellArrayRecortes{i}, indicesMuestreo);
    %Imagen con muestras
    matrizR(:,i) = matrizRtemporal;
    matrizG(:,i) = matrizGtemporal;
    matrizB(:,i) = matrizBtemporal;
end

%% P4. Resolver sistema lineal
%1. Calculamos la matriz 'log delta t' para cada imagen
B = zeros(ancho*alto, numImagenes);
for i = 1:numImagenes
    B(:,i) = tiempoExposicion(i);
end

%2. Factor de suavizado
lambda = 25; %25

%3. Funcion de pesos para cada valor de pixel
pesos = zeros(1, 256);
for i=1:256
    pesos(i) = weight(i, 1, 256);
end

%4. Resolvemos el sistema con gsolve.m
fprintf('Calculando el primer sistema lineal.\n');
[g_R, radiancia_R] = gsolve(matrizR, B, lambda, pesos);
fprintf('Calculando el segundo sistema lineal.\n');
[g_G, radiancia_G] = gsolve(matrizG, B, lambda, pesos);
fprintf('Calculando el tercer sistema lineal.\n');
[g_B, radiancia_B] = gsolve(matrizB, B, lambda, pesos);

%% P5. Mostrar las curvas de respuesta
figure; 
    title('Función de respuesta RGB');
subplot(2, 2, 1); plot(g_R, 0:255, 'r'); 
    xlabel('Valor de la exposición logarítmica'); ylabel('Valor de píxel Z');
    title('Función de respuesta R'); ylim([0 255]);
subplot(2, 2, 2); plot(g_G, 0:255, 'g');
    xlabel('Valor de la exposición logarítmica'); ylabel('Valor de píxel Z');
    title('Función de respuesta G'); ylim([0 255]);
subplot(2, 2, 3); plot(g_B, 0:255, 'b'); ylim([0 255]);
    xlabel('Valor de la exposición logarítmica'); ylabel('Valor de píxel Z');
    title('Función de respuesta B'); ylim([0 255]);
subplot(2, 2, 4); plot(g_R, 0:255, 'r', g_G, 0:255, 'g', g_B, 0:255, 'b');
xlabel('Valor de la exposición logarítmica'); ylabel('Valor de píxel Z');
    title('Funciones de respuesta RGB'); ylim([0 255]);

%% P6. Cálculo del mapa de radiancia
fprintf('Calculamos el mapa de radiancia.\n')

miMapa = mapaRadiancia(cellArrayRecortes, g_R, g_G, g_B, B, pesos);
figure; imshow(miMapa);
    title('Mapa de radiancia HDR');
truesize

%% P7. Tone mapping
fprintf('Ajustamos el color.\n')

%Especificamos brillo y saturación final
%para bóveda: brillo = 1; saturación = 0.5;
brillo = 1; saturacion = 0.5;
resultadoTumblin = operadorTumblin(miMapa, brillo, saturacion);
resultadoReinhard = operadorReinhard(miMapa, brillo, saturacion);

figure;
subplot(1, 2, 1); imshow(resultadoTumblin);
    title('Imagen con operador de Tumblin');

subplot(1, 2, 2); imshow(resultadoReinhard);
    title('Imagen con operador global de Reinhard');
truesize
