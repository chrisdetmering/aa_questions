require_relative 'questions_database'
require_relative 'users'
require_relative 'questions'

class Reply
  attr_reader :id
  attr_accessor :question_id, :parent_reply_id, :user_reply_id, :body

  def self.all
    data = QuestionsDatabase.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end


  def self.find_by_id(id)
    replies_data = QuestionsDatabase.get_first_row(<<-SQL, id: id )
      SELECT 
        replies.*
      FROM 
        replies
      WHERE 
        replies.id = :id
    SQL
    Reply.new(replies_data)
  end 

  def self.find_by_user_id(user_id)
    replies_data = QuestionsDatabase.execute(<<-SQL, user_id: user_id )
      SELECT 
        replies.*
      FROM 
        replies
      WHERE 
        replies.user_reply_id = :user_id
    SQL
    replies_data.map { |reply_data| Reply.new(reply_data) }
  end 

  def self.find_by_parent_id(parent_id)
    replies_data = QuestionsDatabase.execute(<<-SQL, parent_id: parent_id )
      SELECT 
        replies.*
      FROM 
        replies
      WHERE 
        replies.parent_reply_id = :parent_id
    SQL
    replies_data.map { |reply_data| Reply.new(reply_data) }
  end 

  def self.find_by_question_id(question_id)
    replies_data = QuestionsDatabase.execute(<<-SQL, question_id: question_id )
      SELECT 
        replies.*
      FROM 
        replies
      WHERE 
        replies.question_id = :question_id
    SQL
    replies_data.map { |reply_data| Reply.new(reply_data) }
  end 

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @user_reply_id = options['user_reply_id']
    @body = options['body']
  end 

  def attrs 
    { question_id: question_id, 
      parent_reply_id: parent_reply_id, 
      user_reply_id: user_reply_id, 
      body: body }
  end 



  def author 
    Users.find_by_id(user_reply_id)
  end 

  def question 
    Questions.find_by_id(question_id)
  end 

  def parent_reply 
    Reply.find_by_id(parent_reply_id)
  end 

  def child_replies 
    Reply.find_by_parent_id(id)
  end 


  def save
    if self.id
      update 
    else 
      QuestionsDatabase.execute(<<-SQL, attrs)
        INSERT INTO
          replies (question_id, parent_reply_id, user_reply_id, body)
        VALUES
          (:question_id, :parent_reply_id, :user_reply_id, :body)
      SQL
      self.id = QuestionsDatabase.last_insert_row_id
    end
  end

  def update
    QuestionsDatabase.execute(<<-SQL, attrs.merge({ id: @id }))
      UPDATE
        replies
      SET
        question_id = :question_id, 
        parent_reply_id = :parent_reply_id, 
        user_reply_id = :user_reply_id, 
        body = :body 
      WHERE
        replies.id = :id
    SQL
  end

end