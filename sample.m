% Función para obtener la versión submuestreada de una imagen RGB en los 
% índices expresados en indicesMuestreo
% Referencia: Konstantinos Monachopoulos, septiembre 2018.
%
% indicesMuestreo expresan los píxeles en un único array.

function [red, green, blue] = sample(imagen, indicesMuestreo)
    %% Leemos cada canal, lo reorganizamos en una columna y muestreamos.
    canalR = imagen(:,:,1);
    canalR = reshape(canalR, [], 1);
    red = canalR(indicesMuestreo);

    canalG = imagen(:,:,2);
    canalG = reshape(canalG, [], 1);
    green = canalG(indicesMuestreo);

    canalB = imagen(:,:,3);
    canalB = reshape(canalB, [], 1);
    blue = canalB(indicesMuestreo);
end