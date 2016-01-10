function [AC,DC] = read_acdc_image(filepath, ACSZ)
        img = imread(filepath);
        [h,w] = size(img);
        id = 1;
        AC = zeros(size(1:2:(h-3),2)*size(1:2:(w-3),2), ACSZ);
        DC = zeros(1, size(1:2:(h-3),2)*size(1:2:(w-3),2));
        for i= 1:2:(h-3)
            for j= 1:2:(w-3)
                b = img(i:(i+3),j:(j+3));
                tmp = reshape(dct2(b)', 1, []);
                AC(id, :) = tmp(2:size(tmp,2));
                DC(id) = tmp(1);
                id = id + 1;
            end
        end
end