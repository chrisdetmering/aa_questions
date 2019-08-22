require_relative 'questions_database'
require_relative 'users'
require_relative 'questions'

class QuestionLike 

  attr_accessor :id, :user_id, :question_id

  def self.all 
    data = QuestionsDatabase.execute('SELECT * FROM questions_like')
    data.map { |datum| QuestionLike.new(datum) }
  end 

  def self.likers_for_question_id(question_id)
    like_data = QuestionsDatabase.execute(<<-SQL,  question_id: question_id)
      SELECT 
        users.* 
      FROM 
        users 
      JOIN 
        questions_like 
      ON 
        questions_like.user_id = users.id 
      WHERE 
        questions_like.question_id = :question_id
    SQL

    like_data.map {|liker| Users.new(liker)}
  end 

  def self.num_likes_for_question_id(question_id)
    QuestionsDatabase.execute(<<-SQL,  question_id: question_id)
      SELECT 
        COUNT(*) as likes 
      FROM 
        questions
      JOIN 
        questions_like 
      ON 
        questions.id = questions_like.question_id
      WHERE 
        questions.id = :question_id
    SQL
  end 

  def self.liked_questions_for_user_id(user_id)
     questions_data = QuestionsDatabase.execute(<<-SQL, user_id: user_id)
      SELECT 
        questions.*
      FROM 
        questions
      JOIN 
        questions_like 
      ON 
        questions.id = questions_like.question_id
      WHERE 
        questions_like.user_id = :user_id
    SQL

    questions_data.map{ |liked_questions| Questions.new(liked_questions) }
  end 

  def self.most_liked_questions(n)
   questions_data = QuestionsDatabase.execute(<<-SQL, limit: n)
      SELECT 
        questions.* 
      FROM 
        questions
      JOIN 
        questions_like 
      ON 
        questions.id = questions_like.question_id
      GROUP BY 
        questions.id 
      ORDER BY 
        COUNT(*) DESC
      LIMIT 
        :limit
    SQL

    questions_data.map { |question_data| Questions.new(question_data)}
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end


  def save
    if self.id
      update 
    else 
      QuestionsDatabase.execute(<<-SQL, self.user_id, self.question_id)
        INSERT INTO
          questions_like (user_id, question_id)
        VALUES
          (?, ?)
      SQL
      self.id = QuestionsDatabase.last_insert_row_id
    end
  end

  def update
    QuestionsDatabase.execute(<<-SQL, self.user_id, self.question_id, self.id)
      UPDATE
        questions_like
      SET
        user_id = ?, question_id = ?
      WHERE
        id = ?
    SQL
  end

end 