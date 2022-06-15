picture = imread('Origin.bmp');%读取图片
Infortxt = 'Infor.txt'; % Information that need to steganography
double_picture = double(picture);
[m, n] = size(double_picture);%获取图片尺寸

fpinfor = fopen(Infortxt,"r");
origin_msg = fread(fpinfor, '*char');
fclose(fpinfor);
fprintf("string:%s\n", origin_msg);

fpinfor = fopen(Infortxt,"r");
[msg,msglen] = fread(fpinfor,'ubit1');
fclose(fpinfor);
% msg = msg(:);   % 把矩阵reshape成列向量After_propotion
len_msg = length(msg); %获取嵌入信息长度
p = 1;
Origin_tabu = zeros(2, 128);
After_tabu = zeros(2, 128);
Origin_propotion = zeros(2, 128);
After_propotion = zeros(2, 128);
for f2 = 1:n
    for f1 = 1:m
        Origin_tabu(mod(double_picture(f1, f2), 2)+1, floor(double_picture(f1, f2)/2)+1)=Origin_tabu(mod(double_picture(f1, f2), 2)+1, floor(double_picture(f1, f2)/2)+1) +1;
        double_picture(f1, f2) = double_picture(f1, f2) - mod(double_picture(f1, f2), 2) + msg(p,1);
        After_tabu(mod(double_picture(f1, f2), 2)+1, floor(double_picture(f1, f2)/2)+1)=After_tabu(mod(double_picture(f1, f2), 2)+1, floor(double_picture(f1, f2)/2)+1) +1;
        %将当前需要嵌入的比特放在当前灰度系数的最低位
        if p == len_msg
            break;
        end
        p = p + 1;
    end
    if p == len_msg
        break;
    end
end



double_picture = uint8(double_picture);
imwrite(double_picture, 'after_encrypt.bmp');%保存图片

set(gcf,'unit','centimeters','position',[0,0,40,30])
% 绘制比较图
subplot(3, 2, 1);imshow(picture);title('original pic');
subplot(3, 2, 2);imshow(double_picture);title('after encrypt pic');


subplot(3,2,3);bar(0:2:255,Origin_tabu, 'stack');title('value pair-origin');
subplot(3,2,4);bar(0:2:255,After_tabu , 'stack');title('value pair-after');

for id = 1:128 
   Origin_propotion(1, id) =  Origin_tabu(1, id)/(Origin_tabu(1, id)+Origin_tabu(2, id));
   Origin_propotion(2, id) =  1.0-Origin_propotion(1, id);
   After_propotion(1, id) =  After_tabu(1, id)/(After_tabu(1, id)+After_tabu(2, id));
   After_propotion(2, id) =  1.0-After_propotion(1, id);
end


subplot(3,2,5);bar(0:2:255,Origin_propotion, 'stack');title('value pair propotion-origin');
subplot(3,2,6);bar(0:2:255,After_propotion , 'stack');title('value pair propotion-after');

value_move = zeros(2, 128);
cnt1 = 0; % 符合预期的值对数量
cnt2 = 0; % 不符合预期的值对数量
for id = 1:128 
    if ( abs(Origin_tabu(1, id)-Origin_tabu(2, id)) >= abs(After_tabu(1, id)-After_tabu(2, id)))
        value_move(1, id) = 1.0;
        value_move(2, id) = 0.0;
        cnt1 = cnt1 + 1;
    else
        value_move(2, id) = 1.0;
        value_move(1, id) = 0.0;
        cnt2 = cnt2 + 1;
    end
end

fig = figure('numbertitle','off','name','LSB信息隐藏 值对现象展示');
bar(0:2:255,value_move , 'stack');title('蓝色表示值对趋向于相同，红色表示趋向于不同');
fprintf("符合预期的值对数量: %d\n不符合预期的值对数量: %d\n",cnt1, cnt2 );
