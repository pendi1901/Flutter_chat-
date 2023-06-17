// // Importing redis client
// // By default the redis client connects to redis instance running at localhost:6379
// const Redis = require("ioredis");
// const redisClient = new Redis();

// // Importing socket.io, http and express
// // and initializing express and socket.io
// const { Server } = require("socket.io");
// const express = require("express");
// const http = require("http");
// const app = express();
// const server = http.createServer(app);
// const io = new Server(server);

// // Importing Joi and uuid
// const { v4: uuidv4 } = require("uuid");
// const Joi = require("joi");

// // Defining a basic schema to validate
// // incoming chat messages
// const chatMessageSchema = Joi.object({
//   username: Joi.string().min(3).max(30).required(),
//   message: Joi.string().min(1).max(1000).required(),
// });

// app.get("/", (req, res) => {
//   res.send("kuch bhi");
// });

// io.on("connection", async (socket) => {
//   console.log("user connected");

//   const existingMessages = await redisClient.lrange("chat_messages", 0, -1);
//   const parsedMessages = existingMessages.map((item) => JSON.parse(item));
//   socket.emit("messages", parsedMessages);

//   socket.on("message", (data) => {
//     console.log(data);
//     // Validating the message
//     const { value, error } = chatMessageSchema.validate(data);

//     // If the message is invalid, then sending error
//     if (error) {
//       console.log("Invalid message, error occurred", error);
//       // Triggering an error event to the user
//       socket.emit("error", error);
//       return;
//     }

//     // If message is valid, then creating a new message object
//     const newMessage = {
//       id: uuidv4(), // Generating a unique id for the message
//       username: value.username,
//       message: value.message,
//       created: new Date().getTime(), // Creating timestamp for the message
//     };

//     // Saving message in redis in list named "chat_messages"
//     redisClient.lpush("chat_messages", JSON.stringify(newMessage));

//     // Sending the new message to call the connected clients
//     io.emit("message", newMessage);
//   });
// });

// server.listen(3000, () => {
//   console.log("App started on port 3000");
// });


// Importing redis client
// By default the redis client connects to redis instance running at localhost:6379
const Redis = require("ioredis");
const redisClient = new Redis();

// Importing socket.io, http and express
// and initializing express and socket.io
const { Server } = require("socket.io");
const express = require("express");
const http = require("http");
const app = express();
const server = http.createServer(app);
const io = new Server(server);

// Importing Joi and uuid
const { v4: uuidv4 } = require("uuid");
const Joi = require("joi");

// Defining a basic schema to validate
// incoming chat messages
const chatMessageSchema = Joi.object({
  username: Joi.string().min(3).max(30).required(),
  message: Joi.string().min(1).max(1000).required(),
});

app.get("/", (req, res) => {
  res.send("kuch bhi");
});

io.on("connection", async (socket) => {
  console.log("user connected");

  const existingMessages = await redisClient.lrange("chat_messages", 0, -1);
  const parsedMessages = existingMessages.map((item) => JSON.parse(item));
  socket.emit("messages", parsedMessages);

  socket.on("message", (data) => {
    console.log(data);
    // Validating the message
    const { value, error } = chatMessageSchema.validate(data);

    // If the message is invalid, then sending error
    if (error) {
      console.log("Invalid message, error occurred", error);
      // Triggering an error event to the user
      socket.emit("error", error);
      return;
    }

    // If message is valid, then creating a new message object
    const newMessage = {
      id: uuidv4(), // Generating a unique id for the message
      username: data.username, // Set a default username if not provided
      message: value.message,
      created: new Date().getTime(), // Creating timestamp for the message
    };

    // Saving message in redis in list named "chat_messages"
    redisClient.lpush("chat_messages", JSON.stringify(newMessage));

    // Sending the new message to all the connected clients
    io.emit("message", newMessage);
  });

});

server.listen(3000, () => {
  console.log("App started on port 3000");
});
