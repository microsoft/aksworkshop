module Jekyll
  class CollapsibleTagBlock < Liquid::Block

    def render(context)
      contents = super

      # pipe param through liquid to make additional replacements possible
      content = Liquid::Template.parse(contents).render context

      output = '<button class="toggle-collapsible">Show solution</button>'
      output += '<div class="collapsible-content">'
      output += content
      output += '</div>'

      # return output
      output
    end

  end
end

Liquid::Template.register_tag('collapsible', Jekyll::CollapsibleTagBlock)