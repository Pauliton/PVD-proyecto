% Implementación del operador de Reinhard y aplicación sobre mapaHDR.
% Referencia: Reinhard et al., Photographic Tone Reproduction for Digital Images

% brillo <-> parámetro 'a'

function [resultado] = operadorReinhard(mapaHDR, brillo, saturacion)
    %% P1. Calculamos la luminancia 'Lw(x,y)' del mapa de radiancia HDR
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
    %Y computamos el número total de píxeles en la imagen
    ancho = size(mapaHDR, 2);alto = size(mapaHDR, 1);
    pixeles = ancho*alto;
    %Tumblin toma como aproximacion una luminancia logaritmica      (ec. 1)
    luminanciaKey = exp((1/pixeles)*sum(sum(log(offset + luminancia))));

    %Escalado al rango de brillo deseado
    operadorTumblin = (brillo/luminanciaKey)*luminancia;           %(ec. 2)
    %operadorReinhard = operadorTumblin ./ (1+ operadorTumblin);   %(ec. 3)
    %(ec. 4), ofrece una ligera mejora de contraste
    operadorReinhard = (operadorTumblin.*(1 + operadorTumblin./max(operadorTumblin(:))^2))...
        ./ (1 + operadorTumblin);                                  %(ec. 4)

    %% P3. Aplicación del operador: resultado = mapaHDR * operador
    resultado = ((mapaHDR./ luminancia).^ saturacion).*operadorReinhard;

    %Los valores superiores a 1 los limitamos a 1
    indicesQuemados = resultado > 1; %es lo mismo que find(resultado>1)
    resultado(indicesQuemados) = 1;
end
