require_relative 'questions_database'
require_relative 'users'

class Questions 

  attr_accessor :id, :title, :body, :author_id
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Questions.new(datum) }
  end

  def most_liked(n)
    QuestionLike.most_liked_questions(n)
  end 

  def self.find_by_id(id)
    questions_data = QuestionsDatabase.get_first_row(<<-SQL, id: id )
      SELECT 
        questions.*
      FROM 
        questions 
      WHERE 
        questions.id = :id
    SQL
    Questions.new(questions_data)
  end 

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end 

  def self.find_by_author_id(author_id)
    questions_data = QuestionsDatabase.execute(<<-SQL, author_id: author_id )
      SELECT 
        questions.*
      FROM 
        questions 
      WHERE 
        questions.author_id = :author_id
    SQL
    questions_data.map { |question| Questions.new(question) } 
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end 

  def author
    User.find_by_id(author_id)
  end 

  def replies 
    Reply.find_by_question_id(id)
  end 

  def followers 
    QuestionFollows.followers_for_question_id(id)
  end 

  def likers 
    QuestionLike.likers_for_question_id(id)
  end 

  def num_likes
    QuestionLike.num_likes_for_question_id(question_id)
  end



  def save
    if self.id
      update 
    else 
      QuestionsDatabase.execute(<<-SQL, self.title, self.body, self.author_id)
        INSERT INTO
          questions (title, body, author_id)
        VALUES
          (?, ?, ?)
      SQL
      self.id = QuestionsDatabase.last_insert_row_id
    end
  end

  def update
    QuestionsDatabase.execute(<<-SQL, self.title, self.body, self.author_id, self.id)
      UPDATE
        questions
      SET
        title = ?, body = ?, author_id = ?
      WHERE
        id = ?
    SQL
  end

end