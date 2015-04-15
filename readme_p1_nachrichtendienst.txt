
HOW TO - Build and Run:

erl is an abbrevation for (w)erl.

1. Build all files from an opened erl console with

  erl> make:all().

2. Run each command in a separate shell.
  2.1. Start the hbq node

    shell> erl -name hbqNode -setcookie hallo

  2.2. Run the server

    shell> erl -sname server -setcookie hallo -run server start

  2.3. Run the client

    shell> erl -name client -setcookie hallo -run client start

3. If the servers shutdown is too fast set the latency (given in seconds) in your server.cfg to a reasonable time.

4. To shutdown the nodes, simply terminate the three shells.