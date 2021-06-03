function [ cellArrayRecortes ] = recorteImagen(cellArrayImagenes, recorte)
    numImagenes = numel(cellArrayImagenes);
    ancho = size(cellArrayImagenes{1}, 2);
    alto = size(cellArrayImagenes{1}, 1);

    %limites tal que [xinicial, yinicial, ancho, alto]
    limites = [recorte(1) recorte(2) ancho-recorte(3) alto-recorte(4)];

    for i = 1:numImagenes
        cellArrayRecortes{i} = cellArrayImagenes{i}(limites(2):limites(4)-1,...
            limites(1):limites(3)-1,:...
        );
        imshow(cellArrayRecortes{i});
    end
end

