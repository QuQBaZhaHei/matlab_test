%%
clear;
close all;
clc;

%% ��ȡͼ��
img = imread('��G77777.jpg');
subplot(3,3, 1);
imshow(img);
title('����ͼ��');

%% �Ҷȴ���
img1 = rgb2gray(img);    % RGBͼ��ת�Ҷ�ͼ��
subplot(3,3,2);
imshow(img1);
title('�Ҷ�ͼ��');
subplot(3,3,3);
imhist(img1);
title('�Ҷȴ����ĻҶ�ֱ��ͼ');

%% ��Ե��ȡ
img4 = edge(img1, 'roberts', 0.15, 'both');
subplot(3,3,4);
imshow(img4);
title('roberts���ӱ�Ե���');

%% ƽ��ͼ��ͼ������
se = strel('rectangle', [50,30]);
img5 = imclose(img4, se);
subplot(3,3,5);
imshow(img5);
title('ƽ��ͼ�������');

%% ��ͼ����ɾ����������2200����8�ڽ�
img6 = bwareaopen(img5, 2200);
subplot(3,3,6);
imshow(img6);
title('��ͼ�����Ƴ�С����');

%% �и��ͼ��
[y, x, z] = size(img6);
img7 = double(img6);    % ת��˫���ȸ�����

% ���Ƶ���ɫ����
% Y����
blue_Y = zeros(y, 1);
for i = 1:y
    for j = 1:x
        if(img7(i, j) == 1) % �жϳ���λ������
            blue_Y(i, 1) = blue_Y(i, 1) + 1;    % ���ص�ͳ��
        end
    end
end

% �ҵ�Y�������Сֵ
img_Y1 = 1;
while (blue_Y(img_Y1) < 5) && (img_Y1 < y)
    img_Y1 = img_Y1 + 1;
end

% �ҵ�Y��������ֵ
img_Y2 = y;
while (blue_Y(img_Y2) < 5) && (img_Y2 > img_Y1)
    img_Y2 = img_Y2 - 1;
end

% x����
blue_X = zeros(1, x);
for j = 1:x
    for i = 1:y
        if(img7(i, j) == 1) % �жϳ���λ������
            blue_X(1, j) = blue_X(1, j) + 1;
        end
    end
end

% �ҵ�x�������Сֵ
img_X1 = 1;
while (blue_X(1, img_X1) < 5) && (img_X1 < x)
    img_X1 = img_X1 + 1;
end

% �ҵ�x�������Сֵ
img_X2 = x;
while (blue_X(1, img_X2) < 5) && (img_X2 > img_X1)
    img_X2 = img_X2 - 1;
end

% ��ͼ����вü�
img8 = img(img_Y1:img_Y2, img_X1:img_X2, :);
subplot(3,3,7);
imshow(img8);
title('��λ���к�Ĳ�ɫ����ͼ��')

% ������ȡ�����ĳ���ͼ��
imwrite(img8, '����ͼ��.jpg');

%% �Գ���ͼ����ͼ��Ԥ����
plate_img = imread('����ͼ��.jpg');
plate_img=img8;

% ת���ɻҶ�ͼ��
plate_img1 = rgb2gray(plate_img);    % RGBͼ��ת�Ҷ�ͼ��
figure;
subplot(3, 3, 1);
imshow(plate_img1);
title('�Ҷ�ͼ��');
subplot(3, 3, 2);
imhist(plate_img1);
title('�Ҷȴ����ĻҶ�ֱ��ͼ');

%��ͼ����
Ig2=double(plate_img1);
w=fspecial('laplacian',0);
g1=imfilter(plate_img1,w,'replicate');
plate_img1=plate_img1-3*g1;
subplot(3,3,3);
imshow(plate_img1);
title('��ͼ');


% ֱ��ͼ���⻯
plate_img2 = histeq(plate_img1);
subplot(3,3,4);
imshow(plate_img2);
title('ֱ��ͼ���⻯��ͼ��');
subplot(3,3,5);
imhist(plate_img2);
title('ֱ��ͼ');

%��ȥ��������
plate_img2 = medfilt2(plate_img2);
subplot(3,3,6);
imshow(plate_img2);
title('��ȥ��������');

% ��ֵ������
plate_img3 = im2bw(plate_img2, 0.7);
subplot(3,3,7);
imshow(plate_img3);
title('���ƶ�ֵͼ��');

% % ��ֵ�˲�
% plate_img4 = medfilt2(plate_img3);
% subplot(3,3,8);
% imshow(plate_img4);
% title('��ֵ�˲����ͼ��');

%% �����ַ��ָ�
plate_img5 = my_imsplit(plate_img3);
[m, n] = size(plate_img5);

s = sum(plate_img5);    %sum(x)����������ӣ���ÿ�еĺͣ������������;
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

 % �ָ���ڶ����ַ�
 [word2,plate_img6]=getword(plate_img6);
 % �ָ���������ַ�
 [word3,plate_img5]=getword(plate_img5);
 % �ָ�����ĸ��ַ�
 [word4,plate_img5]=getword(plate_img5);
 % �ָ��������ַ�
 [word5,plate_img5]=getword(plate_img5);
 % �ָ���������ַ�
 [word6,plate_img5]=getword(plate_img5);

 % �ָ�����߸��ַ�
 [word7,plate_img5]=getword(plate_img5);

 figure;
 subplot(5,7,1),imshow(word1),title('1');
 subplot(5,7,2),imshow(word2),title('2');
 subplot(5,7,3),imshow(word3),title('3');
 subplot(5,7,4),imshow(word4),title('4');
 subplot(5,7,5),imshow(word5),title('5');
 subplot(5,7,6),imshow(word6),title('6');
 subplot(5,7,7),imshow(word7),title('7');

 word1=imresize(word1,[40 20]);%imresize��ͼ�������Ŵ������õ��ø�ʽΪ��B=imresize(A,ntimes,method)������method��ѡnearest,bilinear��˫���ԣ�,bicubic,box,lanczors2,lanczors3��
 word2=imresize(word2,[40 20]);
 word3=imresize(word3,[40 20]);
 word4=imresize(word4,[40 20]);
 word5=imresize(word5,[40 20]);
 word6=imresize(word6,[40 20]);
 word7=imresize(word7,[40 20]);
 
 imwrite(word1,'1.jpg'); % ������λ�����ַ�ͼ��
 imwrite(word2,'2.jpg');
 imwrite(word3,'3.jpg');
 imwrite(word4,'4.jpg');
 imwrite(word5,'5.jpg');
 imwrite(word6,'6.jpg');
 imwrite(word7,'7.jpg');