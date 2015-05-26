//This code comes from Keith's WifiTCPEchoServer sketch.

typedef enum
{
    NONE = 0,
    CONNECT,
    TCPCONNECT,
    WRITE,
    READ,
    CLOSE,
    DONE,
} STATE;

STATE state = CONNECT;

unsigned tStart = 0;
unsigned tWait = 5000;

byte rgbRead[1024];
int cbRead = 0;

uint16_t port = 1883;
TCPSocket tcpSocket;

// this is for Print.write to print
byte rgbWrite[] = {'*','W','r','o','t','e',' ','f','r','o','m',' ','p','r','i','n','t','.','w','r','i','t','e','*','\n'};
int cbWrite = sizeof(rgbWrite);

// this is for tcpSocket.writeStream to print
byte rgbWriteStream[] = {'*','W','r','o','t','e',' ','f','r','o','m',' ','t','c','p','C','l','i','e','n','t','.','w','r','i','t','e','S','t','r','e','a','m','*','\n'};
int cbWriteStream = sizeof(rgbWriteStream);


void connect() {
  //Taken from TCPEchoClient
  //TODO: Talk with Keith about license
  
  IPSTATUS status;
  int cbRead = 0;

  while (state != DONE)
  {
    switch(state)
    {
    case CONNECT:
      if(WiFiConnectMacro())
      {
        Serial.println("WiFi connected");
        deIPcK.begin();
        //state = TCPCONNECT;
        state = DONE; 
      }
      else if(IsIPStatusAnError(status))
       {
       Serial.print("Unable to connection, status: ");
       Serial.println(status, DEC);
       state = CLOSE;
       }
      break;

    case TCPCONNECT:
      if(deIPcK.tcpConnect(server, port, tcpSocket))
      {
        Serial.println("Connected to server.");
        state = WRITE;
      }
      break;

      // write out the strings
    case WRITE:
      if(tcpSocket.isEstablished())
      {     
        tcpSocket.writeStream(rgbWriteStream, cbWriteStream);

        Serial.println("Bytes Read Back:");
        state = READ;
        tStart = (unsigned) millis();
      }
      break;

      // look for the echo back
    case READ:

      // see if we got anything to read
      if((cbRead = tcpSocket.available()) > 0)
      {
        cbRead = cbRead < sizeof(rgbRead) ? cbRead : sizeof(rgbRead);
        cbRead = tcpSocket.readStream(rgbRead, cbRead);

        for(int i=0; i < cbRead; i++)
        {
          Serial.print((char) rgbRead[i]);
        }
      }

      // give us some time to get everything echo'ed back
      else if( (((unsigned) millis()) - tStart) > tWait )
      {
        Serial.println("");
        state = CLOSE;
      }
      break;

      // done, so close up the tcpSocket
    case CLOSE:
      tcpSocket.close();
      Serial.println("Closing TcpClient, Done with sketch.");
      while (1) {}; //Hang forever!
      state = DONE;
      break;

    case DONE:
      Serial.println("Done with connecting!");
    default:
      break;
    }

    // keep the stack alive each pass through the loop()
    DEIPcK::periodicTasks();
  }
}

