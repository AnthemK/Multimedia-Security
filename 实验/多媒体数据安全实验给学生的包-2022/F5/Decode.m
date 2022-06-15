Aim_Pic='after.jpeg';  %resulting image (grayscale JPEG image)
Infortxt = 'Infor.txt'; % Information that need to steganography
F5Coe = 2; % 需要和加密保持一致
fpF5infor=fopen('F5infor.txt', 'w'); %直接把比特写到文件里，再作为字符串读出来

fpinfor = fopen(Infortxt,"r");
[~,msglen]=fread(fpinfor,'ubit1');
fprintf("The length of infor is :%d\n", msglen);
fclose(fpinfor);
fperrinfor = fopen('Error.txt','w');
try
    jobj=jpeg_read(Aim_Pic) ;   %JPEG image structure
    DCT=jobj.coef_arrays{1};  % DCT plane
catch
    error(' ERROR (problem with the after image)');
end
%% 

AC=numel(DCT)-numel(DCT(1:8:end, 1:8:end));  %非零AC DCT系数的数量
lenthDCT = numel(DCT);
if(msglen >AC)
    error('ERROR (message too long to steganography) ');
end
%% 
idD=1;
id=1;
% 使用2位的F5
while id <= msglen
    assert(id+F5Coe-1<=msglen, 'message length is not dividable by F5Coe');
    Pic_Infor = zeros(1,F5Coe);
    
    for id1 = 1:(2^F5Coe - 1)
        while (DCT (idD) == 0)
            idD=idD+1 ;
            assert(idD<=lenthDCT ,"Cannot steganographic so much information.");
        end
        nowid1=id1;
        for id2 = 1:F5Coe
            Pic_Infor(id2)=xor(Pic_Infor(id2), mod(nowid1, 2)*mod(DCT(idD),2));
            nowid1=floor(nowid1/2);
        end
        idD=idD+1 ;
    end
    
    for id1 = 1:F5Coe
        fwrite(fpF5infor,Pic_Infor(id1), 'ubit1');
    end
    id = id+F5Coe;
end
fclose(fpF5infor);
%% 

fpF5infor=fopen('F5infor.txt', 'r');
msg=fread(fpF5infor,'*char')';
fprintf('------------------------------------------------\n');
fprintf('The Information in JPEG is :\n%s\n' ,msg);
fclose(fpF5infor);
fclose(fperrinfor);

