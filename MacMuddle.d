#!/usr/bin/env rdmd
// Computes average line length for standard input.
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
        auto macAddressNumber = uniform( 0, 281_474_976_710_655, generator );

        // Format it as HEX (thank you std.format!)
        auto macAddressAppender = appender!string();
        formattedWrite( macAddressAppender, "%X", macAddressNumber );

        writeln( "Random MAC address created: ", macAddressAppender.data() );

        // Execute the commands. Do each twice. Sometimes it's finnicky.
        // TODO -- Instead of repeating, check for proper state changes/return codes.
        shell( "ifconfig wlan0 down" );
        shell( "ifconfig wlan0 down" );
        shell( "ifconfig wlan0 hw ether " ~ macAddressAppender.data() );
        shell( "ifconfig wlan0 hw ether " ~ macAddressAppender.data() );
        shell( "ifconfig wlan0 up" );
        shell( "ifconfig wlan0 up" );

    }

}
