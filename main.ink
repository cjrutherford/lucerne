` Lucerne, a twitter client `

std := load('vendor/std')
str := load('vendor/str')
json := load('vendor/json')

log := std.log
f := std.format
deJSON := json.de

readFile := std.readFile

http := load('vendor/http')
mime := load('vendor/mime')
percent := load('vendor/percent')

mimeForPath := mime.forPath
pctDecode := percent.decode

twitter := load('lib/twitter')

server := (http.new)()
MethodNotAllowed := {status: 405, body: 'method not allowed'}

serveStatic := path => (req, end) => req.method :: {
	'GET' -> readFile('static/' + path, file => file :: {
		() -> end({status: 404, body: 'file not found'})
		_ -> end({
			status: 200
			headers: {'Content-Type': mimeForPath(path)}
			body: file
		})
	})
	_ -> end(MethodNotAllowed)
}

addRoute := server.addRoute
addRoute('/timeline', params => (req, end) => req.method :: {
	'GET' -> retrieve(data => end({
		status: 200
		headers: {'Content-Type': 'application/json'}
		body: data :: {
			() -> '{"error": "failed to fetch"}'
			_ -> data
		}
	}))
	_ -> end(MethodNotAllowed)
})
addRoute('/static/*staticPath', params => serveStatic(params.staticPath))
addRoute('/', params => serveStatic('index.html'))

end := (server.start)(7238)
log(f('Lucerne started, listening on 0.0.0.0:{{0}}', [7283]))

`` TEST
`` send('Tweet sent with Ink, ' + string(floor(time())))
`` retrieve()
retrieve := cb => (
	readFile := std.readFile
	readFile('./home_timeline.json', file => file :: {
		() -> cb(())
		_ -> cb(file)
	})
)