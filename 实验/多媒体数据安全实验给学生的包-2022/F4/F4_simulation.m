function [AC]=F4_simulation(Origin_Pic, Aim_Pic, Infortxt) 
fpinfor = fopen(Infortxt,"r");
[msg,msglen]=fread(fpinfor,'ubit1');
fclose(fpinfor);

try
    jobj=jpeg_read(Origin_Pic) ;   %JPEG image structure
    DCT=jobj.coef_arrays{1};  % DCT plane
catch
    error(' ERROR (problem with the cover image)');
end
%% 
f1=fopen('DCT1out.txt', 'w');
len_DCT = length(DCT(:));
for i=1:len_DCT
    fprintf(f1,'%d ',DCT(i));
end
fclose(f1);

AC=numel(DCT)-numel(DCT(1:8:end, 1:8:end));  % 非零AC DCT系数的数量 此处不理解
if(msglen >AC)
    error('ERROR (message too long to steganography) ');
end
idD=1;
id=1;
%% 

while id <= msglen  % 枚举信息
    %过滤 +-1和0
    while (DCT (idD) == 0) % 去除0信息，保证可以嵌入
        idD=idD+1 ;
    end
    
    if (DCT(idD) >0)
        DCT(idD) = DCT(idD) - xor(mod(DCT(idD),2), msg(id));
    elseif (DCT(idD) <0)
        DCT(idD) = DCT(idD) + xor(xor(mod(DCT(idD),2), msg(id)), 1);
    end
    if (DCT(idD) ~= 0)  %嵌入信息成功
        id = id + 1;
    end
    idD=idD+1;
end
%% 
f2=fopen('DCT2out.txt', 'w');
for i=1:len_DCT
    fprintf(f2,'%d ',DCT(i));
end
fclose(f2);
%% 

%%% save the resulting stego image
try
    jobj.coef_arrays{1}=DCT;
    jobj.optimize_coding=1;
    jpeg_write(jobj , Aim_Pic) ; 
catch
    error('ERROR (problem with saving the stego image) ')
end

end