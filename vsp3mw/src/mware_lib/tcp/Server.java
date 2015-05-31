package mware_lib.tcp;

import com.google.gson.Gson;

import java.io.IOException;
import java.net.ServerSocket;
import java.util.HashMap;

public class Server {
	private static int port = 51000 - 1;

	private ServerSocket MySvrSocket;
	
	public Server(int listenPort) throws IOException {
		MySvrSocket = new ServerSocket(listenPort);
	}
	
	public Connection getConnection() throws IOException {
		return new Connection(MySvrSocket.accept());
	}
	
	public void shutdown() throws IOException {
		MySvrSocket.close();
	}

	public static int newPort() {
		port++;
		return port;
	}

	/**
	 * @param args
	 * @throws IOException 
	 */
	public static void main(String[] args) throws IOException {
		Server theServer = new Server(14001);

		// Auf Verbindungsanfrage warten.
		Connection myConnection = theServer.getConnection();
		
		// Kommunikation
		System.out.println(myConnection.receive());
		myConnection.send("Who's there?");
		
		// Verbindung schliessen
		myConnection.close();

		// Server runterfahren
		theServer.shutdown();
	}
}
