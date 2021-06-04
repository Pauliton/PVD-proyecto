% Función para recortar las imágenes de un cell array en función de los
% valores expresados en recorte = [recorteIzq, recorteSuperior, recorteDch, recorteInferior]

function [cellArrayRecortes] = recorteImagen(cellArrayImagenes, recorte)
    %% Determinar las dimensiones de las imágenes
    numImagenes = numel(cellArrayImagenes);
    ancho = size(cellArrayImagenes{1}, 2);
    alto = size(cellArrayImagenes{1}, 1);

    %Calcular los nuevos límites de las imágenes
    limites = [recorte(1) recorte(2) ancho-recorte(3) alto-recorte(4)];
    %Preasignamos variables para mayor velocidad
    cellArrayRecortes = cell(1, numImagenes);
    for i = 1:numImagenes
        cellArrayRecortes{i} = cellArrayImagenes{i}(limites(2):limites(4)-1,...
            limites(1):limites(3)-1,:...
        );
        %Mostramos el resultado al usuario
        imshow(cellArrayRecortes{i});
    end
end