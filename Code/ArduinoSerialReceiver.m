%模擬示波器，信號來源為Serial Port
delete(instrfindall);
serialPort = serial('COM4'); %獲得Serial Port(序列阜)
set(serialPort,'BaudRate',9600); %設定Baud Rate
 
fopen(serialPort); %打開Serial Port
stop = 0;
try   %進行例外(Exception)處理

    while stop == 0
        data = fgetl(serialPort);   %使用fgetl()來讀去從Serial Port讀到的值
        
        disp(data);

    end
 
catch ME
 
    id = ME.identifier
 
    fclose(serialPort); %關閉Serial Port
 
end
 
fclose(serialPort); %關閉Serial Port