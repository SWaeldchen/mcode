function [y] = SR_dering(x)

% de-ring
x_cos = dct2_eb(x);
y = zeros(size(x));
for m = 1:size(x,1)
    for n = 1:size(x,2)
        pos = sqrt((512-m)^2 + (512-n)^2) * 64 * exp(-(m^2 + n^2) / 96^2) + 80;
        if (abs(x_cos(m,n)) > pos)
            y(m,n) = 0;
        else
            y(m,n) = x_cos(m,n);
        end
    end
end
y = idct2_eb(y);
%{
%recalibrate
medfilt_x = medfilt2(x, [3 3]);
min_x = min(min(medfilt_x));
max_x = max(max(medfilt_x));
medfilt_y = medfilt2(y, [3 3]);
min_y = min(min(medfilt_y));
min_diff = min_x - min_y;
y = y + min_diff;
medfilt_y = medfilt2(y, [3 3]);
max_y = max(max(medfilt_y));
y = y / max_y * max_x;
%}