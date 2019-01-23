module Jekyll
  class GithubAuthorTag < Liquid::Tag
    def initialize(tag_name, input, tokens)
      super
      @input = input
    end
  
    def render(context)
      # Split the input variable (omitting error checking)
      input_split = split_params(@input)
      author = input_split[0].strip

      <<~GITHUBAUTHORBLOCK
      <div class="github-contributor">
        <img class="github-avatar" src="https://avatars.githubusercontent.com/#{author}?s=60&v=4"/>
        <span>
          <a href="http://github.com/#{author}">@#{author}</a>
        </span>
      </div>
      GITHUBAUTHORBLOCK

    end
  
    def split_params(params)
      params.split("|")
    end
  end
end
Liquid::Template.register_tag('githubauthor', Jekyll::GithubAuthorTag)