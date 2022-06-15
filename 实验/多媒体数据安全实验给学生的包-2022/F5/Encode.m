%%% setup
Origin_Pic='Origin.jpg';  % Origin image (grayscale JPEG image)
Aim_Pic='after.jpeg';  % resulting image (grayscale JPEG image)
Infortxt = 'Infor.txt'; % Information that need to steganography
fprintf('Origin image name:     %s\n' ,Origin_Pic);
fprintf('After image name:     %s\n' , Aim_Pic) ;
fprintf('Information txt name:     %s\n' , Infortxt) ;

%% 

tic;% tic用来保存当前时间，而后使用toc来记录程序完成时间
[nzAC]=F5_simulation (Origin_Pic, Aim_Pic, Infortxt, 2) ;
T=toc;
%% 
fprintf('Used time:    %5f seconds\n',T);

% 做图像对比图
fig = figure('numbertitle','off','name','F5信息隐藏图像对比和DCT频率分布直方图');
subplot(2,2,1);imshow(Origin_Pic);title('未嵌入信息的图像');
subplot(2,2,2);imshow(Aim_Pic);title('已嵌入信息的图像');
% 做直方图
data1=load('DCT1out.txt'); % 前的DCT系数
data2=load('DCT2out.txt'); % 后的DCT系数
subplot(2,2,3);histogram(data1,-30:1:30);title('histogram-origin');
subplot(2,2,4);histogram(data2,-30:1:30);title('histogram-after');

