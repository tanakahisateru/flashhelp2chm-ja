require 'net/http'
require 'set'
require 'fileutils'

host = ARGV[0]
remote_base = ARGV[1]
local_base = ARGV[2]

host = 'livedocs.adobe.com'
remote_base = '/flex/3_jp/langref'
startfile = 'index.html'
local_base = 'langref'

task = [startfile]
cmpl = Set.new()

def findlink(html, url, task, cmpl)
	html.scan(/(src|href)=\"([^\"\'\?\#]+)\"/) { |hit|
		dir = url.split('/')[0...-1].join('/')
		found = dir + hit[1]
		if not (Set[task] + cmpl).include?(found) then
			print "found : %s\n" % found
			task.push(found)
		end
	}
end



while not task.empty?
	url = task.shift()
	Net::HTTP.start(host) { |http|
		print "getting : %s\n" % url
		resp = http.get(remote_base + '/' + url)
		if resp.code == "200" then
			dir = local_base + '/' + url.split('/')[0...-1].join('/')
			FileUtils.mkdir_p(dir) if not File.exist?(dir)
			open(local_base + '/' + url, 'wb') { |fd|
				fd.write(resp.body)
			}
			findlink(resp.body, url, task, cmpl)
		end
		cmpl.add(url)
	}
end
