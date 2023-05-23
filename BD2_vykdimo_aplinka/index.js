const express = require("express");
var mongoose = require("mongoose"),
  Schema = mongoose.Schema;
const { Server } = require("socket.io");


io = new Server(server);
var app = express(),
  server = require("http").createServer(app),
  io = io.listen(server);

const userSchema = new mongoose.Schema({
  username: String,
  password: String,
  dateOfBirth: String,
  email: String,
  scores:[]
});
const User = mongoose.model("User", userSchema);

const categorySchema = new mongoose.Schema({
  name: String,
});
const Category = mongoose.model("Category", categorySchema);

const AnswerSchema = new mongoose.Schema({
  user: [{ type: Schema.Types.ObjectId, ref: "User" }],
  category: [{ type: Schema.Types.ObjectId, ref: "Category" }],
  text: String,
  score: []
});
const Answer = mongoose.model("Answer", AnswerSchema);

const QuestionSchema = new mongoose.Schema({
  user: [{ type: Schema.Types.ObjectId, ref: "User" }],
  category: [{ type: Schema.Types.ObjectId, ref: "Category" }],
  text: String,
  answers: [{ type: Schema.Types.ObjectId, ref: "Answer" }],
});
const Question = mongoose.model("Question", QuestionSchema);


const reportedAnswerSchema = new mongoose.Schema({
  reportedUser: [{ type: Schema.Types.ObjectId, ref: "User" }],
  answer: [{ type: Schema.Types.ObjectId, ref: "Answer" }],
});
const ReportedAnswer = mongoose.model("ReportedAnswer", reportedAnswerSchema);

app.use(express.json());

app.get("/category", (req, res) => {
  Category.find()
    .then((result) => {
      console.log(result);
      res.send(result);
    })
    .catch("category fetch error");
});

app.post("/category",  (req, res) => {
console.log(req.query.name);
   Category.findOne({name: req.query.name }).then((result) => {
    if(result != null) res.send("CATEGORY EXISTS");
    else {
      const newCategory = new Category({
        name: req.query.name,
      });
      newCategory.save();
    
      res.send(newCategory);
    }
  })
});

app.post("/question", (req, res) => {
  console.log(req.body);

  const newQuestion = new Question({
    user: [req.body.user],
    category: req.body.category,
    text: req.body.text,
  });
  newQuestion.save();

  res.send(newQuestion);
});


app.post("/score", async (req, res) => {

  var scoreEntry;
  var categorizedScoreEntry;
  var modifiedScore = 0;
  await Answer.findById(req.query.asnwerId).then((result) => {

    //cia logika turi buti 
    scoreEntry = result.score.find(e => e.callerId == req.query.callerId);
    if(scoreEntry == null){
      result.score.push(
        {
        callerId: req.query.callerId,
        user: req.query.user,
        scoreModifier: req.query.scoreModifier
      });



      User.findById(req.query.user).then((result) => {
        categorizedScoreEntry = result.scores.find(e => e.category == req.query.category);
        if(categorizedScoreEntry == undefined){
          result.scores.push({
            category: req.query.category,
            score: req.query.scoreModifier
        });
        result.save();
        modifiedScore = req.query.scoreModifier;
        }
        else if(categorizedScoreEntry != undefined){
          result.scores.pull(categorizedScoreEntry);
          newScore = parseInt(categorizedScoreEntry.score)+parseInt(req.query.scoreModifier);
          categorizedScoreEntry.score=newScore;
          result.scores.push(categorizedScoreEntry);
          result.save();
          modifiedScore = req.query.scoreModifier;
          res.send({modifiedScore: modifiedScore});
        }
        
        });  
    }
    else{
      if(scoreEntry.scoreModifier == 1 && req.query.scoreModifier == -1){
        result.score.pull(scoreEntry);

        User.findById(req.query.user).then((result) => {
          var categorizedScoreEntry = result.scores.find(e => e.category == req.query.category);
          if(categorizedScoreEntry == undefined){
            result.scores.push({
              category: req.query.category,
              score: req.query.scoreModifier
          });
          result.save();
          modifiedScore = req.query.scoreModifier;
          res.send({modifiedScore: modifiedScore});
          }
          else if(categorizedScoreEntry != undefined){
            result.scores.pull(categorizedScoreEntry);
            newScore = parseInt(categorizedScoreEntry.score)+parseInt(req.query.scoreModifier);
            categorizedScoreEntry.score=newScore;
            result.scores.push(categorizedScoreEntry);
            result.save();
            modifiedScore = req.query.scoreModifier;
            res.send({modifiedScore: modifiedScore});
          }
          });
          

      }
      if(scoreEntry.scoreModifier == -1 && req.query.scoreModifier == 1){
        result.score.pull(scoreEntry);

        User.findById(req.query.user).then((result) => {
          var categorizedScoreEntry = result.scores.find(e => e.category == req.query.category);
          if(categorizedScoreEntry == undefined){
            result.scores.push({
              category: req.query.category,
              score: req.query.scoreModifier
          });
          result.save();
          modifiedScore = req.query.scoreModifier;
          }
          else if(categorizedScoreEntry != undefined){
            result.scores.pull(categorizedScoreEntry);
            newScore = parseInt(categorizedScoreEntry.score)+parseInt(req.query.scoreModifier);
            categorizedScoreEntry.score=newScore;
            result.scores.push(categorizedScoreEntry);
            result.save();
            modifiedScore = req.query.scoreModifier;
            res.send({modifiedScore: modifiedScore});
          }
          });
          
      }
    }

    result.save();
    
   
  }
  
  )
  
  
});


app.post("/answer/:id", (req, res) => {
  const newAnswer = new Answer({
    user: req.body.user,
    category: req.body.category,
    text: req.body.text,
  });



    newAnswer.save();
    var reference;
    update = Question.findById(req.params.id)
      .then((result) => {
        result.answers.push(newAnswer._id);
        result.save();
      })
      .catch("post fetch error");

    result = User.findById(req.body.user)
      .then((result) => {
        res.send({
          user: result,
          category: req.body.category,
          text: req.body.text,
          _id: newAnswer._id,
          __v: 0,
        });
      })
      .catch("post fetch error");
  });

  app.get("/dashboard/question", (req, res) => {
    Question.find()
      .populate("user category")
      .then((result) => {
        console.log(result);
        res.send(result);
      })
      .catch("post fetch error");
  });

  app.get("/dashboard/question/:id", (req, res) => {
    Question.find({ category: mongoose.Types.ObjectId(req.params.id) })
      .populate("user category")
      .then((result) => {
        console.log(result);
        res.send(result);
      })
      .catch("post fetch error");
  });

  app.post("/deleteReportedAnswer", (req, res) => {
    ReportedAnswer.findById(req.query.reportedRecordId).remove().exec();
    res.send('report deleted');
  });

  app.post("/blockUser", (req, res) => {
    Answer.findById(req.query.reportedAnswer).then((result)=>{
      result.text = '[Ištrintas]';
      result.save();
    });
    User.findById(req.query.reportedUser).then((result)=>{
      result.username = '[Užblokuotas]';
      result.isBlocker = true;
      result.save();
    });
    ReportedAnswer.findById(req.query.reportedRecordId).remove().exec();
    res.send('user blocked');
  });

  app.get("/qnaview/question/:id", (req, res) => {
    console.log(req.params.id);
    Question.findById(req.params.id)
      .populate("user category answers")
      .populate({
        path: "answers",
        populate: { path: "user", model: "User" },
      })
      .then((result) => {
        //cia insert into what field
        console.log(result);
        res.send(result.toJSON());
      })
      .catch("post fetch error");
  });

  app.post("/login", (req, res) => {
      User.findOne({ username: req.body.username }).then((result) => {
        console.log(result);
        if(result == null) res.send('USER NOT FOUND');
        else if(result.password != req.body.password) res.send('WRONG PASSWORD');
        else res.send(result.toJSON());
      })
      .catch("post fetch error");
  });

  app.get("/user", async (req, res) => {
    listOfScores = [];
    returnObject = {
      scoreTable: []
    };
    await User.findById(req.query._id).then((result) => {
      returnObject.username = result.username;
      listOfScores.scores = result.scores
      console.log(result);
    });
    for(i = 0; i < listOfScores.scores.length; i++){
        await Category.findById(listOfScores.scores[i].category).then((result) => {
            returnObject.scoreTable.push({
              name: result.name,
              score: listOfScores.scores[i].score
            });
        })
      }
    console.log(returnObject);
    res.send(returnObject);
  });

  app.post("/register", async (req, res) => {
    
    validated = true;
    userDoesExist = true;

    await User.findOne({ username: req.body.username }).then((result) => {
      console.log(result);
      if(result != null) {
        res.send('USER EXISTS');
        userDoesExist = false;
        validated = false;
      }
    })
    if(userDoesExist){
      await User.findOne({ email: req.body.email }).then((result) => {
        console.log(result);
        if(result != null){
          res.send('EMAIL TAKEN');
          validated = false;
        }
      })
    }


    if(validated){
      const newUser = new User({
        username: req.body.username,
        password: req.body.password,
        dateOfBirth: req.body.dateOfBirth,
        email: req.body.email,
      });
      newUser.save();
  
      res.send(newUser);
    }
    
  });

  app.post("/reportAnswer", async (req, res) => {
    const newReportedAnswer = new ReportedAnswer ({
      reportedUser: req.query.user,
      answer: req.query.asnwerId
    })
    newReportedAnswer.save();
    res.send('ANSWER REPORTED');
        
  });

  app.get("/reportedAnswer", async (req, res) => {
    ReportedAnswer.find().populate("reportedUser answer").then((result) => {
      res.send(result);
    })
        
  });

  var ChatSchema = new Schema({}, { strict: false });
  var Chats = mongoose.model("Chats", ChatSchema);
  var chats = new Chats({ iAmNotInTheSchema: true });
  chats.save();

  var MessageSchema = new Schema(
    {
      user: [{ type: Schema.Types.ObjectId, ref: "User" }],
      text: String,
    },
    { strict: false }
  );
  var MessageModel = mongoose.model("Message", MessageSchema);

  var collection;

  server.listen(3000, async () => {
    try {
      await await mongoose
        .connect("mongodb://localhost:2000/platformDb")
        .then(() => {
          console.log("db is connected");
        })
        .catch((err) => console.log(err, "it has an error"));
      collection = Chats.find();
      console.log("Listening on port :%s...", "3000");
    } catch (e) {
      console.error(e);
    }
  });

  io.on("connection", (socket) => {
    console.log("somebody is tinkering");

    socket.on("room", function (room) {
      socket.join(room);

    });

    socket.on("msg", (message) => {
      room = "abc123"; 
      message = new MessageModel({
        roomId: message.roomId,
        user: message.user,
        text: message.text,
      });
      message.save();
      io.to(socket.room).emit("msg", message);
    });
  });

  app.get("/chats", async (req, res) => {
    MessageModel.find({ roomId: req.query.roomId }).then((result) => {

      console.log(result);
      res.send(JSON.stringify(result));

    });
  });

module.exports = app;