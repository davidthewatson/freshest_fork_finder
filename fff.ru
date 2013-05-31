require 'scorched'
require 'rest-client'
require 'json'

class App < Scorched::Controller

  def retrieve_json url
    response = RestClient.get url
    data = JSON.parse(response)
    data.sort_by { |hsh| hsh[:updated_at] }
  end

  def render_table data
    rows = '<table class="table"><tr><th>Fork</th><th>URL</th><th>Updated At</th></tr>'
    data.each do |d|
      rows += '<tr>'
      d.each do |f|
        if f[0] == 'full_name' || f[0] == 'updated_at'
          rows += '<td>' + f[1].to_s + '</td>'
        elsif f[0] == 'html_url'
          rows += '<td><a href="' + f[1].to_s + '">' + f[1].to_s + '</a></td>'
        end
      end
      rows += '</tr>'
    end
    rows += '</table>'
    rows
  end

  get '/' do
    response['Content-Type'] = 'text/html'
    <<-HTML
    <!DOCTYPE html>
    <html>
    <xmp theme="united" style="display:none;">
# Enter a github repository that has forks
<form method="POST" action="#{absolute(request.matched_path)}" enctype="multipart/form-data">
  <input type="text" name="url" />
  <input type="submit" value="Submit" />
</form>
    </xmp>
    <script src="http://strapdownjs.com/v/0.2/strapdown.js"></script>
    </html>
    HTML
  end

  post '/' do
    url = request[:url]
    data = retrieve_json url
    table = render_table data
    <<-HTML
    <!DOCTYPE html>
    <html>
    <xmp theme="united" style="display:none;">
# Enter a github repository that has forks
<form class="form-horizontal" method="POST" action="#{absolute(request.matched_path)}" enctype="multipart/form-data">
  <div class="control-group">
    <label class="control-label" for="url">Github Repository URL</label>
    <div class="controls">
  <input class="input-large search-query" type="text" name="url" />
    </div>
  </div>
  <div class="action">
  <input type="submit" value="Submit" />
</div>
</form>
#{table}
    </xmp>
    <script src="http://strapdownjs.com/v/0.2/strapdown.js"></script>
    </html>
    HTML

  end

end
run App
