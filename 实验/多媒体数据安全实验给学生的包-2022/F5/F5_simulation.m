function [AC]=F5_simulation(Origin_Pic, Aim_Pic, Infortxt, F5Coe) 
fpinfor = fopen(Infortxt,"r");
[msg,msglen]=fread(fpinfor,'ubit1');
fclose(fpinfor);
fperrinfor = fopen('Error2.txt',"w");

try
    jobj=jpeg_read(Origin_Pic) ;   %JPEG image structure
    DCT=jobj.coef_arrays{1};  % DCT plane
catch
    error(' ERROR (problem with the cover image)');
end

%% 
% 存储原始DCT系数
f1=fopen('DCT1out.txt', 'w');
len_DCT = length(DCT(:));
for i=1:len_DCT
    fprintf(f1,'%d ',DCT(i));
end
fclose(f1);

AC=numel(DCT)-numel(DCT(1:8:end, 1:8:end));  % 非零AC DCT系数的数量 此处不理解
lenthDCT = numel(DCT);
if(msglen >AC)
    error('ERROR (message too long to steganography) ');
end
%% 
idD=1;
id=1;
while id <= msglen
    assert(id+F5Coe-1<=msglen, 'message length is not dividable by F5Coe');
    S_idD=idD;
    S_id=id;
    Pic_Infor = zeros(1,F5Coe);
    Embedding_point_loc = zeros(1, 2^F5Coe - 1);
    for id1 = 1:(2^F5Coe - 1)
        while (DCT (idD) == 0)
            idD=idD+1 ;
            assert(idD<=lenthDCT ,"Cannot steganographic so much information.");
        end
        Embedding_point_loc(id1) = idD;
        nowid1=id1;
        for id2 = 1:F5Coe
            Pic_Infor(id2)=xor(Pic_Infor(id2), mod(nowid1, 2)*mod(DCT(idD),2));
            nowid1=floor(nowid1/2);
        end
        idD=idD+1 ;
    end
    nowidD = 0;
    for id1 = 1:F5Coe
        nowidD=nowidD + xor(msg(id1+id-1),  Pic_Infor(id1))*2^(id1-1);
    end
    if(nowidD == 0)
        id = id+F5Coe;
        continue;
    end
    nowidD = Embedding_point_loc(nowidD);
    if (DCT(nowidD) > 0)
        DCT(nowidD) = DCT(nowidD) - 1;
    elseif (DCT(nowidD) < 0)
        DCT(nowidD) = DCT(nowidD) + 1;
    end
    
    %% 
    %{
    if (DCT(nowidD) == 0)
        idD=S_idD;
        id=S_id;
        continue;
    end
    
    Pic_Infor =zeros(1, F5Coe);
    for id1 = 1:(2^F5Coe - 1)
        idD=Embedding_point_loc(id1);
        nowid1=id1;
        idD
        fprintf(fperrinfor, " %d ",idD);
        for id2 = 1:F5Coe
            Pic_Infor(id2)=xor(Pic_Infor(id2), mod(nowid1, 2)*mod(DCT(idD),2));
            nowid1=floor(nowid1/2);
        end
    end
    
    for id1 = 1:F5Coe
        assert(Pic_Infor(id1)==msg(id1));
    end   
    
    %}
    
    %% 
    
    
    
    
    
    
    
    if (DCT(nowidD) == 0)
        idD=S_idD;
        id=S_id;
    else 
        id = id+F5Coe;
    end
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
fclose(fperrinfor);
end