Sbox_1 = [172 4 127 68 183 74 88 224 254 12 229 67 167 245 177 23; 19 140 164 132 154 92 27 196 115 99 199 26 243 108 182 200; 43 207 29 227 79 159 100 131 134 73 1 93 65 35 110 57; 145 157 238 246 253 49 209 117 121 58 102 144 170 240 94 2; 40 109 186 95 18 52 148 76 213 30 104 119 206 97 60 63; 212 33 251 149 116 83 89 11 142 242 77 98 129 210 112 139; 137 136 255 223 194 184 185 7 71 106 219 124 56 201 248 158; 225 176 15 202 34 191 244 41 25 16 133 180 143 28 44 55; 173 105 61 151 147 32 62 168 36 70 236 250 86 82 13 218; 152 237 161 155 189 249 75 90 22 208 203 192 141 47 125 146; 46 193 6 197 222 38 165 48 162 10 84 215 5 37 85 239; 217 231 214 103 175 120 178 211 195 50 205 138 128 174 228 14; 190 187 91 122 179 9 21 101 160 130 153 51 31 230 45 42; 234 96 235 107 233 53 241 20 81 17 72 166 80 156 78 226; 59 252 113 54 114 135 163 204 66 247 111 171 150 87 8 220; 69 39 188 198 221 181 0 118 169 232 123 24 64 126 3 216];

Sbox_2 = [184 246 232 159 24 136 101 71 230 139 252 2 92 152 171 91; 4 62 81 75 129 26 21 194 12 225 202 23 102 150 197 33; 35 34 110 189 165 37 105 210 249 173 113 215 233 88 151 172; 156 182 128 46 177 18 93 229 98 209 50 112 142 118 218 164; 248 31 226 1 89 99 119 54 130 64 85 146 66 9 56 176; 73 181 195 55 187 219 208 185 0 63 79 126 25 162 147 186; 222 211 51 61 148 143 77 40 192 193 97 58 114 234 206 250; 155 87 154 53 132 224 68 111 158 45 48 214 227 196 14 80; 15 207 116 44 123 140 120 121 29 127 100 122 125 30 96 237; 167 169 179 65 239 157 200 106 107 235 78 221 76 43 115 231; 124 131 188 134 216 170 144 166 255 108 203 60 36 241 163 201; 94 52 5 70 251 205 236 245 39 198 38 22 20 138 191 238; 95 104 190 32 27 67 153 84 212 161 199 41 7 90 17 3; 28 11 183 254 47 174 117 160 228 82 10 220 149 109 253 242; 72 16 243 13 59 83 135 137 49 42 57 168 8 86 145 213; 223 244 240 180 175 6 69 19 133 141 103 204 247 74 217 178];

originalImage= imread('cameraman.tif');

if size(originalImage,3) ==3 
    originalImage = rgb2gray(originalImage);
end

grayScaleImgNew = double(originalImage);

grayScaleImgNew = imresize(grayScaleImgNew, [256 256]);

a  = size(grayScaleImgNew, 1);
b  = size(grayScaleImgNew, 2);
numParts = 16;
c = floor(a/numParts);
d = rem(a, numParts);
partition_a = ones(1, numParts)*c;
partition_a(1:d) = partition_a(1:d)+1;
e = floor(b/numParts);
f = rem(b, numParts);
partition_b = ones(1, numParts)*e;
partition_b(1:f) = partition_b(1:f)+1;
output = mat2cell(grayScaleImgNew, partition_a, partition_b);

substitutedCell ={};
for row = 1:length(output)
    for column = 1:length(output)
        subSliceImage =  output{row,column};
        newSubSliceImageSubtituted = zeros(16);

        for imageSliceRow = 1:length(subSliceImage)
            for imageSliceCol = 1:length(subSliceImage)
                pixelValueImgSlice = uint8(subSliceImage(imageSliceRow,imageSliceCol));
                pixelValueInHex =  dec2hex(pixelValueImgSlice);
                hexLength=length(pixelValueInHex);
                if hexLength==2
                    HexByteX = pixelValueInHex(1:1);
                    HexByteY = pixelValueInHex(2:2);
                else
                    HexByteX = '0';
                    HexByteY = pixelValueInHex(1:1);
                end
                lookUpX = hex2dec(HexByteX) + 1;
                lookUpY = hex2dec(HexByteY) + 1 ;
                if lookUpX == 0
                    lookUpX = 1;
                end
                if lookUpY == 0
                   lookUpY = 1;
                end
                valueForSubs  = Sbox_1(lookUpX,lookUpY);
                pixelValueXored = bitxor(valueForSubs,Sbox_2(imageSliceRow,imageSliceCol)) ;%pixelValue + Sbox_2(imageSliceRow,imageSliceCol);
                pixelValueUnderMod256 = mod(pixelValueXored,256);
                newSubSliceImageSubtituted(imageSliceRow,imageSliceCol)= pixelValueUnderMod256;
            end
        end
        substitutedCell{row,column}= newSubSliceImageSubtituted;
    end
end


finalCellArray ={};


cipherImage = cell2mat(substitutedCell);
cipherImage = uint8(cipherImage);
imshow(cipherImage);

NPCR_VALUE = Cal_NPCR(uint8(grayScaleImgNew),cipherImage);
UACI_VALUE = UACI(cipherImage,uint8(grayScaleImgNew));

entropyPlainImg = entropy(uint8(grayScaleImgNew));
entropyEncImg = entropy(cipherImage);

%  Correlation
figure
subplot(1,2,1)
scatter(grayScaleImgNew(1:end-1),grayScaleImgNew(2:end),'.')
axis([0 255 0 255])
subplot(1,2,2)
scatter(cipherImage(1:end-1),cipherImage(2:end),'.')
axis([0 255 0 255])
% 

PSNR_VALUE = psnr(uint8(cipherImage),uint8(grayScaleImgNew));
MSE_VALUE =immse(uint8(cipherImage),uint8(grayScaleImgNew));


[chiSquareCipherImage_Test1,chiSquareCipherImage_Test1_P,chiSquareCipherImage_Test1_stats] = chi2gof(double(cipherImage(:)),'Alpha',0.01);
[chiSquareCipherImage_Test2,chiSquareCipherImage_Test2_P,chiSquareCipherImage_Test2_stats] = chi2gof(double(cipherImage(:)),'Alpha',0.05);

BIC_Test_SBOX1 = BIC(Sbox_1);
BIC_Test_SBOX2 = BIC(Sbox_2);

disp("Entropy plain Image");
disp(entropyPlainImg);

disp("Entropy Encrypted Image");
disp(entropyEncImg);

disp("UACI Value");
disp(UACI_VALUE);

disp("NPCR Value");
disp(NPCR_VALUE);

disp("PSNR Value");
disp(PSNR_VALUE);

disp("MSE Value");
disp(MSE_VALUE);

disp("BIC Value SBOX1");
disp(BIC_Test_SBOX1);

disp("BIC Value SBOX2");
disp(BIC_Test_SBOX2);

disp ("Chisquare test with 0.01% test");
disp(chiSquareCipherImage_Test1);

disp ("Chisquare test with 0.05% test");
disp(chiSquareCipherImage_Test2);


function [ NPCR ] = Cal_NPCR( imge,enc)
[rows,columns]=size(imge);
step=0;
for i=1:rows
    for j=1:columns
        if imge(i,j)~= enc(i,j)
           step=step+1;
        else 
             step=step+0;
        end
    end
end
NPCR =(step/(rows*columns))*100;
end

% calc UACI
function [UACI_value] = UACI( after_change,befor_change )
[row, col]=size(befor_change);
AB=[];
for i=1:row
    for j=1:col
AB(i,j)=abs(befor_change(i,j)-after_change(i,j));
    end
 end
  UACI_value = (sum(AB(:))/(256*row*col))*100;
   
end

function [BIC_Test] = BIC (sbox)
rows=uint8(8);
columns=uint8(8);
sbox_ = sbox';
sbox_ = reshape(sbox_,1,[]);

corrl = 0.0;
maxCorr = 0.0;
innerMostLoopLimit = bitshift(1,rows);

for i=0:rows-1
    pow = uint8(bitshift(1,i));
    for j=0:columns-1
        for k=0:columns-1 
            if j~=k
                for X=1:innerMostLoopLimit
                  ej = bitshift(1,j);
                  ek = bitshift(1,k);
                   x = uint8(X);
                  xoredValue = bitxor(x , pow);    
                  xoredValue = xoredValue + 1;
                  x = x + 1 ;
                  dei = bitxor(uint8(sbox_(X)) , uint8(sbox_(xoredValue)));
                  deiej = bitand(uint8(dei) , ej);
                  deiek = bitand(uint8(dei) , ek);

                
               
                  dej = (deiej / (2^j));  % C and C++ use this equation at backend to compute right shift
                  dek = (deiek / (2^k));  % C and C++ use this equation at backend to compute right shift
                 
                  aval_vector_j(X) = dej;
                  aval_vector_k(X) = dek;
                

   
                end

                  corrl = correlation(aval_vector_j, aval_vector_k,innerMostLoopLimit);
                if maxCorr < corrl
                   maxCorr = corrl;
                end
            end
        end
    end
end
BIC_Test = maxCorr;
end

function [corrValue] = correlation(x,y,n)
   sx = double(0.0);
  sy = double(0.0);
  sxx = double(0.0);
  syy = double(0.0);
  sxy = double(0.0);

    for i =1:n 
        xi = double(x(i));
        yi = double(y(i));
        sx = sx + xi;
        sy =sy + yi;
        sxx = sxx +  (xi * xi);
        syy = syy + (yi * yi);
        sxy = sxy + (xi * yi);
    end


    cov = (sxy / n) - (((sx * sy) / n) / n);
    if cov == 0.0
        corrValue = 0.0;
        return;
    end 

     calc = (sxx / n) - ( ((sx * sx )/ n) / n);

     sigmax = double(sqrt(double(calc)));
     calc2 = (syy / n) -  (((sy * sy) / n )/ n);
     sigmay = double(sqrt(double(calc2)));
     corrValue = (cov / sigmax )/ sigmay;
end




