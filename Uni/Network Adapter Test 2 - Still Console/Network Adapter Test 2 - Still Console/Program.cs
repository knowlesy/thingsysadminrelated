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
            // Print SharpPcap version 
            string ver = SharpPcap.Version.VersionString;
            //Console.WriteLine("SharpPcap {0},", ver);

            // Retrieve the device list
            SharpPcap.LivePcapDeviceList devices = SharpPcap.LivePcapDeviceList.Instance;

            // If no devices were found print an error
            if (devices.Count < 1)
            {
                Console.WriteLine("No devices were found on this machine");
                return;
            }

            Console.WriteLine("\nThe following devices are available on this machine:");
            //Console.WriteLine("----------------------------------------------------\n");

            int i = 0;
            
            // Print out the available network devices 
            foreach (SharpPcap.PcapDevice dev in devices)
            {
                /* Description */
                //Console.WriteLine("{0}){1}", i, SharpPcap.PcapDevice.Description get);
                //Console.WriteLine();
                /* Name */
                Console.WriteLine("\tName:\t{0}", dev.Description);
                /* IP Address */
               // Console.WriteLine("\tIP Address: \t\t{0}", dev.PcapIpAddress);
                /* Is Loopback */
               // Console.WriteLine("\tLoopback: \t\t{0}", dev.PcapLoopback);

                Console.WriteLine();
                i++;
            }

            Console.Write("Hit 'Enter' to exit...");
            Console.ReadLine();
        }
    }
}
