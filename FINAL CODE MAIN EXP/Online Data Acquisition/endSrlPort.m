function endSrlPort(srl)

fclose(srl) % close connection to serial port
delete(srl) %delete srl object
clear srl %clear it from workspace
end