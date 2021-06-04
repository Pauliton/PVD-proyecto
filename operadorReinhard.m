% Implementación del operador global de Reinhard y aplicación sobre mapaHDR.

function [resultado] = operadorReinhard(mapaHDR, brillo, saturacion)
    %% P1. Calculamos la luminancia del mapa de radiancia HDR
    %Opcion 1, referencia: https://en.wikipedia.org/wiki/Relative_luminance
    %luminancia = 0.2126*mapaHDR(:,:,1) + 0.7152*mapaHDR(:,:,2) + 0.0722*mapaHDR(:,:,3);
    
    %El resultado no parece demasiado bueno con opcion 1.
    
    %Opcion 2, aprovechamos el espacio de color HSV -> la V es la
    %luminancia
    hsv = rgb2hsv(mapaHDR);
    luminancia = hsv(:, :, 3); %saturacion = hsv(:, :, 2);
    
    %% P2. Cálculo del operador
    %Tomamos un margen d para evitar hacer log(0)con pixeles Z = 0
    d = 0.00001;

    ancho = size(mapaHDR, 2);alto = size(mapaHDR, 1);
    pixeles = ancho*alto;
    key = exp((1/pixeles)*(sum(sum(log(luminancia + d)))));

    %Escalado al rango de brillo deseado
    luminanciaEscalada = luminancia * (brillo/key);
    luminanciaReinhard = luminanciaEscalada ./ (luminanciaEscalada + 1);
    resultado = zeros(size(mapaHDR));

    for i=1:3   
        %Uso del operador de Reinhard
        resultado(:,:,i) = ...
            ((mapaHDR(:,:,i) ./ luminancia) .^ saturacion) .* luminanciaReinhard;
    end

    idx = resultado > 1;
    resultado(idx) = 1;
end

