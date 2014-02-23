require 'socket'
require 'base64'

REFRESH_RATE = 1*1000
SCREEN_CAPTURE_COMMAND = 'screencapture -C -x tmp.png'
image = ''
latest = Time.now
server = TCPServer.new 3000

Thread.abort_on_exception = true

puts 'Sharable available on http://localhost:3000'

loop do
  Thread.start(server.accept) do |client|
    system(SCREEN_CAPTURE_COMMAND)
    latest = Time.now
    File.open('tmp.png', 'rb') do |file|
      image = 'data:image/png;base64,'+Base64.encode64(file.read)
    end

    client.puts <<-HTML
      <html>
        <head>
          <meta name="viewport" content="width=device-width, user-scalable=no" />
          <script>
            setTimeout(function(){
              document.location.reload();
            }, #{REFRESH_RATE});
          </script>
        </head>
        <body style="padding:0px;margin:0px;">
          <image src="#{image}" style="height:100%;width:100%;" />
        </body>
      </html>
    HTML

    client.close
  end
end
