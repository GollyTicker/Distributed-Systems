
HOW TO - Build and Run:



erl is an abbrevation for (w)erl.

Build all files from an opened erl console with

erl> make:all().

Run each command in a separate shell.
First run the hbq

shell> erl -sname hbqNode@localhost -run hbq start

Second run the server

shell> erl -sname serverNode@localhost -run server start

Third run the client

shell> erl -sname client -run client start

If the servers shutdown is too fast set the latency (given in seconds) in your server.cfg to a reasonable time.

To shutdown the nodes, simply terminate the three shells.