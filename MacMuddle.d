#!/usr/bin/env rdmd
import std.stdio;

void main( string[] args ) 
{
	bool helpRequested = false;
    //	bool randomMAC = false; Random is the only option right now.
	// string macAddress; Not yet

	{
		import std.getopt;
		getopt( args,
			"help|h", &helpRequested,
			//"random|r", &randomMAC,
			/*"macAddress|m", &macAddress*/ );
	}

    if( helpRequested )
    {
        writeln( "MacMuddle -- Haphazardly tears down wireless service, changes your MAC address (if supported by your hardware), and brings the service back up." );
        writeln( "You MUST run this as root or with permissions to change network hardware. Try \'sudo\'." );
        writeln( " Valid Options:" );
		writeln( "   --help, -h : display this output" );
        return;
    }

    {
        import std.process, 
                std.random, 
                std.datetime, 
                std.format,
                std.array;
             
        // Generate a random MAC address
        Random generator; 
        generator.seed( cast( uint ) Clock.currStdTime() );
        // Generate a number between 0 and the maximum value for a 48 bit long integer (MAC address length is 12 nibbles)
        // Apparently, this call can accept types larger than the standard 32 bit type, uint, but the seed function above cannot.
        // TODO -- narrow the scope of generated random numbers. Some seem to fail.
        auto macAddressNumber = uniform( 0, 281_474_976_710_655, generator );

        // Format it as HEX (thank you std.format!)
        auto macAddressAppender = appender!string();
        formattedWrite( macAddressAppender, "%X", macAddressNumber );

        writeln( "Random MAC address created: ", macAddressAppender.data() );

        // Execute the commands.
        // TODO -- Check for proper state changes/return codes.
        auto returnStruct = executeShell( "ifconfig wlan0 down" );
        writeln( returnStruct.output );
        returnStruct = executeShell( "ifconfig wlan0 hw ether " ~ macAddressAppender.data() );
        writeln( returnStruct.output );
        returnStruct = executeShell( "ifconfig wlan0 up" );
        writeln( returnStruct.output );

    }

}
