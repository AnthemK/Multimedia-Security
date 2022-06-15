Aim_Pic='after.jpeg';  %resulting image (grayscale JPEG image)
Infortxt = 'Infor.txt'; % Information that need to steganography
fpF4infor=fopen('F4infor.txt', 'w'); %直接把比特写到文件里，再作为字符串读出来

fpinfor = fopen(Infortxt,"r");
[~,msglen]=fread(fpinfor,'ubit1');
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
    while (DCT (idD) == 0)
        idD=idD+1;
    end
    fwrite(fpF4infor,xor(mod(DCT(idD),2), (DCT(idD) < 0)), 'ubit1');
    %{
    if (mod(DCT(idD),2)==1)
        fwrite(fp,1, 'ubit1');
    else
        fwrite(fp,0, 'ubit1');
    end
    %}
    idD=idD+1; 
end
fclose(fpF4infor);
%% 

fpF4infor=fopen('F4infor.txt', 'r');
msg=fread(fpF4infor,'*char')';
fprintf('------------------------------------------------\n');
fprintf('The Information in JPEG is :\n%s\n' ,msg);
fclose(fpF4infor);

