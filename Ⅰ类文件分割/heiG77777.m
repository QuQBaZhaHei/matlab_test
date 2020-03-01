%%
clear;
close all;
clc;

%% 读取图像
img = imread('黑G77777.jpg');
subplot(3,3, 1);
imshow(img);
title('车牌图像');

%% 灰度处理
img1 = rgb2gray(img);    % RGB图像转灰度图像
subplot(3,3,2);
imshow(img1);
title('灰度图像');
subplot(3,3,3);
imhist(img1);
title('灰度处理后的灰度直方图');

%% 边缘提取
img4 = edge(img1, 'roberts', 0.15, 'both');
subplot(3,3,4);
imshow(img4);
title('roberts算子边缘检测');

%% 平滑图像，图像膨胀
se = strel('rectangle', [50,30]);
img5 = imclose(img4, se);
subplot(3,3,5);
imshow(img5);
title('平滑图像的轮廓');

%% 从图像中删除所有少于2200像素8邻接
img6 = bwareaopen(img5, 2200);
subplot(3,3,6);
imshow(img6);
title('从图像中移除小对象');

%% 切割出图像
[y, x, z] = size(img6);
img7 = double(img6);    % 转成双精度浮点型

% 车牌的蓝色区域
% Y方向
blue_Y = zeros(y, 1);
for i = 1:y
    for j = 1:x
        if(img7(i, j) == 1) % 判断车牌位置区域
            blue_Y(i, 1) = blue_Y(i, 1) + 1;    % 像素点统计
        end
    end
end

% 找到Y坐标的最小值
img_Y1 = 1;
while (blue_Y(img_Y1) < 5) && (img_Y1 < y)
    img_Y1 = img_Y1 + 1;
end

% 找到Y坐标的最大值
img_Y2 = y;
while (blue_Y(img_Y2) < 5) && (img_Y2 > img_Y1)
    img_Y2 = img_Y2 - 1;
end

% x方向
blue_X = zeros(1, x);
for j = 1:x
    for i = 1:y
        if(img7(i, j) == 1) % 判断车牌位置区域
            blue_X(1, j) = blue_X(1, j) + 1;
        end
    end
end

% 找到x坐标的最小值
img_X1 = 1;
while (blue_X(1, img_X1) < 5) && (img_X1 < x)
    img_X1 = img_X1 + 1;
end

% 找到x坐标的最小值
img_X2 = x;
while (blue_X(1, img_X2) < 5) && (img_X2 > img_X1)
    img_X2 = img_X2 - 1;
end

% 对图像进行裁剪
img8 = img(img_Y1:img_Y2, img_X1:img_X2, :);
subplot(3,3,7);
imshow(img8);
title('定位剪切后的彩色车牌图像')

% 保存提取出来的车牌图像
imwrite(img8, '车牌图像.jpg');

%% 对车牌图像作图像预处理
plate_img = imread('车牌图像.jpg');
plate_img=img8;

% 转换成灰度图像
plate_img1 = rgb2gray(plate_img);    % RGB图像转灰度图像
figure;
subplot(3, 3, 1);
imshow(plate_img1);
title('灰度图像');
subplot(3, 3, 2);
imhist(plate_img1);
title('灰度处理后的灰度直方图');

%将图像锐化
Ig2=double(plate_img1);
w=fspecial('laplacian',0);
g1=imfilter(plate_img1,w,'replicate');
plate_img1=plate_img1-3*g1;
subplot(3,3,3);
imshow(plate_img1);
title('锐化图');


% 直方图均衡化
plate_img2 = histeq(plate_img1);
subplot(3,3,4);
imshow(plate_img2);
title('直方图均衡化的图像');
subplot(3,3,5);
imhist(plate_img2);
title('直方图');

%除去椒盐噪声
plate_img2 = medfilt2(plate_img2);
subplot(3,3,6);
imshow(plate_img2);
title('除去椒盐噪声');

% 二值化处理
plate_img3 = im2bw(plate_img2, 0.7);
subplot(3,3,7);
imshow(plate_img3);
title('车牌二值图像');

% % 中值滤波
% plate_img4 = medfilt2(plate_img3);
% subplot(3,3,8);
% imshow(plate_img4);
% title('中值滤波后的图像');

%% 进行字符分割
plate_img5 = my_imsplit(plate_img3);
[m, n] = size(plate_img5);

s = sum(plate_img5);    %sum(x)就是竖向相加，求每列的和，结果是行向量;
j = 1;
k1 = 1;
k2 = 1;
while j ~= n
    while s(j) == 0
        j = j + 1;
    end
    k1 = j;
    while s(j) ~= 0 && j <= n-1
        j = j + 1;
    end
    k2 = j + 1;
    if k2 - k1 > round(n /7)
        [val, num] = min(sum(plate_img5(:, [k1+5:k2-5])));
        plate_img5(:, k1+num+5) = 0;
    end
end


y1 = 0;
y2 = 0.25;
flag = 0;
word1 = [];
while flag == 0
    [m, n] = size(plate_img5);
    [x, y] = size(plate_img5);
    left = 1;
    width = 0;
    while sum(plate_img5(:, width+1)) ~= 0
        width = width + 1;
    end
    if width < y1
        plate_img5(:,[1:width]) = 0;
        plate_img5 = my_imsplit(plate_img5);
    else
        temp = my_imsplit(imcrop(plate_img5, [0,1,width+2,m]));
        [m, n] = size(temp);
        all = sum(sum(temp));
        two_thirds=sum(sum(temp([round(m/3):2*round(m/3)],:)));
        if two_thirds/all > y2
            flag = 1;
            word1 = temp;
        end
        plate_img5(:, [1:1]) = 0;
        plate_img6 = my_imsplit(imcrop(plate_img5, [width+3,1,n,m]));
        plate_img5 = my_imsplit(imcrop(plate_img5, [3*width,1,y-3*width+3,x]));
    end
end

 % 分割出第二个字符
 [word2,plate_img6]=getword(plate_img6);
 % 分割出第三个字符
 [word3,plate_img5]=getword(plate_img5);
 % 分割出第四个字符
 [word4,plate_img5]=getword(plate_img5);
 % 分割出第五个字符
 [word5,plate_img5]=getword(plate_img5);
 % 分割出第六个字符
 [word6,plate_img5]=getword(plate_img5);

 % 分割出第七个字符
 [word7,plate_img5]=getword(plate_img5);

 figure;
 subplot(5,7,1),imshow(word1),title('1');
 subplot(5,7,2),imshow(word2),title('2');
 subplot(5,7,3),imshow(word3),title('3');
 subplot(5,7,4),imshow(word4),title('4');
 subplot(5,7,5),imshow(word5),title('5');
 subplot(5,7,6),imshow(word6),title('6');
 subplot(5,7,7),imshow(word7),title('7');

 word1=imresize(word1,[40 20]);%imresize对图像做缩放处理，常用调用格式为：B=imresize(A,ntimes,method)；其中method可选nearest,bilinear（双线性）,bicubic,box,lanczors2,lanczors3等
 word2=imresize(word2,[40 20]);
 word3=imresize(word3,[40 20]);
 word4=imresize(word4,[40 20]);
 word5=imresize(word5,[40 20]);
 word6=imresize(word6,[40 20]);
 word7=imresize(word7,[40 20]);
 
 imwrite(word1,'1.jpg'); % 创建七位车牌字符图像
 imwrite(word2,'2.jpg');
 imwrite(word3,'3.jpg');
 imwrite(word4,'4.jpg');
 imwrite(word5,'5.jpg');
 imwrite(word6,'6.jpg');
 imwrite(word7,'7.jpg');