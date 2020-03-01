%%
clc;
clear;
close all;


%% 自动弹出提示框读取图像

% [FileName,PathName,FilterIndex] = uigetfile(FilterSpec,DialogTitle,DefaultName)
% FileName：返回的文件名
% PathName：返回的文件的路径名
% FilterIndex：选择的文件类型
% FilterSpec：文件类型设置
% DialogTitle：打开对话框的标题
% DefaultName：默认指向的文件名
[filename filepath] = uigetfile('.jpg', '输入一个需要识别出车牌的图像');   %自动读入图像

file = strcat(filepath, filename);   %strcat函数：连接字符串；把filepath的字符串与filename的连接，即路径/文件名
img = imread(file);
figure;
imshow(img);
title('车牌图像');

%% 灰度处理
img1 = rgb2gray(img);    % RGB图像转灰度图像
figure;
subplot(1, 2, 1);
imshow(img1);
title('灰度图像');
subplot(1, 2, 2);
imhist(img1);
title('灰度处理后的灰度直方图');

%% 直方图均衡化
img2 = histeq(img1);    %直方图均衡化
figure;
subplot(1, 2, 1);
imshow(img2);
title('灰度图像');
subplot(1, 2, 2);
imhist(img2);
title('灰度处理后的灰度直方图');

%% 中值滤波
img3 = medfilt2(img2);
figure;
imshow(img3);
title('中值滤波');

%% 边缘提取
% img4 = edge(img3, 'roberts', 0.15, 'both');
% figure('name','边缘检测');
% imshow(img4);
% title('roberts算子边缘检测');

img4 = edge(img3, 'sobel', 0.2);
figure('name','边缘检测');
imshow(img4);
title('sobel算子边缘检测');

%% 图像腐蚀
se=[1;1;1];
img5 = imerode(img4, se);
figure('name','图像腐蚀');
imshow(img5);
title('图像腐蚀后的图像');

%% 平滑图像，图像膨胀
se = strel('rectangle', [20, 20]);
img6 = imclose(img5, se);
figure('name','平滑处理');
imshow(img6);
title('平滑图像的轮廓');

%% 从图像中删除所有少于1000像素8邻接
img7 = bwareaopen(img6, 1000);
figure('name', '移除小对象');
imshow(img7);
title('从图像中移除小对象');

%% 切割出图像
[y, x, z] = size(img7);
img8 = double(img7);    % 转成双精度浮点型

% 车牌的蓝色区域
% Y方向
blue_Y = zeros(y, 1);
for i = 1:y
    for j = 1:x
        if(img8(i, j) == 1) % 判断车牌位置区域
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
        if(img8(i, j) == 1) % 判断车牌位置区域
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
img9 = img(img_Y1:img_Y2, img_X1:img_X2, :);
figure('name', '定位剪切图像');
imshow(img9);
title('定位剪切后的彩色车牌图像')

% 保存提取出来的车牌图像
imwrite(img9, '车牌图像.jpg');

%% 对车牌图像作图像预处理
plate_img = imread('车牌图像.jpg');

% 转换成灰度图像
plate_img1 = rgb2gray(plate_img);    % RGB图像转灰度图像
figure;
subplot(1, 2, 1);
imshow(plate_img1);
title('灰度图像');
subplot(1, 2, 2);
imhist(plate_img1);
title('灰度处理后的灰度直方图');

% 直方图均衡化
plate_img2 = histeq(plate_img1);
figure('name', '直方图均衡化');
subplot(1,2,1);
imshow(plate_img2);
title('直方图均衡化的图像');
subplot(1,2,2);
imhist(plate_img2);
title('直方图');

% 二值化处理
plate_img3 = im2bw(plate_img2, 0.76);
figure('name', '二值化处理');
imshow(plate_img3);
title('车牌二值图像');

% 中值滤波
plate_img4 = medfilt2(plate_img3);
figure('name', '中值滤波');
imshow(plate_img4);
title('中值滤波后的图像');

%% 进行字符识别
plate_img5 = my_imsplit(plate_img4);
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
    if k2 - k1 > round(n / 6.5)
        [val, num] = min(sum(plate_img5(:, [k1+5:k2-5])));
        plate_img5(:, k1+num+5) = 0;
    end
end

y1 = 10;
y2 = 0.25;
flag = 0;
word1 = [];
while flag == 0
    [m, n] = size(plate_img5);
    left = 1;
    width = 0;
    while sum(plate_img5(:, width+1)) ~= 0
        width = width + 1;
    end
    if width < y1
        plate_img5(:, [1:width]) = 0;
        plate_img5 = my_imsplit(plate_img5);
    else
        temp = my_imsplit(imcrop(plate_img5, [1,1,width,m]));
        [m, n] = size(temp);
        all = sum(sum(temp));
        two_thirds=sum(sum(temp([round(m/3):2*round(m/3)],:)));
        if two_thirds/all > y2
            flag = 1;
            word1 = temp;
        end
        plate_img5(:, [1:width]) = 0;
        plate_img5 = my_imsplit(plate_img5);
    end
end

figure;
subplot(2,4,1), imshow(plate_img5);

 % 分割出第二个字符
 [word2,plate_img5]=getword(plate_img5);
 subplot(2,4,2), imshow(plate_img5);
 % 分割出第三个字符
 [word3,plate_img5]=getword(plate_img5);
 subplot(2,4,3), imshow(plate_img5);
 % 分割出第四个字符
 [word4,plate_img5]=getword(plate_img5);
 subplot(2,4,4), imshow(plate_img5);
 % 分割出第五个字符
 [word5,plate_img5]=getword(plate_img5);
 subplot(2,3,4), imshow(plate_img5);
 % 分割出第六个字符
 [word6,plate_img5]=getword(plate_img5);
 subplot(2,3,5), imshow(plate_img5);
 % 分割出第七个字符
 [word7,plate_img5]=getword(plate_img5);
 subplot(2,3,6), imshow(plate_img5);

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

 subplot(5,7,15),imshow(word1),title('11');
 subplot(5,7,16),imshow(word2),title('22');
 subplot(5,7,17),imshow(word3),title('33');
 subplot(5,7,18),imshow(word4),title('44');
 subplot(5,7,19),imshow(word5),title('55');
 subplot(5,7,20),imshow(word6),title('66');
 subplot(5,7,21),imshow(word7),title('77');
 
 imwrite(word1,'1.jpg'); % 创建七位车牌字符图像
 imwrite(word2,'2.jpg');
 imwrite(word3,'3.jpg');
 imwrite(word4,'4.jpg');
 imwrite(word5,'5.jpg');
 imwrite(word6,'6.jpg');
 imwrite(word7,'7.jpg');
 
 %% 进行字符识别
 liccode=char(['0':'9' 'A':'Z' '京辽陕苏鲁浙']);%建立自动识别字符代码表；'京津沪渝港澳吉辽鲁豫冀鄂湘晋青皖苏赣浙闽粤琼台陕甘云川贵黑藏蒙桂新宁'
 % 编号：0-9分别为 1-10;A-Z分别为 11-36;
 % 京  津  沪  渝  港  澳  吉  辽  鲁  豫  冀  鄂  湘  晋  青  皖  苏
 % 赣  浙  闽  粤  琼  台  陕  甘  云  川  贵  黑  藏  蒙  桂  新  宁
 % 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 
 % 60 61 62 63 64 65 66 67 68 69 70
 subBw2 = zeros(40, 20);
 num = 1;   % 车牌位数
 for i = 1:7
    ii = int2str(i);    % 将整型数据转换为字符串型数据
    word = imread([ii,'.jpg']); % 读取之前分割出的字符的图片
    segBw2 = imresize(word, [40,20], 'nearest');    % 调整图片的大小
    segBw2 = im2bw(segBw2, 0.5);    % 图像二值化
    if i == 1   % 字符第一位为汉字，定位汉字所在字段
        kMin = 37;
        kMax = 42;
    elseif i == 2   % 第二位为英文字母，定位字母所在字段
        kMin = 11;
        kMax = 36;
    elseif i >= 3   % 第三位开始就是数字了，定位数字所在字段
        kMin = 1;
        kMax = 36;
    end
    
    l = 1;
    for k = kMin : kMax
        fname = strcat('namebook\',liccode(k),'.jpg');  % 根据字符库找到图片模板
        samBw2 = imread(fname); % 读取模板库中的图片
        samBw2 = im2bw(samBw2, 0.5);    % 图像二值化
        
        % 将待识别图片与模板图片做差
        for i1 = 1:40
            for j1 = 1:20
                subBw2(i1, j1) = segBw2(i1, j1) - samBw2(i1 ,j1);
            end
        end
        
        % 统计两幅图片不同点的个数，并保存下来
        Dmax = 0;
        for i2 = 1:40
            for j2 = 1:20
                if subBw2(i2, j2) ~= 0
                    Dmax = Dmax + 1;
                end
            end
        end
        error(l) = Dmax;
        l = l + 1;
    end
    
    % 找到图片差别最少的图像
    errorMin = min(error);
    findc = find(error == errorMin);
%     error
%     findc
       
    % 根据字库，对应到识别的字符
    Code(num*2 - 1) = liccode(findc(1) + kMin - 1);
    Code(num*2) = ' ';
    num = num + 1;
    
    
 end
 
 % 显示识别结果
 disp(Code);
 msgbox(Code,'识别出的车牌号');

