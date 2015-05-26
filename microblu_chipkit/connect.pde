//This code comes from Keith's WifiTCPEchoServer sketch.


/************************************************************************/
/*                                                                      */
/*       TCPEchoServer                                                  */
/*                                                                      */
/*       A chipKIT DEWFcK TCP Server application to                     */
/*       demonstrate how to use the TcpServer Class.                    */
/*       This can be used in conjuction  with TCPEchoClient             */              
/*                                                                      */
/************************************************************************/
/*       Author:        Keith Vogel                                     */
/*       Copyright 2014, Digilent Inc.                                  */
/************************************************************************/
/* 
*
* Copyright (c) 2013-2014, Digilent <www.digilentinc.com>
* Contact Digilent for the latest version.
*
* This program is free software; distributed under the terms of 
* BSD 3-clause license ("Revised BSD License", "New BSD License", or "Modified BSD License")
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1.    Redistributions of source code must retain the above copyright notice, this
*        list of conditions and the following disclaimer.
* 2.    Redistributions in binary form must reproduce the above copyright notice,
*        this list of conditions and the following disclaimer in the documentation
*        and/or other materials provided with the distribution.
* 3.    Neither the name(s) of the above-listed copyright holder(s) nor the names
*        of its contributors may be used to endorse or promote products derived
*        from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
* BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
* OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
* OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*       5/14/2014 (KeithV): Created                                    */
/*       5/26/2015 (AdamW): Modified for Microblu Chipkit               */
/*                                                                      */
/************************************************************************/

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

