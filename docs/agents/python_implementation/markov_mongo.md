## Storage of Markov Games

To store the Markov games, we decided to go with mongodb.

A few advantages:
 - Don't have to deal with parsing text.
 - Can store large amounts of data, without dealing with large text files in repositories.
 - It's a NoSQL database so the representation in the database closely matches what it looks like in memory when you read it.
 - We can store arbitrary data / info along with the states, so we don't have to recompute it every time.