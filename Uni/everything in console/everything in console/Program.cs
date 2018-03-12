using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace everything_in_console
{
    class Program
    {
        static void Main(string[] args)
        {
            // Print SharpPcap version 
            string ver = SharpPcap.Version.VersionString;
            Console.WriteLine("SharpPcap {0}, Example1.IfList.cs", ver);

            // Retrieve the device list
            SharpPcap.LivePcapDeviceList devices = SharpPcap.LivePcapDeviceList.Instance;

            // If no devices were found print an error
            if (devices.Count < 1)
            {
                Console.WriteLine("No devices were found on this machine");
                return;
            }

            Console.WriteLine("\nThe following devices are available on this machine:");
            Console.WriteLine("----------------------------------------------------\n");

            int i = 0;
       /* Scan the list printing every entry */
foreach(SharpPcap.PcapDevice dev in devices)
{
    /* Description */
    Console.WriteLine("{0}) {1}", i, dev.Interface.Description);

    Console.WriteLine();
    i++;
}

            // Extract a device from the list 
            SharpPcap.PcapDevice device = devices[i];

            // Register our handler function to the 
            // 'packet arrival' event 
            device.OnPacketArrival +=
              new SharpPcap.PacketArrivalEventHandler(device_OnPacketArrival);

            // Open the device for capturing 
            int readTimeoutMilliseconds = 1000;
            device.Open(SharpPcap.DeviceMode.Promiscuous, readTimeoutMilliseconds);

            Console.WriteLine(
                "-- Listening on {0}, hit 'Enter' to stop...",
                device.Description);

            // Start the capturing process 
            device.StartCapture();

            // Wait for 'Enter' from the user. 
            Console.ReadLine();

            // Stop the capturing process 
            device.StopCapture();

            // Close the pcap device
            device.Close();}

            private static void device_PcapOnPacketArrival(object sender, Packet packet)
{
    DateTime time = packet.PcapHeader.Date;
    int len = packet.PcapHeader.PacketLength;
    Console.WriteLine("{0}:{1}:{2},{3} Len={4}", 
    time.Hour, time.Minute, time.Second, time.Millisecond, len);
}
        }
    }

