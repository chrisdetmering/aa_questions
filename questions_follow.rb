require_relative 'questions_database'
require_relative 'users'
require_relative 'questions'

class QuestionsFollow

  attr_accessor :id, :user_id, :question_id

  def self.all
    data = QuestionsDatabase.execute("SELECT * FROM questions_follow")
    data.map { |datum| QuestionsFollow.new(datum) }
  end

  def self.find_by_id(id)
    questions_data = QuestionsDatabase.get_first_row(<<-SQL, id: id )
      SELECT 
        questions_follow.*
      FROM 
        questions_follow
      WHERE 
        questions_follow.id = :id
    SQL
    QuestionsFollow.new(questions_data)
  end 

  def self.followers_for_question_id(question_id)
    users_data = QuestionsDatabase.execute(<<-SQL, question_id: question_id)
      SELECT 
        users.*
      FROM 
        users 
      JOIN 
        questions_follow 
      ON 
        users.id = questions_follow.user_id 
      WHERE 
        questions_follow.question_id = :question_id
    SQL

    users_data.map {|followers| Users.new(followers)}
  end 

  def self.followers_for_user_id(user_id)
    questions_data = QuestionsDatabase.execute(<<-SQL, user_id: user_id)
      SELECT 
        questions.* 
      FROM 
       questions
      JOIN 
        questions_follow 
      ON 
        questions.id = questions_follow.question_id
      WHERE 
        questions_follow.user_id = :user_id
    SQL

    questions_data.map {|followers| Questions.new(followers)}
  end 

  #Fetches the n most followed questions.

  def self.most_followed_questions(n)
    questions_data = QuestionsDatabase.execute(<<-SQL, limit: n)
      SELECT 
        questions.*
      FROM 
        questions_follow
      JOIN 
        questions 
      ON 
        questions_follow.question_id = questions.id
      GROUP BY 
        question_id
      ORDER BY 
        COUNT(*) DESC
      LIMIT :limit
    SQL

    questions_data
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end 


end