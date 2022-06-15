%%% setup
Origin_Pic='Origin.jpg';  % Origin image (grayscale JPEG image)
Aim_Pic='after.jpeg';  % resulting image (grayscale JPEG image)
Infortxt = 'Infor.txt'; % Information that need to steganography
fprintf('Origin image name:     %s\n' ,Origin_Pic);
fprintf('After image name:     %s\n' , Aim_Pic) ;
fprintf('Information txt name:     %s\n' , Infortxt) ;

%% 

tic;% tic用来保存当前时间，而后使用toc来记录程序完成时间
[nzAC]=jsteg_simulation (Origin_Pic, Aim_Pic, Infortxt) ;
T=toc;
%% 
fprintf('Used time:    %5f seconds\n',T);

max_pic_row = 4;  % 图片的行数
max_pic_column = 2; % 图片的列数
now_pic_id = 1; % 现在是第几幅图,每次输出图像之后加1

% 做图像对比图
fig = figure('numbertitle','off','name','JSTEG信息隐藏图像对比和DCT频率分布直方图');
set(gcf,'unit','centimeters','position',[0,0,40,30])
subplot(max_pic_row,max_pic_column,now_pic_id);imshow(Origin_Pic);title('未嵌入信息的图像');now_pic_id = now_pic_id + 1;
subplot(max_pic_row,max_pic_column,now_pic_id);imshow(Aim_Pic);title('已嵌入信息的图像');now_pic_id = now_pic_id + 1;

% 做直方图
data1=load('DCT1out.txt');
data2=load('DCT2out.txt');
subplot(max_pic_row,max_pic_column,now_pic_id);histogram(data1,-30:1:30);title('histogram-origin');now_pic_id = now_pic_id + 1;
subplot(max_pic_row,max_pic_column,now_pic_id);histogram(data2,-30:1:30);title('histogram-after');now_pic_id = now_pic_id + 1;

% 做值对条状图
% 横轴为 [-127:2:-1, 0, 1:2:127] 到 1:129 的顺序映射
normalize_offset = 128; % 这里实际上不是一个变量，不能修改，因为后面的值不是使用normalize_offset 推算出来的
Origin_tabu = zeros(2, 129);
After_tabu = zeros(2, 129);

data1=load('DCT1out.txt');
for i = 1:length(data1)
    if(data1(i) <= -1*normalize_offset || data1(i) >= normalize_offset)
        continue;
    end
    normalize_DCT = data1(i) + normalize_offset;
    if(normalize_DCT < 127)
        x = xor(mod(normalize_DCT, 2), 1) + 1;
        y = ceil(normalize_DCT/2);
    elseif(normalize_DCT > 129)
        x = mod(normalize_DCT, 2) + 1;
        y = floor(normalize_DCT/2) + 2;
    else 
        x = 1;
        y = normalize_DCT-63;
    end
    Origin_tabu(x, y ) = Origin_tabu(x, y ) + 1;
end

subplot(max_pic_row,max_pic_column,now_pic_id);bar([-127:2:-1, 0, 1:2:127],Origin_tabu, 'stack');title('value pair-origin');now_pic_id = now_pic_id + 1;

data2=load('DCT2out.txt');
for i = 1:length(data2)
    if(data2(i) <= -1*normalize_offset || data2(i) >= normalize_offset)
        continue;
    end
    normalize_DCT = data2(i) + normalize_offset;
    if(normalize_DCT < 127)
        x = xor(mod(normalize_DCT, 2), 1) + 1;
        y = ceil(normalize_DCT/2);
    elseif(normalize_DCT > 129)
        x = mod(normalize_DCT, 2) + 1;
        y = floor(normalize_DCT/2) + 2;
    else 
        x = 1;
        y = normalize_DCT-63;
    end
    After_tabu(x, y ) = After_tabu(x, y ) + 1;
end
subplot(max_pic_row,max_pic_column,now_pic_id);bar([-127:2:-1, 0, 1:2:127],After_tabu , 'stack');title('value pair-after');now_pic_id = now_pic_id + 1;


% 做值对标准化图
% 横轴为 [-127:2:-1, 0, 1:2:127] 到 1:129 的顺序映射
Origin_propotion = zeros(2, 129);
After_propotion = zeros(2, 129);
for id = 1:129 
   Origin_propotion(1, id) =  Origin_tabu(1, id)/(Origin_tabu(1, id)+Origin_tabu(2, id));
   Origin_propotion(2, id) =  1.0-Origin_propotion(1, id);
   After_propotion(1, id) =  After_tabu(1, id)/(After_tabu(1, id)+After_tabu(2, id));
   After_propotion(2, id) =  1.0-After_propotion(1, id);
end

subplot(max_pic_row,max_pic_column,now_pic_id);bar([-127:2:-1, 0, 1:2:127],Origin_propotion, 'stack');title('value pair propotion-origin');now_pic_id = now_pic_id + 1;
subplot(max_pic_row,max_pic_column,now_pic_id);bar([-127:2:-1, 0, 1:2:127],After_propotion , 'stack');title('value pair propotion-after');now_pic_id = now_pic_id + 1;


% 做值对是否符合预期的图
% 横轴为 [-127:2:-1, 0, 1:2:127] 到 1:129 的顺序映射
value_move = zeros(2, 129);
cnt1 = 0;
cnt2 = 0;
for id = 1:129 
    if ( abs(Origin_tabu(1, id)-Origin_tabu(2, id)) >= abs(After_tabu(1, id)-After_tabu(2, id))) % 值对现象符合预期
        value_move(1, id) = 1.0;
        value_move(2, id) = 0.0;
        cnt1 = cnt1 + 1;
    else  % 值对现象不符合预期
        value_move(2, id) = 1.0;
        value_move(1, id) = 0.0;
        cnt2 = cnt2 + 1;
    end
end
fig = figure('numbertitle','off','name','JSTEG信息隐藏 值对现象展示');
bar([-127:2:-1, 0, 1:2:127],value_move , 'stack');title('蓝色表示值对趋向于相同，红色表示趋向于不同');
fprintf("符合预期的值对数量: %d\n不符合预期的值对数量: %d\n",cnt1, cnt2 );