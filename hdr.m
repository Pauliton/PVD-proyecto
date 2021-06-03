% Generates a hdr radiance map from a set of pictures
function [ hdr ] = hdr( cellArrayRecortes, gRed, gGreen, gBlue, w, dt )
    numExposures = size(cellArrayRecortes,2);

    % pre-allocate resulting hdr image
    hdr = zeros(size(cellArrayRecortes{1}));
    sum = zeros(size(cellArrayRecortes{1}));

    for i=1:numExposures
        fprintf('Adding picture %i of %i \n', i, numExposures);
        image = double(cellArrayRecortes{i});

        wij = w(image + 1);
        sum = sum + wij;

        m(:,:,1) = (gRed(image(:,:,1) + 1) - dt(1,i));
        m(:,:,2) = (gGreen(image(:,:,2) + 1) - dt(1,i));
        m(:,:,3) = (gBlue(image(:,:,3) + 1) - dt(1,i));

        saturatedPixels = ones(size(image));

        saturatedPixelsRed = find(image(:,:,1) == 255);
        saturatedPixelsGreen = find(image(:,:,2) == 255);
        saturatedPixelsBlue = find(image(:,:,3) == 255);

        % Mark the saturated pixels from a certain channel in *all three*
        % channels
        dim = size(image,1) * size(image,2);
        saturatedPixels(saturatedPixelsRed) = 0;
        saturatedPixels(saturatedPixelsRed + dim) = 0;
        saturatedPixels(saturatedPixelsRed + 2*dim) = 0;

        saturatedPixels(saturatedPixelsGreen) = 0;
        saturatedPixels(saturatedPixelsGreen + dim) = 0;
        saturatedPixels(saturatedPixelsGreen + 2*dim) = 0;

        saturatedPixels(saturatedPixelsBlue) = 0;
        saturatedPixels(saturatedPixelsBlue + dim) = 0;
        saturatedPixels(saturatedPixelsBlue + 2*dim) = 0;

        hdr = hdr + (wij .* m);
        hdr = hdr .* saturatedPixels;
        sum = sum .* saturatedPixels;
    end

    saturatedPixelIndices = find(hdr == 0);
    hdr(saturatedPixelIndices) = m(saturatedPixelIndices);
    sum(saturatedPixelIndices) = 1;

    % normalize
    hdr = hdr ./ sum;
    hdr = exp(hdr);
end