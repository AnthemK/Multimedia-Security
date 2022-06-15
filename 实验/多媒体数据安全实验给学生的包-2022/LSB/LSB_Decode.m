picture = imread('after_encrypt.bmp');%读取图片
double_picture = double(picture);
[m, n] = size(double_picture);%获取图片尺寸

fpLSBinfor=fopen('LSBinfor.txt', 'w'); %直接把比特写到文件里，再作为字符串读出来

fpinfor = fopen(Infortxt,"r");
[~,msglen]=fread(fpinfor,'ubit1');
fprintf("The length of infor is :%d\n", msglen);
fclose(fpinfor);
p = 0;
for f2 = 1:n
    for f1 = 1:m
        
        fwrite(fpLSBinfor,bitand(double_picture(f1, f2), 1), 'ubit1');
        p=p+1;
        
        if p == msglen
            break;
        end
    end
    
    if p == msglen
        break;
    end
end

% 
% msg = reshape(msg, [], 7); % []表示自动计算后填入
% fprintf("Bin msg %s\n", msg);
% msg = (bin2dec(msg));%将二进制流格式的秘密信息转为字符串格式
% msg = msg';
% fprintf("the origin infor is %s\n", msg);
% 

fclose(fpLSBinfor);
fpLSBinfor=fopen('LSBinfor.txt', 'r');
msg=fread(fpLSBinfor,'*char')';
fprintf('------------------------------------------------\n');
fprintf('The Information in JPEG is :\n%s\n' ,msg);
fclose(fpLSBinfor);
