function [ red, green, blue ] = sample( image, sampleIndices )
    % Takes relevant samples of the input image
    redChannel = image(:,:,1);
    redChannel = reshape(redChannel, [], 1);
    red = redChannel(sampleIndices);

    greenChannel = image(:,:,2);
    greenChannel = reshape(greenChannel, [], 1);
    green = greenChannel(sampleIndices);

    blueChannel = image(:,:,3);
    blueChannel = reshape(blueChannel, [], 1);
    blue = blueChannel(sampleIndices);
end