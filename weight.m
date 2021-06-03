% Funcion peso 
function w = weight(z, zmin, zmax)
    if z <= 1/2 * (zmin + zmax)
        w = ((z - zmin) + 1);
    else
        w = ((zmax - z) + 1);
    end
 end
