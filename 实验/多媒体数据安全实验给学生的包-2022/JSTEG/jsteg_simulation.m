function [AC]=jsteg_simulation(Origin_Pic, Aim_Pic, Infortxt) 
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

f1=fopen('DCT1out.txt', 'w'); % 存储原始DCT系数
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

%% 

for id = 1:msglen
    %过滤 +-1和0
    while (abs (DCT (idD))<=1)
        idD=idD+1 ;
    end
    if (DCT(idD) >0)
        %{
        if (message(id)==0 && mod(DCT(idD),2)~=0)
            DCT(idD)=DCT(idD)-1;
        end
        if (message(id)==1 && mod(DCT(idD),2)==0)
            DCT(idD)=DCT(idD)+1;
        end
        %}
        % 尝试Xor？
        if msg(id) ~= mod(DCT(idD),2) % 如果提取结果不等于嵌入信息
            DCT(idD)=bitxor(DCT(idD),1); % 进行翻转
        end 
    elseif (DCT(idD) <0)
        if (msg(id)==0 && mod(DCT(idD),2)~=0)
            DCT(idD)=DCT(idD)+1;
        end
        if (msg(id)==1 && mod(DCT(idD),2)==0)
            DCT(idD)=DCT(idD)-1;
        end
    end
    idD=idD+1;
end
%% 
f2=fopen('DCT2out.txt', 'w'); % 存储修改后的DCT系数
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