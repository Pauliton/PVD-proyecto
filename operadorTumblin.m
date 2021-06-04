% Implementación del operador de Tumblin y aplicación sobre mapaHDR.

function [resultado] = operadorTumblin(mapaHDR, brillo, saturacion)
    %% P1. Calculamos la luminancia del mapa de radiancia HDR
    %Opcion 1, referencia: https://en.wikipedia.org/wiki/Relative_luminance
    %luminancia = 0.2126*mapaHDR(:,:,1) + 0.7152*mapaHDR(:,:,2) + 0.0722*mapaHDR(:,:,3);
    
    %El resultado no parece demasiado bueno con opcion 1.
    
    %Opcion 2, aprovechamos el espacio de color HSV -> la V es la
    %luminancia
    hsv = rgb2hsv(mapaHDR);
    luminancia = hsv(:, :, 3); %saturacion = hsv(:, :, 2);
    
    %% P2. Cálculo del operador
    %Tomamos un offset para evitar hacer log(0)con pixeles Z = 0
    offset = 0.00001;

    ancho = size(mapaHDR, 2);alto = size(mapaHDR, 1);
    pixeles = ancho*alto;
    key = exp((1/pixeles)*(sum(sum(log(luminancia + offset)))));

    %Escalado al rango de brillo deseado
    luminanciaEscalada = luminancia * (brillo/key);
    operadorTumblin = luminanciaEscalada ./ (luminanciaEscalada + 1);
    resultado = zeros(size(mapaHDR));

    for i=1:3   
        %Uso del operador de Reinhard
        %imagenFinal = mapaHDR/luminancia^saturacion*operadorReinhard
        resultado(:,:,i) = ...
            ((mapaHDR(:,:,i) ./ luminancia) .^ saturacion) .* operadorTumblin;
    end

    idx = resultado > 1;
    resultado(idx) = 1;
end

