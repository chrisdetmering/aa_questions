require_relative 'questions_database'
require_relative 'questions'
require_relative 'replies'

class Users 

  attr_accessor :id, :fname, :lname
  def self.find_by_name(fname, lname)
    user_data = QuestionsDatabase.get_first_row(<<-SQL, fname: fname, lname: lname)
      SELECT 
        users.*
      FROM 
        users
      WHERE 
        users.fname = :fname AND users.lname = :lname  
    SQL
    Users.new(user_data)
  end 

   def self.find_by_id(id)
    user_data = QuestionsDatabase.get_first_row(<<-SQL, id: id)
      SELECT 
        users.*
      FROM 
        users
      WHERE 
        users.id = :id 
    SQL
    Users.new(user_data)
  end 

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end 
    
  def authord_questions 
    Questions.find_by_author_id(self.id)
  end 

  def authord_replies 
    Reply.find_by_user_id(self.id)
  end 

  def followed_questions 
    QuestionsFollow.followers_for_user_id(id)
  end 

  def liked_questions 
    QuestionLike.liked_questions_for_user_id(id)
  end 


  def average_karma 
    data = QuestionsDatabase.execute(<<-SQL, id: self.id)
      SELECT 
        questions.title, 
        CAST(COUNT(questions.author_id) as float) / COUNT(DISTINCT questions.id) as avg_likes
      FROM 
        questions 
      JOIN 
        questions_like ON questions.id = questions_like.question_id
      WHERE
        questions.author_id = :id
      GROUP BY 
        questions.author_id 
      SQL

    data 
  end 


  def save
    if self.id
      update 
    else 
      QuestionsDatabase.execute(<<-SQL, self.fname, self.lname)
        INSERT INTO
          users (fname, lname)
        VALUES
          (?, ?)
      SQL
      self.id = QuestionsDatabase.last_insert_row_id
    end
  end

  def update
    QuestionsDatabase.execute(<<-SQL, self.fname, self.lname, self.id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end

end