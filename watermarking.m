clear all;
close all;
[x, Fs] = audioread("piano.wav", 'native');
s = 'the text i want to insert in the wav file';

binary = reshape(dec2bin(s, 8).'-'0',1,[]);
%code is the length of my binary text on 10 bits, I will add it at the
%beginning of my text so that we know how many bits to extract from the
%signal. With 10 bits I can have 1024 bits length for my binary text wich
%is largely enough to store names.

code = reshape(dec2bin(length(binary), 10).'-'0',1,[]);
binary = [code binary];


%I convert the int16 value of each sample in binary
% then I replace the LSB of each sample by a bit of my binary text
%and I convert it back in int 16
for i = 1:length(binary)
    bina = dec2bin((typecast(int16(x(i,1)), 'uint16')), 16);
    bina(16) = char('0' + binary(i));
    dec = typecast(uint16(bin2dec(bina)),'int16');
    x(i, 1) = dec;
end

%I write the new wav file with the text inside
audiowrite('watermarked_piano.wav',x,Fs);

%Now I will get the text back from the file
[y, Fs] = audioread("watermarked_piano.wav", 'native');
%number will read the 10 first bits to know how many bits we need to
%analyse
number = '0000000000';
for i = 1:10
    bina = dec2bin((typecast(int16(y(i,1)), 'uint16')), 16);
    number(i) = bina(16);  
end

number = bin2dec(number);

%Now that I know haw many bits I need to read I store them in the array
%message
message = zeros(1,number);
for i = 10:number+10
    bina = dec2bin((typecast(int16(y(i,1)), 'uint16')), 16);
    if(bina(16) == '1')
        message(i-10) = 1;
    end
end

%Str is an array containing all the char
str = char(bin2dec(reshape(char(message+'0'), 8,[]).'));

%text is the message I get from the wav file
text = [];
for i = 1:length(str)
    text = [text str(i)];
end

%compute the SNR
[x, Fs] = audioread("piano.wav");
[y, Fs] = audioread("watermarked_piano.wav");
r = snr(x, y-x);

