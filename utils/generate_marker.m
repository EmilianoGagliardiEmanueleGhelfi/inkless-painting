scale = 2;
global color;
color = [0, 0.57, 0.843];
out_name = '/home/emiliano/Desktop/green.jpg';
im = ones(297*scale, 210*scale, 3);
for i = 0:2
    im = makepattern(im, [10 + 60*i*scale, 10*scale], 1, 1, 5*scale, 20*scale);
    im = makepattern(im, [10 + 80*i*scale, 30*scale], 1, 1, 5*scale, 30*scale);
    im = makepattern(im, [10 + 95*i*scale, 50*scale], 1, 1, 5*scale, 35*scale);
end

figure, imshow(im);
imwrite(im, out_name);


function im = makepattern(im, from, hw, vw, vd, hd)
    global color;
    h = hw * 2 + hd * 2;
    for r = from(1) - 5 : from(1) + h + 5
        for line_width = 1:vw
            im(r, from(2) + line_width - 1, 1) = color(1);
            im(r, from(2) + vw + vd + line_width - 1, 1) = color(1);
            im(r, from(2) + line_width - 1, 2) = color(2);
            im(r, from(2) + vw + vd + line_width - 1, 2) = color(2);
            im(r, from(2) + line_width - 1, 3) = color(3);
            im(r, from(2) + vw + vd + line_width - 1, 3) = color(3);
        end
    end
    w = vw + vd;
    for c = from(2) - 5 : from(2) + w + 5
        for line_width = 1:hw
            im(from(1) + line_width - 1, c, 1) = color(1);
            im(from(1) + hw + hd + line_width -1, c, 1) = color(1);
            im(from(1) + 2*hw + 2*hd + line_width -1, c, 1) = color(1);
            im(from(1) + line_width - 1, c, 2) = color(2);
            im(from(1) + hw + hd + line_width -1, c, 2) = color(2);
            im(from(1) + 2*hw + 2*hd + line_width -1, c, 2) = color(2);
            im(from(1) + line_width - 1, c, 3) = color(3);
            im(from(1) + hw + hd + line_width -1, c, 3) = color(3);
            im(from(1) + 2*hw + 2*hd + line_width -1, c, 3) = color(3);
        end
    end
end



