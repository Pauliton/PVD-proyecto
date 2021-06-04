% Funci�n que parte de las im�genes de un cell array, su exposici�n
% logar�tmica por canal, su tiempo de exposici�n logar�tmico y pesos por
% p�xel para calcular el mapa de radiancia HDR.

function [mapa] = mapaRadiancia(cellArrayRecortes, g_R, g_G, g_B, B, w)
    %% Calculamos el n�mero de im�genes en el cell array
    numImagenes = numel(cellArrayRecortes);

    %Preasignamos variables para mayor velocidad
    %el mapa hdr final
    mapa = zeros(size(cellArrayRecortes{1})); 
    %influencia pesada a cada p�xel por las im�genes anteriores
    denominador = zeros(size(cellArrayRecortes{1})); 
    
    %% Calculo de la ecuaci�n (6) de Paul E. Debevec y Jitendra Malik
    for j=1:numImagenes
        
        fprintf('Calculando mapa para la imagen %i de %i.\n', j, numImagenes);
        
        %Leemos imagen(j) del cell array
        imagenActual = double(cellArrayRecortes{j});
        
        %Usamos todas las exposiciones disponibles para calcular la radiancia
        wij = w(imagenActual + 1);          %T�rmino: w(Zij)
        denominador = denominador + wij;    %Sumatoria de los w(Zij) en j
        %T�rmino: g(Zij) - log(delta tj) por cada canal
        diferencia(:, :, 1) = (g_R(imagenActual(:, :, 1) + 1) - B(1, j)); 
        diferencia(:, :, 2) = (g_G(imagenActual(:, :, 2) + 1) - B(1, j));
        diferencia(:, :, 3) = (g_B(imagenActual(:, :, 3) + 1) - B(1, j));
        
        %Sumatoria del numerador
        mapa = mapa + (wij .* diferencia);  
    end
    %Realizamos la divisi�n
    mapa = mapa./denominador;
    %Deshacemos el logaritmo para devolver Ei
    mapa = exp(mapa);
end