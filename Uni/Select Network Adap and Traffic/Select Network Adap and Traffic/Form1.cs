using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;


namespace Select_Network_Adap_and_Traffic
{


    public partial class Form1 : Form
    {

        bool Stop = true;
        //creates a delegate to be referenced later on to initiate interactions between multiple concurrent threads
        private delegate void AddListBoxItemDelegate(object item);
        //Form 1 
        public Form1()
        {
            InitializeComponent();
        }
        //initialiaze Component is a test - not in use 
        private void initializeComponents()
        {
            // _startbtn = new Button();
            //m_nameButton.Click += new System.EventHandler(NameButtonClicked);
            // _startbtn.Click += EventHandler(_startbtn_Click);
        }
        //form load
        private void Form1_Load(object sender, EventArgs e)
        {
            //Form Load


        }
        // Get App looks for the Network Interface Cards and indexs them passing it to the combo box
        private void GetAdap()
        {
            int i = 0;
            // Retrieve NIC Adapters
            SharpPcap.LivePcapDeviceList devices = SharpPcap.LivePcapDeviceList.Instance;
            // If no devices are found show message box or appear no device in NIC combobox
            if (devices.Count < 1)
            {
                _comboNIC.Items.Add("No devices were found on this machine");
                MessageBox.Show("No devices were found on this machine");
                return;
            }

            // this is the process for indexing NIC Devices
            foreach (SharpPcap.PcapDevice dev in devices)
            {
                //bring in the instance pcap interface links it to pcapdevices
                SharpPcap.PcapInterface _Interface = dev.Interface;
                //passes the dev command to traffic
                /// Previous Testing for All NIC
                // Traffic(dev);
                ///

                //fills NIC's found into combo box with  ip addresses from pcapinterface of the NIC
                _comboNIC.Items.Add(dev.Description + " " + "IP Address: " + _Interface.Addresses[1].Addr.ipAddress.ToString());
                i++;
            }

        }
        // Repeat Process for Get Adap, however this is the process in which is the selection of the adapter for packet capturing
        private void ReadNICAdap(string SelectedDevice)
        {
            int i = 0;

            // Retrieve NIC Adapters
            SharpPcap.LivePcapDeviceList devices = SharpPcap.LivePcapDeviceList.Instance;

            // Show available NIC adapters
            foreach (SharpPcap.LivePcapDevice dev in devices)
            {
                //bring in the instance pcap interface links it to pcapdevices
                SharpPcap.PcapInterface _Interface = dev.Interface;
                //passes the dev command to traffic
                //
                if (dev.Description + " " + "IP Address: " + _Interface.Addresses[1].Addr.ipAddress.ToString() == SelectedDevice)
                {
                    //Passes selected network adapter to Traffic
                    Traffic(dev);
                    ///test
                    //_startbtn_Click(dev);
                    ///
                }


              
                i++;
            }

        }
        //sends back the text of the selected network card to ReadNICAdap
        private void _comboNIC_SelectedIndexChanged(object sender, EventArgs e)
        {
            //passing the combo text to ReadNICAdap
            ReadNICAdap(_comboNIC.Text);
        }
        //Enables the ability of directing network packets through a network adapter and starting to capture them
        private void Traffic(SharpPcap.LivePcapDevice device)
        {

            // Register our handler function to the 
            // 'packet arrival' event sets up for incomming network packets and what to do 
            device.OnPacketArrival += new SharpPcap.PacketArrivalEventHandler(device_OnPacketArrival);
            ///<debug>
            //MessageBox.Show(device.Mode.ToString());
            ///<end>
            //int readTimeoutMilliseconds = 1000;
            // Open the device for capturing in promiscuous mode BY DEFAULT
            device.Open(SharpPcap.DeviceMode.Promiscuous);

            ///<Previous Code>
            // device.Open(SharpPcap.DeviceMode.Promiscuous, readTimeoutMilliseconds);
            ///<END>

            // Start the capturing process for selected adapter - no button
            device.StartCapture();
            // _startbtn = new Button();
            //  _startbtn.Click +=(device.StartCapture());

            // Stop the capturing process 
            //  device.StopCapture();
            // Close the pcap device
            // device.Close();

            ///<Previous Check for promiscuous mode>
            /*
            //sets string for selected device
            string NICselected;
            NICselected = _comboNIC.SelectedItem.GetType();
            //passes string of selected to device to NICselected
           // NICselected = device.Interface[i];
  
            //Checks if promiscuous mode is enabled
            if (_checkProm.Checked.Equals(true))
            {
                //if enabled device goes into promiscuous mode

                NICselected.SharpPcap.LivePcapDevice.Open(SharpPcap.DeviceMode.Promiscuous);
            }
            else
            {
               NICselected.SharpPcap.LivePcapDevice.Open(SharpPcap.DeviceMode.Normal);
            }
             */
            ///<End>

        }
        //previous start button - not used
        private void _startbtn_Click(object sender, EventArgs e, SharpPcap.LivePcapDevice device)
        {
            /*// Register our handler function to the 
            // 'packet arrival' event 
            device.OnPacketArrival += new SharpPcap.PacketArrivalEventHandler(device_OnPacketArrival);

            // Open the device for capturing 
            //int readTimeoutMilliseconds = 1000;
            MessageBox.Show(device.Mode.ToString());
            //int readTimeoutMilliseconds = 1000;
            device.Open(SharpPcap.DeviceMode.Promiscuous);

            // device.Open(SharpPcap.DeviceMode.Promiscuous, readTimeoutMilliseconds);


            // Console.WriteLine(
            // "-- Listening on {0}, hit 'Enter' to stop...",
            // device.Description);

            // Start the capturing process 
            device.StartCapture();*/
        }
        //stop button to stop capturing data
        private void _stopbtn_Click(object sender, EventArgs e)
        {
            //stops packet capture based on boolean
            Stop = true;
        }
        //uses delgation to talk between the capture thread and the send to list box thread
        private void AddListBoxItem(object item)
        {
            if (this.listBox1.InvokeRequired)
            {
                // This is a worker thread so delegate the task.
                this.listBox1.Invoke(new AddListBoxItemDelegate(this.AddListBoxItem), item);
            }
            else
            {
                // This is the UI thread so perform the task.
                this.listBox1.Items.Add(item);
            }
        }
        //Packet Filter System  "FILTER ENGINE"
        private void device_OnPacketArrival(object sender, SharpPcap.CaptureEventArgs e)
        {

            //puts the stop clause capturing packets until stop is == false 
            if (Stop == false)
            {


                //sets variable "var" time as the date
                var time = e.Packet.Timeval.Date;
                //sets variable "var" len as the packet length
                var len = e.Packet.Data.Length;
                //sets variable "var" packet as a parser 
                var packet = PacketDotNet.Packet.ParsePacket(e.Packet);
                //string s = System.Text.Encoding.ASCII.GetString(e.Packet.Data                );
                //(debug check) string pete = s;

                // gets the encapsulated packet 
                var tcpPacket = PacketDotNet.TcpPacket.GetEncapsulated(packet);
                var udpPacket = PacketDotNet.UdpPacket.GetEncapsulated(packet);
                // defines a variable ippacket and assosiates it with the ip packet command in the packet.net dll
                System.Net.IPAddress srcIp;
                System.Net.IPAddress dstIp;




                      //TCP Packet Filtering System
                    if (tcpPacket != null)
                    {
                        //loads ip packet and examines the whole packet
                        var ipPacket = (PacketDotNet.IpPacket)tcpPacket.ParentPacket;
                        //links the variable names to the packet.net dll commands for src and dst ip addresses
                        srcIp = ipPacket.SourceAddress;
                        dstIp = ipPacket.DestinationAddress;

                        //AddListBoxItem(srcIp.ToString());
                        //AddListBoxItem(dstIp.ToString());

                        //string for the source ip of the address which the packet came from
                        string _SourceIP = srcIp.Address.ToString();
                        //string for the destination ip of the address which the packet came from
                        string _DestinIP = dstIp.Address.ToString();

                        ///<previous code>
                        //creates a string and applys ascii encoding to the packet data
                        // string Pete  = UTF8Encoding.Convert(Encoding.ASCII, Encoding.UTF8, e.Packet.Data).ToString(); 
                        // Encoding.ASCII.GetString(e.Packet.Data, 0, Array.IndexOf(e.Packet.Data, (byte)0));
                        // System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
                        // string Pete = encoding.GetString(e.Packet.Data);
                        ///<END>


                        //conversion mechanisim converts text from ascii aswell as utf encoding 8
                        string s = System.Text.Encoding.ASCII.GetString(UTF8Encoding.Convert(Encoding.ASCII, Encoding.UTF8, e.Packet.Data));
                        //string t = System.Text.Encoding.Convert(e.Packet.Data);

                        //displays all network traffic
                        if (_chkAll.Checked.Equals(true))
                        {
                            AddListBoxItem(s);
                            //MessageBox.Show("No Data will be shown in listbox, however data is being recieved - you can still save this data");
                        }

                        //check box for if selected it will capture it (will capture TCP ONLY!!!!!!!!!)
                        if (_checkiplay.Checked.Equals(true))
                        {
                            //creates the filter for the checked item
                            if (s.Contains("GET /iplayer/") || s.Contains("Referer: http://www.bbc.co.uk/emp/10player.swf?"))
                            {
                                //displayes that the checked item is being used on the network
                                AddListBoxItem("::: iplayer ::: " + "SRC= " + srcIp.ToString() + " - DEST= " + dstIp.ToString());

                            }
                            else
                            {
                                //do nowt
                            }
                        }


                        //check box for if selected it will capture
                        if (_checkie8.Checked.Equals(true))
                        {
                            //creates the filter for the checked item
                            if (s.Contains("MSIE 8.0"))
                            {
                                //displayes that the checked item is being used on the network
                                AddListBoxItem("::: IE8 ::: " + "SRC= " + srcIp.ToString() + " - DEST= " + dstIp.ToString());
                            }
                            else
                            {
                                //do nowt
                            }

                            //(debug check) string pete = s;
                        }




                        //check box for if selected it will capture
                        if (_checkskype.Checked.Equals(true))
                        {
                            /*
                             * GET /ui/0/4.2.0.155.259/en/getlatestversion?ver=4.2.0.155&uhash=1dc39bfd1972f0a1b7b5b8fe6213a3091 HTTP/1.1
                                User-Agent: Skype\231
                                    Host: ui.skype.com
                                        Cache-Control: no-cache
                             */




                            //creates the filter for the checked item
                            if (s.Contains("User-Agent: Skype\\231") || s.Contains("GET /ui/0/4.2.") || s.Contains("Host: ui.skype.com\\r\\n") && s.Contains("getlatestversion?ver="))
                            {
                                //displayes that the checked item is being used on the network
                                AddListBoxItem("::: Skype ::: " + "SRC= " + srcIp.ToString() + " - DEST= " + dstIp.ToString());

                            }
                            else
                            {
                                //do nowt
                            }

                            //(debug check) string pete = s;
                        }

                        //check box for if selected it will captureit will then check for thunderbird data in packets and then what to do with the data
                        if (_checkthunderb.Checked.Equals(true))
                        {
                            //creates the filter for the checked item
                            if (s.Contains("GET /thunderbird/start?locale=") && s.Contains("WINNT&buildid="))
                            {
                                //displayes that the checked item is being used on the network
                                AddListBoxItem("::: Thunderbird ::: " + "SRC= " + srcIp.ToString() + " - DEST= " + dstIp.ToString());

                            }
                            else
                            {
                                // dee nowt
                            }

                        }

                        /*
                            .BitTorrent protocol........Ñß×qo(Öj¸b7[p¼‡Ì.}.1-UT2000-¼HÊñ€Áií..î›
                        */

                        //check box for if selected it will capture
                        if (_checkutor2.Checked.Equals(true))
                        {
                            //creates the filter for the checked item
                           // if (s.Contains(".BitTorrent protocol") && s.Contains(".1-UT2000") || s.Contains(".1-UT2000"))
                            if (s.Contains("-UT2000"))
                            {
                                //displayes that the checked item is being used on the network
                                AddListBoxItem("::: Utorrent ::: " + "SRC= " + srcIp.ToString() + " - DEST= " + dstIp.ToString());

                            }
                            else
                            {
                                //do nowt
                            }
                        }

                        else
                        {
                            //do nowt

                        }


                        //(debug check) string pete = s;


                    }
                    //UDP Filter
                if( udpPacket != null)
                {
                    //sets the soruce and destination under a name command
                   System.Net.IPAddress UDPsrcIp;
                  System.Net.IPAddress UDPdstIp;
                  //links the variable names to the packet.net dll commands
                    var ipPacket = (PacketDotNet.IpPacket)udpPacket.ParentPacket;
                    

                    ///<previous code>
                  //  System.Net.IPAddress usrcIp;
                  //  System.Net.IPAddress udstIp;
                   //  usrcIp = ipPacket.SourceAddress;
                   // udstIp = ipPacket.DestinationAddress;
                   ///<END>
                   
                    //links the previously created strings to the ip packet address
                   UDPsrcIp = ipPacket.SourceAddress;
                   UDPdstIp = ipPacket.DestinationAddress;
                

                    
                    //string for the source ip of the address which the packet came from
                   string _SourceIP = UDPsrcIp.ToString();
                   string _DestinIP = UDPdstIp.ToString();
                  
                    //same method as the TCP filter for text conversion
                    string u = System.Text.Encoding.ASCII.GetString(UTF8Encoding.Convert(Encoding.ASCII, Encoding.UTF8, e.Packet.Data));

                    //if this is checked or boolean is equal to true then carry out inside proceadure 
                    if (_checkquake3.Checked.Equals(true))
                    {
                        //creates the filter for the checked item
                        if (u.Contains("getinfo xxx"))
                        {
                            //displayes that the checked item is being used on the network
                            AddListBoxItem("::: Quake 3 ::: " + "SRC= " + _SourceIP.ToString() + " - DEST= " + _DestinIP.ToString());

                        }
                        else
                        {
                            //do nowt
                        }
                        //(debug check) string pete = s;
                    }
                }



                    ///<Old Code>
                    //  packet.Packet.Data.
                    // PacketDotNet.TcpPacket;
                    //packet.Device.Description.ToString();
                    // DateTime time = packet.Date;
                    //int len = packet.PacketLength;

                    //listBox1.Items.Add(time.Hour + " " + time.Minute + " " + time.Second + " " + time.Millisecond + " " + len);
                    //PacketDotNet.TcpPacket p = packet.Packet. as PacketDotNet.TcpPacket;
                    //if(packet is SharpPcap)
                    // {
                    //  string pete = "";
                    // pete = "ukgkdsahgfsdgaf";
                    // }
                    //packet.Packet.Data;
                    //if (p == null || p.Data.Length)
                    //return;
                    /*
                    string s = System.Text.Encoding.ASCII.GetString(p.Data);

                    if (s.StartsWith("GET") || s.StartsWith("POST"))
                    Console.WriteLine(s);
                     */
                    ///<End>
                
            }
        }
        // when form is shown it runs called items 
        private void Form1_Shown(object sender, EventArgs e)
        {
            //runs the getapp variable
            GetAdap();
            // System Time 
            System.Windows.Forms.Timer timeUpdater = new Timer()
            {
                Interval = 1000, // milliseconds
            };

            timeUpdater.Tick += delegate
            {
                _timelabel.Text = DateTime.Now.ToLongTimeString();
            };

            timeUpdater.Start();

        }
        //saves the listbox data into a text file
        private void _Savebtn_Click(object sender, EventArgs e)
        {
            //declares stream writer
        StreamWriter Write;
            //opens save window
        SaveFileDialog Open = new SaveFileDialog();
        try
        {
            //specifies save filter / file type filter
        Open.Filter = ("Text Document|*.txt|All Files|*.*");
        Open.ShowDialog();
        Write = new StreamWriter(Open.FileName);
            //for every line write the listbox line to the file
        for (int I = 0; I < listBox1.Items.Count; I++)
        {
            //converts list box line to string (text)
            Write.WriteLine(Convert.ToString(listBox1.Items[I]));
        }
            //closes the writing
        Write.Close();
        }
            //any issues catches them and promts a message box
        catch (Exception ex)
        {
       // MessageBox.Show(Convert.ToString(ex.Message)); //ERROR MEssage
            MessageBox.Show("You did not save the File" );
        return;
        } 
            }
        //CURRENT start button -In USE
        private void _startbtn_Click(object sender, EventArgs e)
        {
            //starts packet capture
            Stop = false;
            MessageBox.Show("You started Network Capture");
            
        }

        private void _chkAll_CheckedChanged(object sender, EventArgs e)
        {

        }








        }

    }
