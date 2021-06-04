% Función que parte de las imágenes de un cell array, su exposición
% logarítmica por canal, su tiempo de exposición logarítmico y pesos por
% píxel para calcular el mapa de radiancia HDR.

function [mapa] = mapaRadiancia(cellArrayRecortes, g_R, g_G, g_B, B, w)
    %% Calculamos el número de imágenes en el cell array
    numImagenes = numel(cellArrayRecortes);

    %Preasignamos variables para mayor velocidad
    %el mapa hdr final
    mapa = zeros(size(cellArrayRecortes{1})); 
    %influencia pesada a cada píxel por las imágenes anteriores
    denominador = zeros(size(cellArrayRecortes{1})); 
    
    %% Calculo de la ecuación (6) de Paul E. Debevec y Jitendra Malik
    for j=1:numImagenes
        
        fprintf('Calculando mapa para la imagen %i de %i.\n', j, numImagenes);
        
        %Leemos imagen(j) del cell array
        imagenActual = double(cellArrayRecortes{j});
        
        %Usamos todas las exposiciones disponibles para calcular la radiancia
        wij = w(imagenActual + 1);          %Término: w(Zij)
        denominador = denominador + wij;    %Sumatoria de los w(Zij) en j
        %Término: g(Zij) - log(delta tj) por cada canal
        diferencia(:, :, 1) = (g_R(imagenActual(:, :, 1) + 1) - B(1, j)); 
        diferencia(:, :, 2) = (g_G(imagenActual(:, :, 2) + 1) - B(1, j));
        diferencia(:, :, 3) = (g_B(imagenActual(:, :, 3) + 1) - B(1, j));
        
        %Sumatoria del numerador
        mapa = mapa + (wij .* diferencia);  
    end
    %Realizamos la división
    mapa = mapa./denominador;
    %Deshacemos el logaritmo para devolver Ei
    mapa = exp(mapa);
end