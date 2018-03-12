using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
//using ;

namespace Network_Adapter_test_1
{
    class Program
    {
        static void Main(string[] args)
        {
            //string LivePcapDeviceList;
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


            // Print out the available network devices 
            foreach (SharpPcap.LivePcapDevice dev in devices)
                Console.WriteLine("{0}\n", dev.ToString());

            Console.Write("Hit 'Enter' to exit...");
            Console.ReadLine();
        }
    }
}
