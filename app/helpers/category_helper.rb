module CategoryHelper
  #recusvly add lists for hierchal display of categories
  #[name,dagrs_list,node_list]
  def recursive_tree(nodes,html)
    html << '<ul>'
    nodes.each do |node|
      html << '<li>'
      html << "<a href=\"/category/show/#{node[0]}\">#{node[1]}</a>"
      recursive_tree(node[3],html) if !node[3].empty?
      html << '</li>'
    end
    html << '</ul>'
    return html.html_safe
  end   
end
