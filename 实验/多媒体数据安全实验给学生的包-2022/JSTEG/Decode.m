Aim_Pic='after.jpeg';  %resulting image (grayscale JPEG image)
Infortxt = 'Infor.txt'; % Information that need to steganography
fpjsteginfor=fopen('jsteginfor.txt', 'w'); %直接把比特写到文件里，再作为字符串读出来

% 此处偷个懒获取嵌入信息的长度。
fpinfor = fopen(Infortxt,"r");
[~,msglen]=fread(fpinfor,'ubit1');% 使用~表示忽略读入的具体信息
fprintf("The length of infor is :%d\n", msglen);
fclose(fpinfor);

try
    jobj=jpeg_read(Aim_Pic) ;   %JPEG image structure
    DCT=jobj.coef_arrays{1};  % DCT plane
catch
    error(' ERROR (problem with the after image)');
end
%% 
AC=numel(DCT)-numel(DCT(1:8:end, 1:8:end));  %非零AC DCT系数的数量
if(msglen >AC)
    error('ERROR (message too long to steganography) ');
end
idD=1;
%% 

for id=1 :msglen
    while (abs (DCT (idD))<=1)
        idD=idD+1;
    end
    fwrite(fpjsteginfor,mod(DCT(idD),2), 'ubit1');
    %{
    if (mod(DCT(idD),2)==1)
        fwrite(fp,1, 'ubit1');
    else
        fwrite(fp,0, 'ubit1');
    end
    %}
    idD=idD+1; 
end
fclose(fpjsteginfor);
%% 

fpjsteginfor=fopen('jsteginfor.txt', 'r');
msg=fread(fpjsteginfor,'*char')';
fprintf('-----\n');
fprintf('The Information in JPEG is :\n%s\n' ,msg);
fclose(fpjsteginfor);

