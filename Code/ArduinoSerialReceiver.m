%�����ܪi���A�H���ӷ���Serial Port
delete(instrfindall);
serialPort = serial('COM4'); %��oSerial Port(�ǦC��)
set(serialPort,'BaudRate',9600); %�]�wBaud Rate
 
fopen(serialPort); %���}Serial Port
stop = 0;
try   %�i��ҥ~(Exception)�B�z

    while stop == 0
        data = fgetl(serialPort);   %�ϥ�fgetl()��Ū�h�qSerial PortŪ�쪺��
        
        disp(data);

    end
 
catch ME
 
    id = ME.identifier
 
    fclose(serialPort); %����Serial Port
 
end
 
fclose(serialPort); %����Serial Port