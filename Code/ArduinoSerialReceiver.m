%模擬示波器，信號來源為Serial Port
delete(instrfindall);
serialPort = serial('COM6'); %獲得Serial Port(序列阜)
set(serialPort,'BaudRate',9600); %設定Baud Rate
 
fopen(serialPort); %打開Serial Port
stop = 0;
try   %進行例外(Exception)處理

    while stop == 0
        day = str2num(fgetl(serialPort));   %使用fgetl()來讀去從Serial Port讀到的值
        hour = str2num(fgetl(serialPort));
        supNum = str2num(fgetl(serialPort));
        sup = zeros(1, supNum);
        for i=1:supNum
            sup(1, i) = str2double(fgetl(serialPort));
        end
        usrNum = str2num(fgetl(serialPort));
        usr = zeros(1, usrNum);
        for i=1:usrNum
            usr(1, i) = str2double(fgetl(serialPort));
        end
    end
 
catch ME
 
    id = ME.identifier
 
    fclose(serialPort); %關閉Serial Port
 
end
 
fclose(serialPort); %關閉Serial Port