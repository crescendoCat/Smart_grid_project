%�����ܪi���A�H���ӷ���Serial Port
delete(instrfindall);
serialPort = serial('COM6'); %��oSerial Port(�ǦC��)
set(serialPort,'BaudRate',9600); %�]�wBaud Rate
 
fopen(serialPort); %���}Serial Port
stop = 0;
try   %�i��ҥ~(Exception)�B�z

    while stop == 0
        day = str2num(fgetl(serialPort));   %�ϥ�fgetl()��Ū�h�qSerial PortŪ�쪺��
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
 
    fclose(serialPort); %����Serial Port
 
end
 
fclose(serialPort); %����Serial Port